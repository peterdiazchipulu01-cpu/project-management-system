from pydantic import BaseModel
from typing import Optional
from datetime import datetime, date


class ProjectBase(BaseModel):
    name: str
    description: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None


class ProjectCreate(ProjectBase):
    pass


class ProjectUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None


class ProjectResponse(ProjectBase):
    id: int
    created_at: datetime

    model_config = {"from_attributes": True}
