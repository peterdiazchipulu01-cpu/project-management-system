const API = '/api';

let currentProjectId = null;
let currentProject   = null;
let currentTab       = 'kanban';
let editingTaskId    = null;
let editingProjectId = null;
let _users           = null;

// ── API helpers ───────────────────────────────────────────────
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
    list:   ()      => apiFetch('/projects/'),
    get:    (id)    => apiFetch(`/projects/${id}`),
    create: (data)  => apiFetch('/projects/', { method: 'POST', body: JSON.stringify(data) }),
    update: (id, d) => apiFetch(`/projects/${id}`, { method: 'PUT', body: JSON.stringify(d) }),
    delete: (id)    => apiFetch(`/projects/${id}`, { method: 'DELETE' }),
  },
  tasks: {
    list:   (pid)   => apiFetch(`/tasks/?project_id=${pid}`),
    create: (data)  => apiFetch('/tasks/', { method: 'POST', body: JSON.stringify(data) }),
    update: (id, d) => apiFetch(`/tasks/${id}`, { method: 'PUT', body: JSON.stringify(d) }),
    delete: (id)    => apiFetch(`/tasks/${id}`, { method: 'DELETE' }),
  },
  users: {
    list:   ()     => apiFetch('/users/'),
    create: (data) => apiFetch('/users/', { method: 'POST', body: JSON.stringify(data) }),
  },
};

// ── Users cache ───────────────────────────────────────────────
async function fetchUsers() {
  if (_users === null) _users = await api.users.list();
  return _users;
}

function invalidateUsers() { _users = null; }

function getUserById(id) {
  return _users ? _users.find(u => u.id === id) : null;
}

// ── Avatar helpers ────────────────────────────────────────────
const AVATAR_PALETTE = [
  '#6366f1','#8b5cf6','#ec4899','#f59e0b',
  '#10b981','#3b82f6','#ef4444','#14b8a6',
  '#f97316','#06b6d4','#84cc16','#a855f7',
];

function avatarColor(id) {
  return AVATAR_PALETTE[(id - 1) % AVATAR_PALETTE.length];
}

function avatarInitials(name) {
  return String(name).split(/\s+/).map(w => w[0]).join('').substring(0, 2).toUpperCase();
}

function makeAvatar(user, cls = '') {
  if (!user) return '';
  const color = avatarColor(user.id);
  const init  = avatarInitials(user.name);
  return `<div class="avatar${cls ? ' ' + cls : ''}" style="background:${color}" title="${esc(user.name)}">${init}</div>`;
}

// ── Toast notifications ───────────────────────────────────────
function showToast(msg, type = '') {
  const container = document.getElementById('toast-container');
  const el = document.createElement('div');
  el.className = `toast${type ? ' ' + type : ''}`;
  el.textContent = msg;
  container.appendChild(el);
  setTimeout(() => {
    el.style.animation = 'toast-out 0.2s ease forwards';
    setTimeout(() => el.remove(), 200);
  }, 3000);
}

function showError(msg) { showToast(msg, 'error'); }

// ── Dark mode ─────────────────────────────────────────────────
function setTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  localStorage.setItem('pms-theme', theme);
  const btn = document.getElementById('btn-dark-mode');
  if (btn) btn.textContent = theme === 'dark' ? '☀️' : '🌙';
}

function initDarkMode() {
  setTheme(localStorage.getItem('pms-theme') === 'dark' ? 'dark' : 'light');
}

// ── Helpers ───────────────────────────────────────────────────
function esc(s) {
  return String(s ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}

function parseLocalDate(str) {
  if (!str) return null;
  const s = String(str).substring(0, 10);
  const [y, m, d] = s.split('-').map(Number);
  return new Date(y, m - 1, d);
}

// ── Tab switching ─────────────────────────────────────────────
function switchTab(tabName) {
  currentTab = tabName;
  document.querySelectorAll('.tab-btn').forEach(btn =>
    btn.classList.toggle('active', btn.dataset.tab === tabName)
  );
  document.getElementById('view-kanban').classList.toggle('hidden', tabName !== 'kanban');
  document.getElementById('view-gantt').classList.toggle('hidden',  tabName !== 'gantt');
  document.getElementById('btn-new-task').style.display = tabName === 'kanban' ? '' : 'none';
  if (tabName === 'gantt') renderGantt();
}

// ── Projects sidebar ──────────────────────────────────────────
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
  try {
    currentProject = await api.projects.get(id);
  } catch {
    currentProject = { id, name, start_date: null, end_date: null };
  }

  document.getElementById('no-project-msg').classList.add('hidden');
  document.getElementById('project-board').classList.remove('hidden');
  document.getElementById('project-title').textContent = name;
  document.querySelectorAll('#project-list li').forEach(li =>
    li.classList.toggle('active', Number(li.dataset.id) === id)
  );

  switchTab('kanban');
  await renderTasks();
}

