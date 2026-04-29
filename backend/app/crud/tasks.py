from sqlalchemy.orm import Session, joinedload
from typing import Optional
from ..models.task import Task
from ..schemas.task import TaskCreate, TaskUpdate


def _add_assignee_name(task):
    """Add assignee_name to task object for response"""
    task.assignee_name = task.assignee.name if task.assignee else None
    return task


def get_tasks(db: Session, project_id: Optional[int] = None):
    query = db.query(Task).options(joinedload(Task.assignee))
    if project_id is not None:
        query = query.filter(Task.project_id == project_id)
    return [_add_assignee_name(t) for t in query.all()]


def get_task(db: Session, task_id: int):
    task = db.query(Task).options(joinedload(Task.assignee)).filter(Task.id == task_id).first()
    return _add_assignee_name(task) if task else None


def create_task(db: Session, task: TaskCreate):
    db_task = Task(**task.model_dump())
    db.add(db_task)
    db.commit()
    db.refresh(db_task, ["assignee"])
    return _add_assignee_name(db_task)


def update_task(db: Session, task_id: int, task: TaskUpdate):
    db_task = db.query(Task).filter(Task.id == task_id).first()
    if not db_task:
        return None
    for field, value in task.model_dump(exclude_unset=True).items():
        setattr(db_task, field, value)
    db.commit()
    db.refresh(db_task, ["assignee"])
    return _add_assignee_name(db_task)


def delete_task(db: Session, task_id: int):
    db_task = get_task(db, task_id)
    if not db_task:
        return False
    db.delete(db_task)
    db.commit()
    return True
