import enum
from datetime import datetime, timezone

from sqlalchemy import String, Text, Enum, DateTime, ForeignKey, Date
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.database import Base


def _enum_values(enum_cls: type[enum.Enum]) -> list[str]:
    return [member.value for member in enum_cls]


class TaskPriority(str, enum.Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"


class TaskStatus(str, enum.Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"


class Task(Base):
    __tablename__ = "tasks"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    priority: Mapped[TaskPriority] = mapped_column(
        Enum(TaskPriority, values_callable=_enum_values),
        default=TaskPriority.MEDIUM,
        nullable=False,
    )
    status: Mapped[TaskStatus] = mapped_column(
        Enum(TaskStatus, values_callable=_enum_values),
        default=TaskStatus.PENDING,
        nullable=False,
    )
    due_date: Mapped[datetime | None] = mapped_column(Date, nullable=True)

    # Foreign key — enforces ownership; validated on every request server-side
    owner_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    owner: Mapped["User"] = relationship("User", backref="tasks")  # type: ignore

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False,
    )
