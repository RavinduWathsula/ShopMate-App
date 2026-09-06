import logging
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

try:
    from app.config.settings import settings
except ImportError:
    from backend.app.config.settings import settings

logger = logging.getLogger("shopmate.database")

def create_db_engine():
    db_url = settings.DB_URL
    if db_url.startswith("sqlite"):
        return create_engine(db_url, connect_args={"check_same_thread": False})
    elif db_url.startswith("mysql"):
        try:
            test_engine = create_engine(db_url, connect_args={"connect_timeout": 2})
            with test_engine.connect():
                logger.info("Successfully connected to MySQL database.")
            return test_engine
        except Exception as e:
            logger.warning(f"Unable to connect to MySQL ({e}). Falling back to local SQLite database.")
            return create_engine("sqlite:///./shopmate.db", connect_args={"check_same_thread": False})
    else:
        return create_engine(db_url)

engine = create_db_engine()
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
