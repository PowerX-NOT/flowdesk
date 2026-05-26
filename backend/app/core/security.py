from datetime import datetime, timedelta, timezone
from typing import Any

import bcrypt
from jose import JWTError, jwt

from app.core.config import settings

# bcrypt cost factor (12 is a good production default)
_BCRYPT_ROUNDS = 12


def hash_password(password: str) -> str:
    """Hash a plaintext password using bcrypt."""
    hashed = bcrypt.hashpw(
        password.encode("utf-8"),
        bcrypt.gensalt(rounds=_BCRYPT_ROUNDS),
    )
    return hashed.decode("utf-8")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a plaintext password against its bcrypt hash."""
    return bcrypt.checkpw(
        plain_password.encode("utf-8"),
        hashed_password.encode("utf-8"),
    )


def create_access_token(subject: Any, expires_delta: timedelta | None = None) -> str:
    """
    Create a JWT access token.
    - Algorithm is HARDCODED to settings.JWT_ALGORITHM (never derived from token)
    - 'exp' claim is always set — no infinite tokens
    """
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(
            minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )

    payload = {
        "sub": str(subject),
        "exp": expire,
        "iat": datetime.now(timezone.utc),
        "type": "access",
    }
    # Algorithm is hardcoded — MUST NOT derive from unverified token header
    return jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)


def create_refresh_token(subject: Any) -> str:
    """Create a longer-lived JWT refresh token."""
    expire = datetime.now(timezone.utc) + timedelta(
        days=settings.REFRESH_TOKEN_EXPIRE_DAYS
    )
    payload = {
        "sub": str(subject),
        "exp": expire,
        "iat": datetime.now(timezone.utc),
        "type": "refresh",
    }
    return jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)


def _decode_token(token: str, expected_type: str) -> dict:
    """
    Decode and validate a JWT.
    Algorithm is HARDCODED — rejects 'none' and any unexpected algorithm.
    """
    payload = jwt.decode(
        token,
        settings.JWT_SECRET_KEY,
        algorithms=[settings.JWT_ALGORITHM],
        options={
            "require_sub": True,
            "verify_exp": True,
            "verify_iat": True,
        },
    )
    if payload.get("type") != expected_type:
        raise JWTError("Invalid token type")
    return payload


def decode_access_token(token: str) -> dict:
    """Decode and validate a JWT access token."""
    try:
        return _decode_token(token, "access")
    except JWTError:
        raise


def decode_refresh_token(token: str) -> dict:
    """Decode and validate a JWT refresh token."""
    try:
        return _decode_token(token, "refresh")
    except JWTError:
        raise
