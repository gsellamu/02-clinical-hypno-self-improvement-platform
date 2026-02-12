"""
Epic 8, Feature 1, Story 1, Task 1: Design 4D Taxonomy Schema
Database Migration: Dimensional Taxonomy Tables

Dimensions:
- MIND: Cognitive, Mental, Emotional patterns
- BODY: Physical, Somatic, Health conditions  
- SOCIAL: Relationships, Communication, Interactions
- SPIRITUAL: Meaning, Purpose, Transcendence
"""

from sqlalchemy import (
    Column, Integer, String, Float, JSON, Boolean, 
    DateTime, ForeignKey, Index, CheckConstraint,
    UniqueConstraint, Enum as SQLEnum
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.dialects.postgresql import JSONB, ARRAY
from datetime import datetime
import enum

Base = declarative_base()


class DimensionType(enum.Enum):
    """Four primary dimensions of consciousness/therapeutic intervention"""
    MIND = "mind"
    BODY = "body"
    SOCIAL = "social"
    SPIRITUAL = "spiritual"


class Dimension(Base):
    """
    Master dimension table defining the 4D taxonomy structure
    """
    __tablename__ = "dimensions"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(SQLEnum(DimensionType), unique=True, nullable=False)
    display_name = Column(String(50), nullable=False)
    description = Column(String(500), nullable=False)
    icon = Column(String(50))  # Icon identifier for UI
    color = Column(String(7))  # Hex color code
    default_weight = Column(Float, default=0.25, nullable=False)
    
    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    __table_args__ = (
        CheckConstraint('default_weight >= 0 AND default_weight <= 1', name='check_weight_range'),
        Index('idx_dimension_name', 'name'),
    )


class DimensionCategory(Base):
    """
    Sub-categories within each dimension for finer-grained taxonomy
    
    Examples:
    - MIND: Anxiety, Depression, Trauma, Cognitive
    - BODY: Pain, Sleep, Autoimmune, Chronic Illness
    - SOCIAL: Relationships, Communication, Work, Family
    - SPIRITUAL: Meaning, Purpose, Transcendence, Growth
    """
    __tablename__ = "dimension_categories"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    dimension_id = Column(Integer, ForeignKey('dimensions.id', ondelete='CASCADE'), nullable=False)
    name = Column(String(100), nullable=False)
    slug = Column(String(100), nullable=False)
    description = Column(String(500))
    parent_category_id = Column(Integer, ForeignKey('dimension_categories.id', ondelete='SET NULL'))
    
    # Hierarchical depth (0 = top level, 1 = second level, etc.)
    level = Column(Integer, default=0, nullable=False)
    
    # Display order within dimension
    sort_order = Column(Integer, default=0)
    
    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    __table_args__ = (
        UniqueConstraint('dimension_id', 'slug', name='uq_dimension_category_slug'),
        Index('idx_dimension_category', 'dimension_id', 'slug'),
        Index('idx_category_parent', 'parent_category_id'),
    )


class ConditionDimensionScore(Base):
    """
    Stores dimensional scores for each therapeutic condition
    
    Each condition gets scored 0-1 on each of the 4 dimensions
    Scores represent how much the condition relates to each dimension
    """
    __tablename__ = "condition_dimension_scores"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    condition_id = Column(Integer, nullable=False)  # FK to conditions table
    dimension_id = Column(Integer, ForeignKey('dimensions.id', ondelete='CASCADE'), nullable=False)
    
    # Primary score (0.0 to 1.0) - how relevant is this dimension?
    score = Column(Float, nullable=False)
    
    # Confidence level (0.0 to 1.0) - how confident are we in this score?
    confidence = Column(Float, default=0.8, nullable=False)
    
    # Detailed sub-scores by category
    category_scores = Column(JSONB, default={})  # {category_id: score}
    
    # Metadata about scoring
    scoring_method = Column(String(50))  # 'manual', 'ai_generated', 'collaborative'
    scored_by = Column(String(100))  # User ID or 'system'
    scoring_notes = Column(String(500))
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    __table_args__ = (
        UniqueConstraint('condition_id', 'dimension_id', name='uq_condition_dimension'),
        CheckConstraint('score >= 0 AND score <= 1', name='check_score_range'),
        CheckConstraint('confidence >= 0 AND confidence <= 1', name='check_confidence_range'),
        Index('idx_condition_dimension', 'condition_id', 'dimension_id'),
        Index('idx_dimension_score', 'dimension_id', 'score'),
    )


class UserDimensionPreference(Base):
    """
    User-specific dimensional preferences and weights
    
    Allows personalization of search/recommendation based on:
    - User's primary concerns (which dimensions matter most?)
    - Historical effectiveness (which dimensions worked best?)
    - Personal values and priorities
    """
    __tablename__ = "user_dimension_preferences"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String(100), nullable=False)
    dimension_id = Column(Integer, ForeignKey('dimensions.id', ondelete='CASCADE'), nullable=False)
    
    # User's preference weight for this dimension (0.0 to 1.0)
    # Sum of all weights for a user should = 1.0
    weight = Column(Float, nullable=False)
    
    # Explicit vs implicit preference
    is_explicit = Column(Boolean, default=False)  # True if user set it, False if inferred
    
    # Historical effectiveness for this user
    effectiveness_score = Column(Float)  # Based on past outcomes
    
    # Preference metadata
    preference_reason = Column(String(200))  # Why this weight? "User selected", "Based on history", etc.
    last_adjusted = Column(DateTime, default=datetime.utcnow)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    __table_args__ = (
        UniqueConstraint('user_id', 'dimension_id', name='uq_user_dimension'),
        CheckConstraint('weight >= 0 AND weight <= 1', name='check_weight_range'),
        Index('idx_user_preference', 'user_id', 'dimension_id'),
    )


