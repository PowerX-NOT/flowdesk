import logging
from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError
from sqlalchemy.orm import Session

from app.core.security import decode_access_token
from app.db.database import get_db
from app.models.user import User, UserRole

logger = logging.getLogger(__name__)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    db: Annotated[Session, Depends(get_db)],
) -> User:
    """
    Validate JWT and return the authenticated user.
    Authentication is performed SERVER-SIDE — client data is never trusted.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = decode_access_token(token)
        user_id_str: str = payload.get("sub", "")
        if not user_id_str:
            raise credentials_exception
        user_id = int(user_id_str)
    except (JWTError, ValueError):
        # Do NOT log the token — it is a credential
        logger.warning("JWT validation failed")
        raise credentials_exception

    # Always fetch user fresh from DB — do NOT trust token claims beyond sub
    user = db.get(User, user_id)
    if user is None or not user.is_active:
        raise credentials_exception

    return user


def get_current_admin(
    current_user: Annotated[User, Depends(get_current_user)],
) -> User:
    """Require admin role — fail closed if not admin."""
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required",
        )
    return current_user
