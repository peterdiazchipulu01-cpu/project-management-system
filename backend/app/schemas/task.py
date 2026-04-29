from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime, date
from ..enums import TaskStatus, TaskPriority


class TaskBase(BaseModel):
    title: str
    description: Optional[str] = None
    status: TaskStatus = TaskStatus.todo
    priority: TaskPriority = TaskPriority.medium
    start_date: Optional[date] = None
    due_date: Optional[datetime] = None
    progress: int = Field(default=0, ge=0, le=100)
    project_id: int
    assignee_id: Optional[int] = None


class TaskCreate(TaskBase):
    pass


class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    status: Optional[TaskStatus] = None
    priority: Optional[TaskPriority] = None
    start_date: Optional[date] = None
    due_date: Optional[datetime] = None
    progress: Optional[int] = Field(default=None, ge=0, le=100)
    assignee_id: Optional[int] = None


class TaskResponse(TaskBase):
    id: int
    created_at: datetime

    model_config = {"from_attributes": True}
