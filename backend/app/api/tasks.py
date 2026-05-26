import logging
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.models.task import Task, TaskStatus
from app.models.user import User
from app.schemas.task import TaskCreate, TaskResponse, TaskUpdate

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/tasks", tags=["Tasks"])


def _get_task_owned_by_user(task_id: int, user_id: int, db: Session) -> Task:
    """
    Fetch a task, validating ownership server-side.
    MUST be called on every task access to prevent IDOR attacks.
    """
    # ORM query — parameterized, no raw SQL
    task = db.query(Task).filter(
        Task.id == task_id,
        Task.owner_id == user_id,  # Ownership enforced at query level
    ).first()

    if not task:
        # Return 404 for both "not found" and "not owned" — prevents enumeration
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Task not found.",
        )
    return task


@router.get("/", response_model=list[TaskResponse])
def list_tasks(
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
    status_filter: Optional[TaskStatus] = Query(None, alias="status"),
    search: Optional[str] = Query(None, max_length=200),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
) -> list[Task]:
    """List tasks belonging to the authenticated user with optional filters."""
    query = db.query(Task).filter(Task.owner_id == current_user.id)

    if status_filter:
        query = query.filter(Task.status == status_filter)

    if search:
        # ORM LIKE — parameterized, safe from SQL injection
        search_term = f"%{search.strip()}%"
        query = query.filter(Task.title.ilike(search_term))

    return query.order_by(Task.created_at.desc()).offset(skip).limit(limit).all()


@router.post("/", response_model=TaskResponse, status_code=status.HTTP_201_CREATED)
def create_task(
    payload: TaskCreate,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> Task:
    """Create a new task for the authenticated user."""
    task = Task(
        **payload.model_dump(),
        owner_id=current_user.id,  # Owner set from authenticated user — not from payload
    )
    db.add(task)
    db.commit()
    db.refresh(task)
    logger.info("Task created: id=%d by user_id=%d", task.id, current_user.id)
    return task


@router.get("/{task_id}", response_model=TaskResponse)
def get_task(
    task_id: int,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> Task:
    """Get a single task — ownership validated server-side."""
    return _get_task_owned_by_user(task_id, current_user.id, db)


@router.put("/{task_id}", response_model=TaskResponse)
def update_task(
    task_id: int,
    payload: TaskUpdate,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> Task:
    """Update a task — ownership validated server-side."""
    task = _get_task_owned_by_user(task_id, current_user.id, db)

    update_data = payload.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(task, field, value)

    db.commit()
    db.refresh(task)
    logger.info("Task updated: id=%d by user_id=%d", task.id, current_user.id)
    return task


@router.delete("/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_task(
    task_id: int,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> None:
    """Delete a task — ownership validated server-side."""
    task = _get_task_owned_by_user(task_id, current_user.id, db)
    db.delete(task)
    db.commit()
    logger.info("Task deleted: id=%d by user_id=%d", task_id, current_user.id)
