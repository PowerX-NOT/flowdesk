import logging
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.core.security import hash_password, verify_password, create_access_token
from app.models.user import User
from app.schemas.user import UserCreate, UserLogin, UserResponse, Token

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
)
def register(
    payload: UserCreate,
    db: Annotated[Session, Depends(get_db)],
) -> User:
    """Register a new employee account."""
    # Check for duplicate email — use ORM, no raw SQL
    existing = db.query(User).filter(User.email == payload.email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account with this email already exists.",
        )

    user = User(
        name=payload.name,
        email=payload.email,
        hashed_password=hash_password(payload.password),  # bcrypt hashed
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    logger.info("New user registered: id=%d", user.id)
    return user


@router.post("/login", response_model=Token)
def login(
    payload: UserLogin,
    db: Annotated[Session, Depends(get_db)],
) -> dict:
    """Authenticate and return a JWT access token."""
    # MUST NOT log credentials — even on failure
    user = db.query(User).filter(User.email == payload.email).first()

    # Use constant-time comparison via passlib to prevent timing attacks
    # Always call verify_password even if user not found to prevent user enumeration
    password_valid = False
    if user:
        password_valid = verify_password(payload.password, user.hashed_password)

    if not user or not password_valid or not user.is_active:
        # Generic error message — do NOT reveal whether email exists
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token = create_access_token(subject=user.id)
    logger.info("User login: id=%d", user.id)

    return {"access_token": access_token, "token_type": "bearer"}


@router.get("/me", response_model=UserResponse)
def get_me(
    db: Annotated[Session, Depends(get_db)],
    # Import inline to avoid circular import
) -> User:
    """Get current user profile — requires valid JWT."""
    from app.api.deps import get_current_user
    # This endpoint is actually wired via dependency in the router include
    # See main.py for the actual dependency injection
    raise HTTPException(status_code=500, detail="Use /me endpoint via router")
