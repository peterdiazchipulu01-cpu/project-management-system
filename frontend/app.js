const API = '/api';

let currentProjectId = null;
let editingTaskId = null;
let editingProjectId = null;

// ── API helpers ──────────────────────────────────────────────────
async function apiFetch(path, options = {}) {
  const res = await fetch(API + path, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  });
  if (!res.ok) {
    const err = await res.text();
    throw new Error(err || `HTTP ${res.status}`);
  }
  if (res.status === 204) return null;
  return res.json();
}

const api = {
  projects: {
    list:   ()       => apiFetch('/projects/'),
    get:    (id)     => apiFetch(`/projects/${id}`),
    create: (data)   => apiFetch('/projects/', { method: 'POST', body: JSON.stringify(data) }),
    update: (id, d)  => apiFetch(`/projects/${id}`, { method: 'PUT', body: JSON.stringify(d) }),
    delete: (id)     => apiFetch(`/projects/${id}`, { method: 'DELETE' }),
  },
  tasks: {
    list:   (projId) => apiFetch(`/tasks/?project_id=${projId}`),
    create: (data)   => apiFetch('/tasks/', { method: 'POST', body: JSON.stringify(data) }),
    update: (id, d)  => apiFetch(`/tasks/${id}`, { method: 'PUT', body: JSON.stringify(d) }),
    delete: (id)     => apiFetch(`/tasks/${id}`, { method: 'DELETE' }),
  },
  users: {
    list:   ()     => apiFetch('/users/'),
    create: (data) => apiFetch('/users/', { method: 'POST', body: JSON.stringify(data) }),
  },
};

