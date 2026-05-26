import logging
from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_current_admin, get_current_user, get_db
from app.models.user import User
from app.schemas.user import UserResponse

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/me", response_model=UserResponse)
def get_my_profile(
    current_user: Annotated[User, Depends(get_current_user)],
) -> User:
    """Get current authenticated user's profile."""
    return current_user


@router.get("/", response_model=list[UserResponse])
def list_all_users(
    db: Annotated[Session, Depends(get_db)],
    _admin: Annotated[User, Depends(get_current_admin)],  # Admin-only
    skip: int = 0,
    limit: int = 100,
) -> list[User]:
    """List all users — ADMIN ONLY. RBAC enforced via dependency."""
    return db.query(User).offset(skip).limit(limit).all()
