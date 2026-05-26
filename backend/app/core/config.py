import secrets
import logging
import os
from pathlib import Path
from pydantic_settings import BaseSettings
from pydantic import field_validator

logger = logging.getLogger(__name__)


def _resolve_jwt_secret() -> str:
    """
    Multi-tiered secret resolution:
    1. Environment variable JWT_SECRET_KEY
    2. Local jwt_secret.txt file (gitignored)
    3. Ephemeral random key (logs severe warning — not suitable for multi-instance)
    """
    # Tier 1: Environment variable
    env_secret = os.environ.get("JWT_SECRET_KEY", "").strip()
    if env_secret:
        return env_secret

    # Tier 2: Local file (gitignored, for dev convenience)
    secret_file = Path("jwt_secret.txt")
    if secret_file.exists():
        file_secret = secret_file.read_text().strip()
        if file_secret:
            return file_secret

    # Tier 3: Ephemeral random key — WARN: sessions won't survive restarts
    ephemeral = secrets.token_hex(32)
    logger.critical(
        "JWT_SECRET_KEY not set in environment or jwt_secret.txt. "
        "Generated an ephemeral key. This instance is ISOLATED — "
        "tokens will be invalid after restart and across multiple instances. "
        "Set JWT_SECRET_KEY environment variable for production."
    )
    return ephemeral


class Settings(BaseSettings):
    # Database
    DATABASE_URL: str

    # JWT
    JWT_SECRET_KEY: str = ""
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # CORS
    ALLOWED_ORIGINS: str = "http://localhost:3000"

    # App
    APP_ENV: str = "development"

    @field_validator("JWT_ALGORITHM")
    @classmethod
    def validate_algorithm(cls, v: str) -> str:
        # MUST reject 'none' algorithm — security requirement
        allowed = {"HS256", "HS384", "HS512"}
        if v not in allowed:
            raise ValueError(f"JWT_ALGORITHM must be one of {allowed}. Got: {v}")
        return v

    def get_allowed_origins(self) -> list[str]:
        return [o.strip() for o in self.ALLOWED_ORIGINS.split(",") if o.strip()]

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        extra = "ignore"


def get_settings() -> Settings:
    settings = Settings()  # type: ignore[call-arg]
    # Override JWT secret with multi-tiered resolution if not set
    if not settings.JWT_SECRET_KEY:
        object.__setattr__(settings, "JWT_SECRET_KEY", _resolve_jwt_secret())
    return settings


settings = get_settings()
