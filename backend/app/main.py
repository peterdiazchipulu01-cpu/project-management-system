from pathlib import Path
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from .database import engine, Base
from . import models  # noqa: F401 — ensures all models are registered before create_all
from .routers import projects, tasks, users

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Project Management System")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(projects.router)
app.include_router(tasks.router)
app.include_router(users.router)

FRONTEND_DIR = Path(__file__).parent.parent.parent / "frontend"
app.mount("/static", StaticFiles(directory=str(FRONTEND_DIR)), name="static")


@app.get("/")
def serve_index():
    return FileResponse(str(FRONTEND_DIR / "index.html"))