class DimensionTag(Base):
    """
    Free-form tags that can be associated with dimensions/categories
    Used for flexible categorization and search
    """
    __tablename__ = "dimension_tags"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    dimension_id = Column(Integer, ForeignKey('dimensions.id', ondelete='CASCADE'))
    category_id = Column(Integer, ForeignKey('dimension_categories.id', ondelete='CASCADE'))
    
    tag = Column(String(50), nullable=False)
    tag_type = Column(String(30))  # 'symptom', 'protocol', 'modality', 'population', etc.
    
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    __table_args__ = (
        Index('idx_tag', 'tag'),
        Index('idx_tag_type', 'tag_type'),
    )


# ============================================================================
# SEED DATA - Initial 4D Taxonomy
# ============================================================================

DIMENSION_SEED_DATA = [
    {
        "name": "MIND",
        "display_name": "Mind",
        "description": "Cognitive, mental, emotional patterns and psychological well-being",
        "icon": "brain",
        "color": "#6366F1",  # Indigo
        "default_weight": 0.25
    },
    {
        "name": "BODY",
        "display_name": "Body", 
        "description": "Physical, somatic sensations, health conditions, and bodily experiences",
        "icon": "heart-pulse",
        "color": "#EF4444",  # Red
        "default_weight": 0.25
    },
    {
        "name": "SOCIAL",
        "display_name": "Social",
        "description": "Relationships, communication, interactions, and social connections",
        "icon": "users",
        "color": "#10B981",  # Green
        "default_weight": 0.25
    },
    {
        "name": "SPIRITUAL",
        "display_name": "Spiritual",
        "description": "Meaning, purpose, transcendence, and connection to something greater",
        "icon": "sparkles",
        "color": "#8B5CF6",  # Purple
        "default_weight": 0.25
    }
]