// ── Tasks / Kanban ────────────────────────────────────────────
async function renderTasks() {
  if (!currentProjectId) return;
  try { await fetchUsers(); } catch (_) { /* non-fatal */ }

  const tasks  = await api.tasks.list(currentProjectId);
  const colMap = { todo: 'col-todo', in_progress: 'col-in-progress', done: 'col-done' };
  Object.values(colMap).forEach(id => { document.getElementById(id).innerHTML = ''; });

  const counts = { todo: 0, in_progress: 0, done: 0 };

  tasks.forEach(t => {
    const colId = colMap[t.status] ?? 'col-todo';
    const user  = getUserById(t.assignee_id);
    document.getElementById(colId).appendChild(makeTaskCard(t, user));
    if (counts[t.status] !== undefined) counts[t.status]++;
  });

  document.getElementById('count-todo').textContent        = counts.todo        || '';
  document.getElementById('count-in-progress').textContent = counts.in_progress || '';
  document.getElementById('count-done').textContent        = counts.done        || '';
}

function makeTaskCard(task, user) {
  const card = document.createElement('div');
  card.className   = 'task-card';
  card.draggable   = true;
  card.dataset.taskId = task.id;

  const progress = Math.min(100, Math.max(0, task.progress ?? 0));
  const barClass  = task.status === 'done' ? ' done' : '';

  let dueHTML = '';
  if (task.due_date) {
    const today = new Date(); today.setHours(0,0,0,0);
    const due   = parseLocalDate(task.due_date.substring(0, 10));
    const over  = due < today && task.status !== 'done';
    dueHTML = `<span class="task-due${over ? ' overdue' : ''}">${over ? '⚠ ' : ''}${task.due_date.substring(0, 10)}</span>`;
  }

  const avatarHTML = user ? makeAvatar(user) : '';

  card.innerHTML = `
    <h4>${esc(task.title)}</h4>
    <div class="task-meta">
      <span class="badge badge-${task.priority}">${task.priority}</span>
      ${dueHTML}
    </div>
    <div class="task-footer">
      <div class="task-progress-wrap">
        <div class="task-progress-bar${barClass}" style="width:${progress}%"></div>
      </div>
      <span class="task-progress-pct">${progress}%</span>
      ${avatarHTML}
    </div>`;

  card.addEventListener('dragstart', e => {
    e.dataTransfer.setData('text/plain', String(task.id));
    e.dataTransfer.effectAllowed = 'move';
    setTimeout(() => card.classList.add('dragging'), 0);
  });
  card.addEventListener('dragend', () => card.classList.remove('dragging'));
  card.addEventListener('click',   () => openEditTaskModal(task));
  return card;
}

// ── Drag-and-drop ─────────────────────────────────────────────
function onDragOver(e) {
  e.preventDefault();
  e.dataTransfer.dropEffect = 'move';
  e.currentTarget.classList.add('drag-over');
}

function onDragLeave(e) {
  if (!e.currentTarget.contains(e.relatedTarget)) {
    e.currentTarget.classList.remove('drag-over');
  }
}

async function onDrop(e) {
  e.preventDefault();
  const col = e.currentTarget;
  col.classList.remove('drag-over');
  const taskId   = parseInt(e.dataTransfer.getData('text/plain'), 10);
  const newStatus = col.dataset.status;
  if (!taskId || !newStatus) return;
  try {
    await api.tasks.update(taskId, { status: newStatus });
    await renderTasks();
  } catch (err) { showError(err.message); }
}

