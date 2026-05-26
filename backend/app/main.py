import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from slowapi.util import get_remote_address

from app.api import auth, tasks, users
from app.core.config import settings
from app.db.database import Base, engine
from app.models import task, user  # noqa: F401 — import models for table creation

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)

# Rate limiter — apply to all routes
limiter = Limiter(key_func=get_remote_address, default_limits=["100/minute"])


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Create database tables on startup."""
    logger.info("Creating database tables if not exist...")
    Base.metadata.create_all(bind=engine)
    logger.info("Database ready.")
    yield
    logger.info("Application shutting down.")


app = FastAPI(
    title="Employee Task Management API",
    version="1.0.0",
    description="Secure REST API for employee task management",
    docs_url="/docs" if settings.APP_ENV == "development" else None,
    redoc_url="/redoc" if settings.APP_ENV == "development" else None,
    lifespan=lifespan,
)

# Rate limiting
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_middleware(SlowAPIMiddleware)

# CORS — strict allow-list, NO wildcard (*)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.get_allowed_origins(),
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],  # Allow-list, TRACE/PATCH excluded
    allow_headers=["Authorization", "Content-Type"],
)


# Security headers middleware
@app.middleware("http")
async def add_security_headers(request: Request, call_next):
    response = await call_next(request)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    response.headers["Content-Security-Policy"] = (
        "default-src 'self'; frame-ancestors 'none'; object-src 'none';"
    )
    response.headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=()"
    response.headers["Cache-Control"] = "no-store"
    return response


# Validation error handler — generic messages to client, no internal details
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    logger.warning("Validation error on %s: %s", request.url.path, str(exc))
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={"detail": "Invalid request data. Please check your input."},
    )


# Generic error handler — do NOT expose internal errors to client
@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    logger.exception("Unhandled error on %s", request.url.path)
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": "An internal error occurred. Please try again later."},
    )


# Include routers with versioned prefix
PREFIX = "/api/v1"
app.include_router(auth.router, prefix=PREFIX)
app.include_router(tasks.router, prefix=PREFIX)
app.include_router(users.router, prefix=PREFIX)


@app.get("/health", tags=["Health"])
def health_check() -> dict:
    """Health check endpoint — no sensitive data returned."""
    return {"status": "ok"}