CATEGORY_SEED_DATA = {
    "MIND": [
        # Top-level categories (level 0)
        {"name": "Anxiety Disorders", "slug": "anxiety", "level": 0, "sort_order": 1},
        {"name": "Depressive Disorders", "slug": "depression", "level": 0, "sort_order": 2},
        {"name": "Trauma & PTSD", "slug": "trauma", "level": 0, "sort_order": 3},
        {"name": "OCD & Related", "slug": "ocd", "level": 0, "sort_order": 4},
        {"name": "ADHD & Focus", "slug": "adhd", "level": 0, "sort_order": 5},
        {"name": "Eating Disorders", "slug": "eating", "level": 0, "sort_order": 6},
        {"name": "Addiction & Habits", "slug": "addiction", "level": 0, "sort_order": 7},
        {"name": "Mood Disorders", "slug": "mood", "level": 0, "sort_order": 8},
        {"name": "Cognitive Function", "slug": "cognitive", "level": 0, "sort_order": 9},
        {"name": "Emotional Regulation", "slug": "emotional", "level": 0, "sort_order": 10},
    ],
    "BODY": [
        {"name": "Chronic Pain", "slug": "pain", "level": 0, "sort_order": 1},
        {"name": "Sleep Disorders", "slug": "sleep", "level": 0, "sort_order": 2},
        {"name": "Autoimmune Conditions", "slug": "autoimmune", "level": 0, "sort_order": 3},
        {"name": "Digestive Issues", "slug": "digestive", "level": 0, "sort_order": 4},
        {"name": "Chronic Illness", "slug": "chronic-illness", "level": 0, "sort_order": 5},
        {"name": "Medical Procedures", "slug": "medical", "level": 0, "sort_order": 6},
        {"name": "Physical Performance", "slug": "performance", "level": 0, "sort_order": 7},
        {"name": "Somatic Symptoms", "slug": "somatic", "level": 0, "sort_order": 8},
        {"name": "Weight Management", "slug": "weight", "level": 0, "sort_order": 9},
        {"name": "Sexual Health", "slug": "sexual", "level": 0, "sort_order": 10},
    ],
    "SOCIAL": [
        {"name": "Relationship Issues", "slug": "relationships", "level": 0, "sort_order": 1},
        {"name": "Communication Skills", "slug": "communication", "level": 0, "sort_order": 2},
        {"name": "Social Anxiety", "slug": "social-anxiety", "level": 0, "sort_order": 3},
        {"name": "Workplace Stress", "slug": "workplace", "level": 0, "sort_order": 4},
        {"name": "Family Dynamics", "slug": "family", "level": 0, "sort_order": 5},
        {"name": "Conflict Resolution", "slug": "conflict", "level": 0, "sort_order": 6},
        {"name": "Assertiveness", "slug": "assertiveness", "level": 0, "sort_order": 7},
        {"name": "Public Speaking", "slug": "public-speaking", "level": 0, "sort_order": 8},
        {"name": "Social Skills", "slug": "social-skills", "level": 0, "sort_order": 9},
        {"name": "Boundaries", "slug": "boundaries", "level": 0, "sort_order": 10},
    ],
    "SPIRITUAL": [
        {"name": "Meaning & Purpose", "slug": "meaning", "level": 0, "sort_order": 1},
        {"name": "Life Transitions", "slug": "transitions", "level": 0, "sort_order": 2},
        {"name": "Grief & Loss", "slug": "grief", "level": 0, "sort_order": 3},
        {"name": "Existential Concerns", "slug": "existential", "level": 0, "sort_order": 4},
        {"name": "Meditation & Mindfulness", "slug": "meditation", "level": 0, "sort_order": 5},
        {"name": "Spiritual Crisis", "slug": "spiritual-crisis", "level": 0, "sort_order": 6},
        {"name": "Self-Actualization", "slug": "self-actualization", "level": 0, "sort_order": 7},
        {"name": "Consciousness Expansion", "slug": "consciousness", "level": 0, "sort_order": 8},
        {"name": "Shadow Work", "slug": "shadow", "level": 0, "sort_order": 9},
        {"name": "Integration", "slug": "integration", "level": 0, "sort_order": 10},
    ]
}


# ============================================================================
# MIGRATION SCRIPT
# ============================================================================

async def upgrade(connection):
    """Create dimensional taxonomy tables and seed initial data"""
    
    # Create tables
    await connection.run_sync(Base.metadata.create_all)
    
    print("✓ Dimensional taxonomy tables created")
    
    # Seed dimensions
    from sqlalchemy import insert
    
    for dim_data in DIMENSION_SEED_DATA:
        await connection.execute(
            insert(Dimension).values(**dim_data)
        )
    
    print("✓ Seeded 4 dimensions")
    
    # Seed categories
    for dim_name, categories in CATEGORY_SEED_DATA.items():
        # Get dimension ID
        result = await connection.execute(
            "SELECT id FROM dimensions WHERE name = :name",
            {"name": dim_name}
        )
        dimension_id = result.scalar()
        
        for cat_data in categories:
            cat_data['dimension_id'] = dimension_id
            await connection.execute(
                insert(DimensionCategory).values(**cat_data)
            )
    
    print("✓ Seeded 40 categories (10 per dimension)")
    print("✓ Migration complete!")


async def downgrade(connection):
    """Drop dimensional taxonomy tables"""
    await connection.run_sync(Base.metadata.drop_all)
    print("✓ Dimensional taxonomy tables dropped")


if __name__ == "__main__":
    import asyncio
    from sqlalchemy.ext.asyncio import create_async_engine
    import os
    from dotenv import load_dotenv
    
    load_dotenv()
    
    engine = create_async_engine(os.getenv("DATABASE_URL"))
    
    async def run_migration():
        async with engine.begin() as conn:
            await upgrade(conn)
    
    asyncio.run(run_migration())