// ── Gantt chart ───────────────────────────────────────────────
async function renderGantt() {
  if (!currentProjectId) return;

  const [tasks, proj] = await Promise.all([
    api.tasks.list(currentProjectId),
    api.projects.get(currentProjectId),
  ]);
  currentProject = proj;

  const today = new Date(); today.setHours(0,0,0,0);

  let rangeStart = proj.start_date ? parseLocalDate(proj.start_date) : null;
  let rangeEnd   = proj.end_date   ? parseLocalDate(proj.end_date)   : null;

  if (!rangeStart && tasks.length) {
    const c = tasks.filter(t => t.start_date).map(t => parseLocalDate(t.start_date));
    if (c.length) rangeStart = new Date(Math.min(...c.map(d => d.getTime())));
  }
  if (!rangeEnd && tasks.length) {
    const c = tasks.filter(t => t.due_date).map(t => parseLocalDate(t.due_date.substring(0, 10)));
    if (c.length) { rangeEnd = new Date(Math.max(...c.map(d => d.getTime()))); rangeEnd.setDate(rangeEnd.getDate() + 7); }
  }

  if (!rangeStart) { rangeStart = new Date(today); rangeStart.setDate(today.getDate() - 7); }
  if (!rangeEnd)   { rangeEnd   = new Date(today); rangeEnd.setDate(today.getDate() + 30); }

  const DAY_W    = 36;
  const ROW_H    = 40;
  const DAY_NAMES = ['Su','Mo','Tu','We','Th','Fr','Sa'];

  const days = [];
  const cur  = new Date(rangeStart);
  while (cur <= rangeEnd) { days.push(new Date(cur)); cur.setDate(cur.getDate() + 1); }

  const totalWidth = days.length * DAY_W;

  function dayOffset(str) {
    if (!str) return null;
    const d = parseLocalDate(String(str).substring(0, 10));
    return Math.round((d.getTime() - rangeStart.getTime()) / 86400000) * DAY_W;
  }

  // Sidebar
  const activityList = document.getElementById('gantt-activity-list');
  activityList.innerHTML = '';

  if (!tasks.length) {
    activityList.innerHTML = '<div class="gantt-empty">No activities yet.<br>Click "+ Add" to create one.</div>';
  } else {
    tasks.forEach(task => {
      const row = document.createElement('div');
      row.className = 'gantt-activity-row';
      row.innerHTML = `
        <span class="status-dot status-dot-${task.status}"></span>
        <span class="gantt-activity-name">${esc(task.title)}</span>
        <span class="gantt-activity-meta">
          <span class="progress-label">${task.progress ?? 0}%</span>
        </span>`;
      row.addEventListener('click', () => openEditTaskModal(task));
      activityList.appendChild(row);
    });
  }

  // Chart
  const chartInner = document.getElementById('gantt-chart-inner');
  chartInner.style.width = totalWidth + 'px';

  let headerHTML = '<div class="gantt-header-row">';
  days.forEach(day => {
    const isToday   = day.toDateString() === today.toDateString();
    const isWeekend = day.getDay() === 0 || day.getDay() === 6;
    const cls = ['gantt-day-cell', isToday ? 'today-col' : '', isWeekend ? 'weekend-col' : ''].filter(Boolean).join(' ');
    headerHTML += `<div class="${cls}"><span>${DAY_NAMES[day.getDay()]}</span><span>${day.getDate()}</span></div>`;
  });
  headerHTML += '</div>';

  let bodyHTML = '<div class="gantt-body" id="gantt-body">';
  tasks.forEach(() => {
    bodyHTML += '<div class="gantt-row">';
    days.forEach(day => {
      const isToday   = day.toDateString() === today.toDateString();
      const isWeekend = day.getDay() === 0 || day.getDay() === 6;
      const cls = ['gantt-row-cell', isToday ? 'today-col' : '', isWeekend ? 'weekend-col' : ''].filter(Boolean).join(' ');
      bodyHTML += `<div class="${cls}"></div>`;
    });
    bodyHTML += '</div>';
  });
  bodyHTML += '</div>';

  chartInner.innerHTML = headerHTML + bodyHTML;
  const ganttBody = document.getElementById('gantt-body');

  tasks.forEach((task, index) => {
    const taskStart = task.start_date ? String(task.start_date).substring(0, 10)
      : (task.due_date ? task.due_date.substring(0, 10) : null);
    const taskEnd = task.due_date ? task.due_date.substring(0, 10)
      : (task.start_date ? String(task.start_date).substring(0, 10) : null);
    if (!taskStart && !taskEnd) return;

    const leftPx  = dayOffset(taskStart ?? taskEnd);
    const rightPx = dayOffset(taskEnd ?? taskStart) + DAY_W;
    const widthPx = Math.max(rightPx - leftPx, DAY_W);
    const topPx   = index * ROW_H + 7;
    const prog    = Math.min(100, Math.max(0, task.progress ?? 0));

    const bar = document.createElement('div');
    bar.className = `gantt-bar-wrapper bar-${task.status}`;
    bar.style.cssText = `left:${leftPx}px; width:${widthPx}px; top:${topPx}px;`;
    bar.innerHTML = `<div class="gantt-bar-bg"></div><div class="gantt-bar-fill" style="width:${prog}%"></div>`;
    ganttBody.appendChild(bar);
  });

  const todayLeft = dayOffset(today.toISOString().substring(0, 10));
  if (todayLeft !== null && todayLeft >= 0 && todayLeft <= totalWidth) {
    const marker = document.createElement('div');
    marker.className = 'gantt-today-marker';
    marker.style.cssText = `left:${todayLeft + DAY_W / 2}px;`;
    ganttBody.appendChild(marker);
  }

  const chartPanel = document.getElementById('gantt-chart-panel');
  let _syncLock = false;
  chartPanel.onscroll = () => {
    if (_syncLock) return;
    _syncLock = true;
    activityList.scrollTop = chartPanel.scrollTop;
    _syncLock = false;
  };
  activityList.onscroll = () => {
    if (_syncLock) return;
    _syncLock = true;
    chartPanel.scrollTop = activityList.scrollTop;
    _syncLock = false;
  };
}

