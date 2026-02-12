"""Database configuration for Jeeth.ai"""
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os

# Database URL from environment or default
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://jeethhypno_user:jeeth2025@localhost:5432/jeethhypno"
)

# Create engine
engine = create_engine(DATABASE_URL)

# Create session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    """Dependency for FastAPI to get database session."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
