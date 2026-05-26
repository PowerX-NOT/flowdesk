#!/usr/bin/env python3
"""
Initialize database schema via Alembic and optionally seed an admin user.

Usage (from backend/):
  python scripts/init_db.py
  python scripts/init_db.py --seed-admin --email admin@example.com --password 'SecurePass1'
"""
from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

# backend/ root
BACKEND_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BACKEND_ROOT))


def run_migrations() -> None:
    print("Running Alembic migrations...")
    result = subprocess.run(
        ["alembic", "upgrade", "head"],
        cwd=BACKEND_ROOT,
        check=False,
    )
    if result.returncode != 0:
        sys.exit(result.returncode)
    print("Migrations complete.")


def seed_admin(email: str, password: str, name: str) -> None:
    from app.core.security import hash_password
    from app.db.database import SessionLocal
    from app.models.user import User, UserRole

    db = SessionLocal()
    try:
        existing = db.query(User).filter(User.email == email).first()
        if existing:
            print(f"Admin user already exists: {email}")
            return
        user = User(
            name=name,
            email=email,
            hashed_password=hash_password(password),
            role=UserRole.ADMIN,
            is_active=True,
        )
        db.add(user)
        db.commit()
        print(f"Admin user created: {email}")
    finally:
        db.close()


def main() -> None:
    parser = argparse.ArgumentParser(description="Initialize FlowDesk database")
    parser.add_argument("--seed-admin", action="store_true")
    parser.add_argument("--email", default="admin@flowdesk.app")
    parser.add_argument("--password", default="")
    parser.add_argument("--name", default="FlowDesk Admin")
    args = parser.parse_args()

    run_migrations()

    if args.seed_admin:
        if not args.password:
            print("Error: --password required when using --seed-admin")
            sys.exit(1)
        seed_admin(args.email, args.password, args.name)


if __name__ == "__main__":
    main()
