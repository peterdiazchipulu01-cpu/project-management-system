# Project Management System

A full-stack web application for managing projects and tasks, built with Python + FastAPI and a plain HTML/CSS/JS frontend.

## Features

- **Projects** — create, rename, and delete projects
- **Tasks** — add tasks with title, description, status, priority, due date, and assignee
- **Kanban board** — drag-free three-column view (To Do / In Progress / Done)
- **Team members** — add users and assign them to tasks

## Setup

### Requirements

- Python 3.9+

### Install dependencies

```bash
cd backend
pip install -r requirements.txt
```

### Run the server

```bash
cd backend
uvicorn app.main:app --reload --port 8000
```

Then open **http://localhost:8000** in your browser.

Interactive API docs are available at **http://localhost:8000/docs**.

## Project Structure

```
.
├── backend/
│   ├── app/
│   │   ├── main.py        # FastAPI app entry point
│   │   ├── database.py    # SQLAlchemy + SQLite setup
│   │   ├── enums.py       # Shared TaskStatus / TaskPriority enums
│   │   ├── models/        # ORM models (User, Project, Task)
│   │   ├── schemas/       # Pydantic request/response schemas
│   │   ├── crud/          # Database operations
│   │   └── routers/       # API route handlers
│   └── requirements.txt
├── frontend/
│   ├── index.html         # Single-page UI
│   ├── style.css          # Styles
│   └── app.js             # Frontend logic
└── README.md
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | /api/projects/ | List all projects |
| POST | /api/projects/ | Create project |
| PUT | /api/projects/{id} | Update project |
| DELETE | /api/projects/{id} | Delete project (cascades tasks) |
| GET | /api/tasks/?project_id=N | List tasks (optionally filter by project) |
| POST | /api/tasks/ | Create task |
| PUT | /api/tasks/{id} | Update task |
| DELETE | /api/tasks/{id} | Delete task |
| GET | /api/users/ | List team members |
| POST | /api/users/ | Add team member |
