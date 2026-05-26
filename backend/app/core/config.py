from pydantic import field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

_ALLOWED_JWT_ALGORITHMS = frozenset({"HS256", "HS384", "HS512"})


def normalize_database_url(url: str) -> str:
    """Normalize mysql:// URLs from Railway/PlanetScale to mysql+pymysql://."""
    if url.startswith("mysql://"):
        url = url.replace("mysql://", "mysql+pymysql://", 1)
    elif url.startswith("mysql2://"):
        url = url.replace("mysql2://", "mysql+pymysql://", 1)
    return url


class Settings(BaseSettings):
    """Production settings — all values must come from the host environment (e.g. Railway)."""

    model_config = SettingsConfigDict(extra="ignore")

    DATABASE_URL: str
    DATABASE_SSL: bool = False
    DB_POOL_SIZE: int = 5
    DB_MAX_OVERFLOW: int = 10
    DB_POOL_TIMEOUT: int = 30
    DB_POOL_RECYCLE: int = 1800

    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    ALLOWED_ORIGINS: str = ""

    APP_ENV: str = "production"
    LOG_LEVEL: str = "INFO"
    PORT: int = 8000

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

    @field_validator("APP_ENV")
    @classmethod
    def validate_app_env(cls, v: str) -> str:
        if v.lower() != "production":
            raise ValueError("APP_ENV must be 'production'. Local deployment is not supported.")
        return "production"

    @model_validator(mode="after")
    def validate_secrets(self) -> "Settings":
        secret = self.JWT_SECRET_KEY.strip()
        if not secret:
            raise ValueError(
                "JWT_SECRET_KEY is required. "
                'Generate with: python -c "import secrets; print(secrets.token_hex(32))"'
            )
        if len(secret) < 32:
            raise ValueError("JWT_SECRET_KEY must be at least 32 characters.")
        return self

    def get_allowed_origins(self) -> list[str]:
        if not self.ALLOWED_ORIGINS.strip():
            return []
        return [o.strip() for o in self.ALLOWED_ORIGINS.split(",") if o.strip()]

    def get_trusted_hosts(self) -> list[str]:
        hosts = [h.strip() for h in self.TRUSTED_HOSTS.split(",") if h.strip()]
        return hosts if hosts else ["*"]


def get_settings() -> Settings:
    return Settings()  # type: ignore[call-arg]


settings = get_settings()
