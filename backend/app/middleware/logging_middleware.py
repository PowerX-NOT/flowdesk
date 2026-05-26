import logging
import time
import uuid

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response

logger = logging.getLogger("flowdesk.access")


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """Structured request/response logging for production observability."""

    async def dispatch(self, request: Request, call_next) -> Response:
        request_id = request.headers.get("X-Request-ID", str(uuid.uuid4())[:8])
        start = time.perf_counter()

        response = await call_next(request)

        duration_ms = (time.perf_counter() - start) * 1000
        response.headers["X-Request-ID"] = request_id

        # Skip noisy health-check logs unless they fail
        if request.url.path != "/health" or response.status_code >= 400:
            logger.info(
                "request_id=%s method=%s path=%s status=%s duration_ms=%.1f client=%s",
                request_id,
                request.method,
                request.url.path,
                response.status_code,
                duration_ms,
                request.client.host if request.client else "-",
            )

        return response