// ── Project modal ─────────────────────────────────────────────
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
    form.elements.name.value        = p.name;
    form.elements.description.value = p.description ?? '';
    form.elements.start_date.value  = p.start_date ?? '';
    form.elements.end_date.value    = p.end_date   ?? '';
    document.getElementById('modal-project').classList.remove('hidden');
  } catch (e) { showError(e.message); }
}

async function submitProjectForm(e) {
  e.preventDefault();
  const form = e.target;
  const data = {
    name:        form.elements.name.value.trim(),
    description: form.elements.description.value.trim() || null,
    start_date:  form.elements.start_date.value || null,
    end_date:    form.elements.end_date.value   || null,
  };
  try {
    if (editingProjectId) {
      const updated = await api.projects.update(editingProjectId, data);
      currentProject = updated;
      closeModal('modal-project');
      await renderProjects();
      document.getElementById('project-title').textContent = updated.name;
      if (currentTab === 'gantt') renderGantt();
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
    currentProject   = null;
    document.getElementById('project-board').classList.add('hidden');
    document.getElementById('no-project-msg').classList.remove('hidden');
    await renderProjects();
  } catch (e) { showError(e.message); }
}

// ── Task modal ────────────────────────────────────────────────
async function openNewTaskModal() {
  editingTaskId = null;
  document.getElementById('modal-task-title').textContent = 'New Task';
  document.getElementById('btn-delete-task').classList.add('hidden');
  document.getElementById('form-task').reset();
  document.getElementById('progress-display').textContent = '0%';
  await populateAssignees(null);
  document.getElementById('modal-task').classList.remove('hidden');
}

async function openEditTaskModal(task) {
  editingTaskId = task.id;
  document.getElementById('modal-task-title').textContent = 'Edit Task';
  document.getElementById('btn-delete-task').classList.remove('hidden');
  const form = document.getElementById('form-task');
  form.elements.title.value       = task.title;
  form.elements.description.value = task.description ?? '';
  form.elements.status.value      = task.status;
  form.elements.priority.value    = task.priority;
  form.elements.due_date.value    = task.due_date   ? task.due_date.substring(0, 10)           : '';
  form.elements.start_date.value  = task.start_date ? String(task.start_date).substring(0, 10) : '';
  const prog = task.progress ?? 0;
  form.elements.progress.value    = prog;
  document.getElementById('progress-display').textContent = `${prog}%`;
  await populateAssignees(task.assignee_id);
  document.getElementById('modal-task').classList.remove('hidden');
}

async function populateAssignees(selectedId) {
  const users = await fetchUsers();
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
  const form        = e.target;
  const dueDateVal  = form.elements.due_date.value;
  const startDateVal = form.elements.start_date.value;
  const assigneeVal = form.elements.assignee_id.value;
  const progressVal = form.elements.progress.value;

  const data = {
    title:       form.elements.title.value.trim(),
    description: form.elements.description.value.trim() || null,
    status:      form.elements.status.value,
    priority:    form.elements.priority.value,
    start_date:  startDateVal || null,
    due_date:    dueDateVal ? new Date(dueDateVal).toISOString() : null,
    progress:    parseInt(progressVal, 10) || 0,
    assignee_id: assigneeVal ? parseInt(assigneeVal, 10) : null,
  };

  try {
    if (editingTaskId) {
      await api.tasks.update(editingTaskId, data);
    } else {
      await api.tasks.create({ ...data, project_id: currentProjectId });
    }
    closeModal('modal-task');
    if (currentTab === 'gantt') await renderGantt();
    else await renderTasks();
  } catch (e) { showError(e.message); }
}

async function deleteCurrentTask() {
  if (!editingTaskId) return;
  if (!confirm('Delete this task?')) return;
  try {
    await api.tasks.delete(editingTaskId);
    closeModal('modal-task');
    if (currentTab === 'gantt') await renderGantt();
    else await renderTasks();
  } catch (e) { showError(e.message); }
}

// ── Users modal ───────────────────────────────────────────────
async function openUsersModal() {
  await renderUserList();
  document.getElementById('form-user').reset();
  document.getElementById('modal-users').classList.remove('hidden');
}

async function renderUserList() {
  const users = await fetchUsers();
  const list  = document.getElementById('user-list');
  list.innerHTML = '';
  users.forEach(u => {
    const li = document.createElement('li');
    li.innerHTML = `
      ${makeAvatar(u, 'avatar-lg')}
      <div class="user-info">
        <span class="user-name">${esc(u.name)}</span>
        <span class="user-email">${esc(u.email)}</span>
      </div>`;
    list.appendChild(li);
  });
}

async function submitUserForm(e) {
  e.preventDefault();
  const form = e.target;
  try {
    await api.users.create({
      name:  form.elements.name.value.trim(),
      email: form.elements.email.value.trim(),
    });
    invalidateUsers();
    form.reset();
    await renderUserList();
    showToast('Team member added', 'success');
  } catch (e) { showError(e.message); }
}

// ── Utilities ─────────────────────────────────────────────────
function closeModal(id)   { document.getElementById(id).classList.add('hidden'); }
function closeAllModals() { document.querySelectorAll('.modal').forEach(m => m.classList.add('hidden')); }

// ── Bootstrap ─────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', async () => {
  initDarkMode();
  await renderProjects();

  // Dark mode toggle
  document.getElementById('btn-dark-mode').addEventListener('click', () => {
    const current = document.documentElement.getAttribute('data-theme');
    setTheme(current === 'dark' ? 'light' : 'dark');
  });

  // Tab bar
  document.querySelectorAll('.tab-btn').forEach(btn =>
    btn.addEventListener('click', () => switchTab(btn.dataset.tab))
  );

  // Kanban drag-and-drop on columns (permanent targets)
  document.querySelectorAll('.column').forEach(col => {
    col.addEventListener('dragover',  onDragOver);
    col.addEventListener('dragleave', onDragLeave);
    col.addEventListener('drop',      onDrop);
  });

  // Progress range slider
  const rangeInput   = document.getElementById('progress-range');
  const rangeDisplay = document.getElementById('progress-display');
  rangeInput.addEventListener('input', () => {
    rangeDisplay.textContent = `${rangeInput.value}%`;
  });

  // Buttons
  document.getElementById('btn-new-project').addEventListener('click',    openNewProjectModal);
  document.getElementById('btn-edit-project').addEventListener('click',   openEditProjectModal);
  document.getElementById('btn-delete-project').addEventListener('click', deleteCurrentProject);
  document.getElementById('btn-new-task').addEventListener('click',       openNewTaskModal);
  document.getElementById('btn-add-activity').addEventListener('click',   openNewTaskModal);
  document.getElementById('btn-delete-task').addEventListener('click',    deleteCurrentTask);
  document.getElementById('btn-manage-users').addEventListener('click',   openUsersModal);

  // Forms
  document.getElementById('form-project').addEventListener('submit', submitProjectForm);
  document.getElementById('form-task').addEventListener('submit',    submitTaskForm);
  document.getElementById('form-user').addEventListener('submit',    submitUserForm);

  // Cancel / close
  document.querySelectorAll('.btn-cancel').forEach(btn =>
    btn.addEventListener('click', closeAllModals)
  );

  // Click-outside-to-close
  document.querySelectorAll('.modal').forEach(modal =>
    modal.addEventListener('click', e => { if (e.target === modal) closeAllModals(); })
  );

  // ESC key
  document.addEventListener('keydown', e => { if (e.key === 'Escape') closeAllModals(); });
});
