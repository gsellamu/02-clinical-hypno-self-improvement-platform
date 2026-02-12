"""
E&P Sexuality Database Schema
Stores extracted content from HMI E&P Sexuality workbooks
"""
from sqlalchemy import Column, Integer, String, Text, JSON, DateTime, Boolean, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime
import os

from dotenv import load_dotenv

load_dotenv()  # <-- This line was missing!

Base = declarative_base()

class EPWorkbookContent(Base):
    """Raw content extracted from E&P workbooks"""
    __tablename__ = 'ep_workbook_content'
    
    id = Column(Integer, primary_key=True)
    workbook_name = Column(String(255), nullable=False)
    page_number = Column(Integer, nullable=False)
    section_title = Column(String(500))
    content_type = Column(String(50))
    raw_text = Column(Text, nullable=False)
    extracted_at = Column(DateTime, default=datetime.utcnow)
    
class EPCoreTheory(Base):
    """Structured E&P core theory concepts"""
    __tablename__ = 'ep_core_theory'
    
    id = Column(Integer, primary_key=True)
    concept_name = Column(String(255), nullable=False, unique=True)
    category = Column(String(100))
    description = Column(Text, nullable=False)
    details = Column(JSON)
    workbook_source = Column(String(255))
    page_references = Column(JSON)
    created_at = Column(DateTime, default=datetime.utcnow)
    
class EPFourCoreTraits(Base):
    """The Four Core Traits of E&P Sexuality"""
    __tablename__ = 'ep_four_core_traits'
    
    id = Column(Integer, primary_key=True)
    trait_name = Column(String(100), nullable=False)
    physical_type = Column(Text)
    emotional_type = Column(Text)
    observable_behaviors = Column(JSON)
    assessment_indicators = Column(JSON)
    therapeutic_implications = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)

class EPRelationshipPatterns(Base):
    """E&P relationship patterns and dynamics"""
    __tablename__ = 'ep_relationship_patterns'
    
    id = Column(Integer, primary_key=True)
    pattern_name = Column(String(255), nullable=False)
    ep_combination = Column(String(50))
    description = Column(Text, nullable=False)
    strengths = Column(JSON)
    challenges = Column(JSON)
    therapeutic_approaches = Column(JSON)
    examples = Column(JSON)
    created_at = Column(DateTime, default=datetime.utcnow)

class EPAssessmentQuestions(Base):
    """E&P assessment questionnaire items"""
    __tablename__ = 'ep_assessment_questions'
    
    id = Column(Integer, primary_key=True)
    question_number = Column(Integer, nullable=False)
    question_text = Column(Text, nullable=False)
    trait_assessed = Column(String(100))
    scoring_key = Column(JSON)
    interpretation = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)

def get_db_engine():
    """Get database engine from environment or use default"""
    db_url = os.getenv('DATABASE_URL', 'postgresql://jeethhypno_user:jeeth2025@localhost:5432/jeethhypno')
    return create_engine(db_url, echo=False)

def init_database():
    """Initialize database tables"""
    engine = get_db_engine()
    Base.metadata.create_all(engine)
    return engine

def get_session():
    """Get database session"""
    engine = get_db_engine()
    Session = sessionmaker(bind=engine)
    return Session()

if __name__ == '__main__':
    print("Initializing E&P Sexuality database schema...")
    engine = init_database()
    print("Database schema created successfully!")
    print(f"   Tables created: {', '.join(Base.metadata.tables.keys())}")