// ── Helpers ──────────────────────────────────────────────────────
function esc(s) {
  return String(s ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}

function showError(msg) {
  alert(`Error: ${msg}`);
}

// ── Projects sidebar ─────────────────────────────────────────────
async function renderProjects() {
  const projects = await api.projects.list();
  const list = document.getElementById('project-list');
  list.innerHTML = '';
  projects.forEach(p => {
    const li = document.createElement('li');
    li.textContent = p.name;
    li.dataset.id = p.id;
    if (p.id === currentProjectId) li.classList.add('active');
    li.addEventListener('click', () => selectProject(p.id, p.name));
    list.appendChild(li);
  });
}

async function selectProject(id, name) {
  currentProjectId = id;
  document.getElementById('no-project-msg').classList.add('hidden');
  document.getElementById('project-board').classList.remove('hidden');
  document.getElementById('project-title').textContent = name;
  document.querySelectorAll('#project-list li').forEach(li =>
    li.classList.toggle('active', Number(li.dataset.id) === id)
  );
  await renderTasks();
}

// ── Tasks / Kanban ───────────────────────────────────────────────
async function renderTasks() {
  if (!currentProjectId) return;
  const tasks = await api.tasks.list(currentProjectId);
  const colMap = { todo: 'col-todo', in_progress: 'col-in-progress', done: 'col-done' };
  Object.values(colMap).forEach(id => { document.getElementById(id).innerHTML = ''; });
  tasks.forEach(t => {
    const colId = colMap[t.status] ?? 'col-todo';
    document.getElementById(colId).appendChild(makeTaskCard(t));
  });
}

function makeTaskCard(task) {
  const card = document.createElement('div');
  card.className = 'task-card';
  const due = task.due_date ? `<span>Due ${task.due_date.substring(0, 10)}</span>` : '';
  card.innerHTML = `
    <h4>${esc(task.title)}</h4>
    <div class="task-meta">
      <span class="badge badge-${task.priority}">${task.priority}</span>
      ${due}
    </div>`;
  card.addEventListener('click', () => openEditTaskModal(task));
  return card;
}

// ── Project modal ────────────────────────────────────────────────
function openNewProjectModal() {
  editingProjectId = null;
  document.getElementById('modal-project-title').textContent = 'New Project';
  document.getElementById('form-project').reset();
  document.getElementById('modal-project').classList.remove('hidden');
}

async function openEditProjectModal() {
  if (!currentProjectId) return;
  try {
    const p = await api.projects.get(currentProjectId);
    editingProjectId = p.id;
    document.getElementById('modal-project-title').textContent = 'Edit Project';
    const form = document.getElementById('form-project');
    form.elements.name.value = p.name;
    form.elements.description.value = p.description ?? '';
    document.getElementById('modal-project').classList.remove('hidden');
  } catch (e) { showError(e.message); }
}

async function submitProjectForm(e) {
  e.preventDefault();
  const form = e.target;
  const data = {
    name: form.elements.name.value.trim(),
    description: form.elements.description.value.trim() || null,
  };
  try {
    if (editingProjectId) {
      const updated = await api.projects.update(editingProjectId, data);
      closeModal('modal-project');
      await renderProjects();
      document.getElementById('project-title').textContent = updated.name;
    } else {
      const proj = await api.projects.create(data);
      closeModal('modal-project');
      await renderProjects();
      await selectProject(proj.id, proj.name);
    }
  } catch (e) { showError(e.message); }
}

async function deleteCurrentProject() {
  if (!currentProjectId) return;
  if (!confirm('Delete this project and all its tasks?')) return;
  try {
    await api.projects.delete(currentProjectId);
    currentProjectId = null;
    document.getElementById('project-board').classList.add('hidden');
    document.getElementById('no-project-msg').classList.remove('hidden');
    await renderProjects();
  } catch (e) { showError(e.message); }
}

// ── Task modal ───────────────────────────────────────────────────
async function openNewTaskModal() {
  editingTaskId = null;
  document.getElementById('modal-task-title').textContent = 'New Task';
  document.getElementById('btn-delete-task').classList.add('hidden');
  document.getElementById('form-task').reset();
  await populateAssignees(null);
  document.getElementById('modal-task').classList.remove('hidden');
}

async function openEditTaskModal(task) {
  editingTaskId = task.id;
  document.getElementById('modal-task-title').textContent = 'Edit Task';
  document.getElementById('btn-delete-task').classList.remove('hidden');
  const form = document.getElementById('form-task');
  form.elements.title.value = task.title;
  form.elements.description.value = task.description ?? '';
  form.elements.status.value = task.status;
  form.elements.priority.value = task.priority;
  form.elements.due_date.value = task.due_date ? task.due_date.substring(0, 10) : '';
  await populateAssignees(task.assignee_id);
  document.getElementById('modal-task').classList.remove('hidden');
}

async function populateAssignees(selectedId) {
  const users = await api.users.list();
  const sel = document.getElementById('form-task').elements.assignee_id;
  sel.innerHTML = '<option value="">— Unassigned —</option>';
  users.forEach(u => {
    const opt = document.createElement('option');
    opt.value = u.id;
    opt.textContent = u.name;
    if (u.id === selectedId) opt.selected = true;
    sel.appendChild(opt);
  });
}

async function submitTaskForm(e) {
  e.preventDefault();
  const form = e.target;
  const dueDateVal = form.elements.due_date.value;
  const assigneeVal = form.elements.assignee_id.value;

  const data = {
    title: form.elements.title.value.trim(),
    description: form.elements.description.value.trim() || null,
    status: form.elements.status.value,
    priority: form.elements.priority.value,
    due_date: dueDateVal ? new Date(dueDateVal).toISOString() : null,
    assignee_id: assigneeVal ? parseInt(assigneeVal, 10) : null,
  };

  try {
    if (editingTaskId) {
      await api.tasks.update(editingTaskId, data);
    } else {
      await api.tasks.create({ ...data, project_id: currentProjectId });
    }
    closeModal('modal-task');
    await renderTasks();
  } catch (e) { showError(e.message); }
}

async function deleteCurrentTask() {
  if (!editingTaskId) return;
  if (!confirm('Delete this task?')) return;
  try {
    await api.tasks.delete(editingTaskId);
    closeModal('modal-task');
    await renderTasks();
  } catch (e) { showError(e.message); }
}

// ── Users modal ──────────────────────────────────────────────────
async function openUsersModal() {
  await renderUserList();
  document.getElementById('form-user').reset();
  document.getElementById('modal-users').classList.remove('hidden');
}

async function renderUserList() {
  const users = await api.users.list();
  const list = document.getElementById('user-list');
  list.innerHTML = '';
  users.forEach(u => {
    const li = document.createElement('li');
    li.textContent = `${u.name} — ${u.email}`;
    list.appendChild(li);
  });
}

async function submitUserForm(e) {
  e.preventDefault();
  const form = e.target;
  try {
    await api.users.create({
      name: form.elements.name.value.trim(),
      email: form.elements.email.value.trim(),
    });
    form.reset();
    await renderUserList();
  } catch (e) { showError(e.message); }
}

// ── Utilities ─────────────────────────────────────────────────────
function closeModal(id) {
  document.getElementById(id).classList.add('hidden');
}

function closeAllModals() {
  document.querySelectorAll('.modal').forEach(m => m.classList.add('hidden'));
}

// ── Bootstrap ─────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', async () => {
  await renderProjects();

  // Buttons
  document.getElementById('btn-new-project').addEventListener('click', openNewProjectModal);
  document.getElementById('btn-edit-project').addEventListener('click', openEditProjectModal);
  document.getElementById('btn-delete-project').addEventListener('click', deleteCurrentProject);
  document.getElementById('btn-new-task').addEventListener('click', openNewTaskModal);
  document.getElementById('btn-delete-task').addEventListener('click', deleteCurrentTask);
  document.getElementById('btn-manage-users').addEventListener('click', openUsersModal);

  // Forms
  document.getElementById('form-project').addEventListener('submit', submitProjectForm);
  document.getElementById('form-task').addEventListener('submit', submitTaskForm);
  document.getElementById('form-user').addEventListener('submit', submitUserForm);

  // Cancel buttons
  document.querySelectorAll('.btn-cancel').forEach(btn =>
    btn.addEventListener('click', closeAllModals)
  );

  // Click-outside-to-close
  document.querySelectorAll('.modal').forEach(modal =>
    modal.addEventListener('click', e => { if (e.target === modal) closeAllModals(); })
  );
});
