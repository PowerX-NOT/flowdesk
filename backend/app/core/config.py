import logging
import os
import secrets
from pathlib import Path
from urllib.parse import parse_qs, urlencode, urlparse, urlunparse

from pydantic import field_validator, model_validator
from pydantic_settings import BaseSettings

logger = logging.getLogger(__name__)

# Algorithms allowed for JWT — rejects "none" and unexpected values
_ALLOWED_JWT_ALGORITHMS = frozenset({"HS256", "HS384", "HS512"})


def _resolve_jwt_secret(app_env: str) -> str:
    """
    Multi-tiered secret resolution:
    1. Environment variable JWT_SECRET_KEY
    2. Local jwt_secret.txt file (gitignored, development only)
    3. Ephemeral random key (development only — forbidden in production)
    """
    env_secret = os.environ.get("JWT_SECRET_KEY", "").strip()
    if env_secret:
        return env_secret

    if app_env == "production":
        raise ValueError(
            "JWT_SECRET_KEY is required when APP_ENV=production. "
            "Generate one with: python -c \"import secrets; print(secrets.token_hex(32))\""
        )

    secret_file = Path("jwt_secret.txt")
    if secret_file.exists():
        file_secret = secret_file.read_text().strip()
        if file_secret:
            return file_secret

    ephemeral = secrets.token_hex(32)
    logger.warning(
        "JWT_SECRET_KEY not set — using ephemeral dev key. "
        "Tokens will not survive restarts. Set JWT_SECRET_KEY for stable sessions."
    )
    return ephemeral


def normalize_database_url(url: str) -> str:
    """
    Normalize database URLs for SQLAlchemy + PyMySQL.
    Railway/PlanetScale often provide mysql:// — convert to mysql+pymysql://.
    """
    if url.startswith("mysql://"):
        url = url.replace("mysql://", "mysql+pymysql://", 1)
    elif url.startswith("mysql2://"):
        url = url.replace("mysql2://", "mysql+pymysql://", 1)
    return url


class Settings(BaseSettings):
    # Database
    DATABASE_URL: str
    DATABASE_SSL: bool = False
    DB_POOL_SIZE: int = 5
    DB_MAX_OVERFLOW: int = 10
    DB_POOL_TIMEOUT: int = 30
    DB_POOL_RECYCLE: int = 1800

    # JWT
    JWT_SECRET_KEY: str = ""
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # CORS — comma-separated origins (mobile apps typically omit Origin)
    ALLOWED_ORIGINS: str = ""

    # App
    APP_ENV: str = "development"
    LOG_LEVEL: str = "INFO"
    PORT: int = 8000

    # HTTPS behind reverse proxy (Railway, load balancers)
    TRUST_PROXY_HEADERS: bool = True
    TRUSTED_HOSTS: str = "*"

    @field_validator("JWT_ALGORITHM")
    @classmethod
    def validate_algorithm(cls, v: str) -> str:
        if v not in _ALLOWED_JWT_ALGORITHMS:
            raise ValueError(
                f"JWT_ALGORITHM must be one of {sorted(_ALLOWED_JWT_ALGORITHMS)}. Got: {v}"
            )
        return v

    @field_validator("DATABASE_URL")
    @classmethod
    def validate_database_url(cls, v: str) -> str:
        normalized = normalize_database_url(v.strip())
        if not normalized.startswith("mysql+pymysql://"):
            raise ValueError(
                "DATABASE_URL must use mysql+pymysql:// (or mysql:// which is auto-converted)."
            )
        return normalized

    @model_validator(mode="after")
    def validate_production_settings(self) -> "Settings":
        if self.is_production:
            if not self.JWT_SECRET_KEY:
                object.__setattr__(
                    self, "JWT_SECRET_KEY", _resolve_jwt_secret(self.APP_ENV)
                )
            elif len(self.JWT_SECRET_KEY) < 32:
                raise ValueError(
                    "JWT_SECRET_KEY must be at least 32 characters in production."
                )
            if not self.DATABASE_URL:
                raise ValueError("DATABASE_URL is required in production.")
        return self

    @property
    def is_production(self) -> bool:
        return self.APP_ENV.lower() == "production"

    @property
    def is_development(self) -> bool:
        return self.APP_ENV.lower() == "development"

    def get_allowed_origins(self) -> list[str]:
        if not self.ALLOWED_ORIGINS.strip():
            return []
        return [o.strip() for o in self.ALLOWED_ORIGINS.split(",") if o.strip()]

    def get_trusted_hosts(self) -> list[str]:
        hosts = [h.strip() for h in self.TRUSTED_HOSTS.split(",") if h.strip()]
        return hosts if hosts else ["*"]

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        extra = "ignore"


def get_settings() -> Settings:
    settings = Settings()  # type: ignore[call-arg]
    if not settings.JWT_SECRET_KEY:
        object.__setattr__(
            settings, "JWT_SECRET_KEY", _resolve_jwt_secret(settings.APP_ENV)
        )
    return settings


settings = get_settings()
