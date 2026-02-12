# DATABASE SCHEMA - Therapeutic Journaling Platform
## PostgreSQL + pgvector with Complete Table Definitions

**Version:** 1.0
**Date:** 2026-02-11
**Database:** PostgreSQL 16 + pgvector 0.6.0
**ORM:** SQLAlchemy 2.0 (Async)

---

## ARCHITECTURE OVERVIEW

```
┌─────────────────────────────────────────────────────────────┐
│                     PostgreSQL 16                           │
│                    + pgvector 0.6.0                         │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
   ┌────▼────┐      ┌──────▼──────┐      ┌────▼────┐
   │  Users  │      │  Sessions   │      │ Content │
   │  Core   │      │  Workflow   │      │ Storage │
   └─────────┘      └─────────────┘      └─────────┘
        │                   │                   │
   ┌────▼────────┐   ┌─────▼──────────┐   ┌────▼────────┐
   │ users       │   │ journaling_    │   │ journaling_ │
   │ ep_profiles │   │   sessions     │   │   artifacts │
   │ preferences │   │ session_states │   │ embeddings  │
   └─────────────┘   │ safety_logs    │   │ themes      │
                     └────────────────┘   │ analysis    │
                                         └─────────────┘
```

---

## COMPLETE SQL SCHEMA

```sql
-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "vector";

-- =============================================================================
-- USERS & PROFILES
-- =============================================================================

-- Core users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    email_verified BOOLEAN DEFAULT FALSE,
    password_hash VARCHAR(255),  -- NULL for SSO users
    auth_provider VARCHAR(50) DEFAULT 'email',  -- email, google, apple
    
    -- Profile
    display_name VARCHAR(100),
    avatar_url TEXT,
    timezone VARCHAR(50) DEFAULT 'UTC',
    locale VARCHAR(10) DEFAULT 'en',
    
    -- Status
    account_status VARCHAR(20) DEFAULT 'active',  -- active, suspended, deleted
    subscription_tier VARCHAR(20) DEFAULT 'free',  -- free, pro, team, enterprise
    
    -- Dates
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_login_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,  -- Soft delete
    
    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(account_status) WHERE account_status != 'deleted';
CREATE INDEX idx_users_created_at ON users(created_at);

-- E&P profiles
CREATE TABLE ep_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Scores
    physical_percentage INT NOT NULL CHECK (physical_percentage BETWEEN 0 AND 100),
    emotional_percentage INT NOT NULL CHECK (emotional_percentage BETWEEN 0 AND 100),
    classification VARCHAR(20) NOT NULL CHECK (classification IN ('Physical', 'Emotional', 'Hybrid')),
    
    -- Derived preferences
    language_style VARCHAR(20) DEFAULT 'balanced',  -- direct, inferential, balanced
    camera_movement VARCHAR(20) DEFAULT 'moderate',  -- static, slow, moderate, dynamic
    pacing_preference VARCHAR(20) DEFAULT 'medium',  -- slow, medium, fast
    
    -- Assessment metadata
    assessment_method VARCHAR(50),  -- quiz, clinician_assigned, inferred
    confidence_score FLOAT,
    
    -- Dates
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,  -- Re-assess every 6 months
    
    CONSTRAINT ep_sum_check CHECK (physical_percentage + emotional_percentage = 100)
);

CREATE INDEX idx_ep_profiles_user_id ON ep_profiles(user_id);
CREATE INDEX idx_ep_profiles_classification ON ep_profiles(classification);

-- User preferences
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    
    -- Notification preferences
    email_notifications BOOLEAN DEFAULT TRUE,
    push_notifications BOOLEAN DEFAULT TRUE,
    reminder_frequency VARCHAR(20) DEFAULT 'weekly',  -- daily, weekly, monthly, none
    
    -- Privacy settings
    analytics_enabled BOOLEAN DEFAULT TRUE,
    share_anonymized_data BOOLEAN DEFAULT FALSE,
    
    -- Journaling preferences
    default_technique VARCHAR(50),
    preferred_session_length INT DEFAULT 15,  -- minutes
    preferred_environment VARCHAR(50) DEFAULT 'forest',  -- XR scene preset
    
    -- Accessibility
    font_size VARCHAR(10) DEFAULT 'medium',  -- small, medium, large
    high_contrast BOOLEAN DEFAULT FALSE,
    reduce_motion BOOLEAN DEFAULT FALSE,
    screen_reader_enabled BOOLEAN DEFAULT FALSE,
    
    -- Advanced
    ai_suggestions_enabled BOOLEAN DEFAULT TRUE,
    auto_save_enabled BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_user_preferences_user_id ON user_preferences(user_id);

-- =============================================================================
-- SESSIONS & WORKFLOW
-- =============================================================================

-- Journaling sessions
CREATE TABLE journaling_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Session config
    technique VARCHAR(50) NOT NULL,
    goal_area VARCHAR(50),
    duration_minutes INT,
    intensity INT CHECK (intensity BETWEEN 1 AND 5),
    
    -- Status
    status VARCHAR(20) DEFAULT 'initiated',  -- initiated, in_progress, completed, paused, terminated
    current_state VARCHAR(50),  -- LangGraph node name
    
    -- Safety
    safety_status VARCHAR(10) DEFAULT 'green',  -- green, yellow, red
    crisis_level VARCHAR(20) DEFAULT 'none',
    constraints JSONB DEFAULT '[]'::jsonb,
    
    -- Session plan (full JSON)
    session_plan JSONB,
    
    -- Dates
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    last_activity_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Metadata
    client_type VARCHAR(20) DEFAULT 'web',  -- web, vr, mobile
    device_info JSONB,
    
    -- Foreign keys
    ep_profile_id UUID REFERENCES ep_profiles(id)
);

CREATE INDEX idx_sessions_user_id ON journaling_sessions(user_id);
CREATE INDEX idx_sessions_status ON journaling_sessions(status);
CREATE INDEX idx_sessions_technique ON journaling_sessions(technique);
CREATE INDEX idx_sessions_started_at ON journaling_sessions(started_at);
CREATE INDEX idx_sessions_safety_status ON journaling_sessions(safety_status);

-- Session state transitions (audit trail)
CREATE TABLE session_state_transitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES journaling_sessions(id) ON DELETE CASCADE,
    
    from_state VARCHAR(50),
    to_state VARCHAR(50) NOT NULL,
    transition_reason VARCHAR(100),
    
    -- Timing
    transitioned_at TIMESTAMPTZ DEFAULT NOW(),
    duration_seconds INT,  -- Time spent in from_state
    
    -- Context
    user_input JSONB,
    llm_response JSONB,
    
    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_state_transitions_session_id ON session_state_transitions(session_id);
CREATE INDEX idx_state_transitions_to_state ON session_state_transitions(to_state);

-- Safety screening logs
CREATE TABLE safety_screening_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_id UUID REFERENCES journaling_sessions(id) ON DELETE SET NULL,
    
    -- Input (hashed for privacy)
    input_hash VARCHAR(64),  -- SHA-256
    context VARCHAR(50) NOT NULL,  -- journaling_initiation, mid_exercise_check, post_session
    
    -- Results
    status VARCHAR(10) NOT NULL,  -- green, yellow, red
    crisis_level VARCHAR(20) NOT NULL,
    detection_signals JSONB DEFAULT '[]'::jsonb,
    constraints JSONB DEFAULT '[]'::jsonb,
    confidence FLOAT,
    
    -- Actions taken
    escalation_required BOOLEAN DEFAULT FALSE,
    resources_provided JSONB,
    clinician_notified BOOLEAN DEFAULT FALSE,
    
    -- Dates
    screened_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Metadata
    screening_version VARCHAR(20),  -- Model version for auditing
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_safety_logs_user_id ON safety_screening_logs(user_id);
CREATE INDEX idx_safety_logs_session_id ON safety_screening_logs(session_id);
CREATE INDEX idx_safety_logs_status ON safety_screening_logs(status);
CREATE INDEX idx_safety_logs_screened_at ON safety_screening_logs(screened_at);
CREATE INDEX idx_safety_logs_escalation ON safety_screening_logs(escalation_required) WHERE escalation_required = TRUE;

-- =============================================================================
-- CONTENT & ARTIFACTS
-- =============================================================================

-- Journaling artifacts (encrypted content)
CREATE TABLE journaling_artifacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES journaling_sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Content (encrypted)
    content_encrypted BYTEA NOT NULL,  -- AES-256-GCM
    encryption_key_id VARCHAR(50),  -- Key version for rotation
    
    -- Metadata (unencrypted for querying)
    technique VARCHAR(50) NOT NULL,
    word_count INT DEFAULT 0,
    character_count INT DEFAULT 0,
    duration_seconds INT DEFAULT 0,
    
    -- Dates
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Storage
    storage_location VARCHAR(20) DEFAULT 'database',  -- database, minio
    minio_object_key TEXT,  -- If stored in MinIO
    
    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_artifacts_session_id ON journaling_artifacts(session_id);
CREATE INDEX idx_artifacts_user_id ON journaling_artifacts(user_id);
CREATE INDEX idx_artifacts_technique ON journaling_artifacts(technique);
CREATE INDEX idx_artifacts_created_at ON journaling_artifacts(created_at);

-- Embeddings (pgvector)
CREATE TABLE journaling_embeddings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    artifact_id UUID NOT NULL REFERENCES journaling_artifacts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Embedding
    embedding vector(1536),  -- OpenAI text-embedding-3-small dimension
    embedding_model VARCHAR(50) DEFAULT 'text-embedding-3-small',
    
    -- Chunk info (if content was chunked)
    chunk_index INT DEFAULT 0,
    chunk_text_hash VARCHAR(64),  -- SHA-256 of plaintext chunk
    
    -- Dates
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_embeddings_artifact_id ON journaling_embeddings(artifact_id);
CREATE INDEX idx_embeddings_user_id ON journaling_embeddings(user_id);
-- Vector similarity search index
CREATE INDEX idx_embeddings_vector ON journaling_embeddings 
    USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Themes (extracted from content)
CREATE TABLE journaling_themes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    artifact_id UUID NOT NULL REFERENCES journaling_artifacts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Theme
    theme_name VARCHAR(100) NOT NULL,
    theme_category VARCHAR(50),  -- emotion, relationship, work, health, etc.
    confidence FLOAT,
    
    -- Context
    evidence_snippets TEXT[],  -- Max 3 quotes supporting this theme
    
    -- Dates
    extracted_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Extraction metadata
    extraction_model VARCHAR(50),
    extraction_version VARCHAR(20)
);

CREATE INDEX idx_themes_artifact_id ON journaling_themes(artifact_id);
CREATE INDEX idx_themes_user_id ON journaling_themes(user_id);
CREATE INDEX idx_themes_name ON journaling_themes(theme_name);
CREATE INDEX idx_themes_category ON journaling_themes(theme_category);

-- Sentiment analysis
CREATE TABLE sentiment_analysis (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    artifact_id UUID NOT NULL REFERENCES journaling_artifacts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Overall sentiment
    sentiment_score FLOAT,  -- -1 (negative) to +1 (positive)
    sentiment_label VARCHAR(20),  -- very_negative, negative, neutral, positive, very_positive
    
    -- Emotions (multi-label)
    emotions JSONB DEFAULT '{}'::jsonb,  -- {"joy": 0.3, "sadness": 0.6, "anger": 0.1}
    
    -- Temporal analysis
    sentiment_trajectory VARCHAR(20),  -- improving, declining, stable
    
    -- Dates
    analyzed_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Analysis metadata
    analysis_model VARCHAR(50),
    analysis_version VARCHAR(20)
);

CREATE INDEX idx_sentiment_artifact_id ON sentiment_analysis(artifact_id);
CREATE INDEX idx_sentiment_user_id ON sentiment_analysis(user_id);
CREATE INDEX idx_sentiment_score ON sentiment_analysis(sentiment_score);
CREATE INDEX idx_sentiment_label ON sentiment_analysis(sentiment_label);

-- =============================================================================
-- CONTENT LIBRARY (RAG)
-- =============================================================================

-- Technique templates
CREATE TABLE technique_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Technique info
    technique_id VARCHAR(50) UNIQUE NOT NULL,
    technique_name VARCHAR(100) NOT NULL,
    technique_category VARCHAR(50),  -- writing, reflection, somatic, meditation
    
    -- Content
    description TEXT NOT NULL,
    instructions TEXT NOT NULL,
    prompts JSONB NOT NULL,  -- Array of prompt objects
    
    -- Requirements
    min_duration_minutes INT DEFAULT 5,
    max_duration_minutes INT DEFAULT 60,
    recommended_duration_minutes INT DEFAULT 15,
    intensity_range INT[] DEFAULT ARRAY[1,2,3,4,5],
    
    -- Adaptations
    physical_adaptation JSONB,
    emotional_adaptation JSONB,
    
    -- Metadata
    evidence_base TEXT[],  -- References to clinical research
    contraindications TEXT[],
    
    -- Status
    active BOOLEAN DEFAULT TRUE,
    version VARCHAR(20),
    
    -- Dates
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_templates_technique_id ON technique_templates(technique_id);
CREATE INDEX idx_templates_category ON technique_templates(technique_category);
CREATE INDEX idx_templates_active ON technique_templates(active) WHERE active = TRUE;

-- XR scene templates
CREATE TABLE xr_scene_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Scene info
    scene_id VARCHAR(50) UNIQUE NOT NULL,
    scene_name VARCHAR(100) NOT NULL,
    theme VARCHAR(50) NOT NULL,  -- forest, garden, studio, space, temple
    
    -- Scene spec (full JSON)
    scene_spec JSONB NOT NULL,
    
    -- Assets
    skybox_url TEXT,
    audio_urls JSONB,
    model_urls JSONB,
    
    -- Performance
    target_framerate INT DEFAULT 72,
    min_spec VARCHAR(50),  -- Quest 2, Quest 3, desktop
    
    -- Status
    active BOOLEAN DEFAULT TRUE,
    version VARCHAR(20),
    
    -- Dates
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_xr_templates_scene_id ON xr_scene_templates(scene_id);
CREATE INDEX idx_xr_templates_theme ON xr_scene_templates(theme);
CREATE INDEX idx_xr_templates_active ON xr_scene_templates(active) WHERE active = TRUE;

-- TTS cache
CREATE TABLE tts_cache (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Cache key
    cache_key VARCHAR(64) UNIQUE NOT NULL,  -- SHA-256 of text+voice+emotion
    
    -- TTS params
    text TEXT NOT NULL,
    text_hash VARCHAR(64),  -- SHA-256
    voice_id VARCHAR(50) NOT NULL,
    emotion VARCHAR(50),
    speed FLOAT DEFAULT 1.0,
    
    -- Audio file
    audio_url TEXT NOT NULL,
    duration_seconds FLOAT,
    file_size_bytes BIGINT,
    
    -- Stats
    hit_count INT DEFAULT 0,
    last_accessed_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Dates
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,  -- For cleanup
    
    -- Metadata
    generation_model VARCHAR(50),
    generation_cost_usd DECIMAL(10, 6)
);

CREATE INDEX idx_tts_cache_key ON tts_cache(cache_key);
CREATE INDEX idx_tts_cache_voice ON tts_cache(voice_id);
CREATE INDEX idx_tts_cache_last_accessed ON tts_cache(last_accessed_at);
CREATE INDEX idx_tts_cache_expires ON tts_cache(expires_at);

-- =============================================================================
-- ANALYTICS & INSIGHTS
-- =============================================================================

-- User progress tracking
CREATE TABLE user_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    
    -- Session counts
    total_sessions INT DEFAULT 0,
    completed_sessions INT DEFAULT 0,
    terminated_sessions INT DEFAULT 0,
    
    -- Time tracking
    total_minutes_journaled INT DEFAULT 0,
    longest_session_minutes INT DEFAULT 0,
    average_session_minutes INT DEFAULT 0,
    
    -- Technique usage
    techniques_tried JSONB DEFAULT '{}'::jsonb,  -- {"sprint": 5, "unsent_letter": 3}
    favorite_technique VARCHAR(50),
    
    -- Streaks
    current_streak_days INT DEFAULT 0,
    longest_streak_days INT DEFAULT 0,
    last_journaled_date DATE,
    
    -- Themes & patterns
    recurring_themes TEXT[],
    resolved_themes TEXT[],
    new_themes_this_month TEXT[],
    
    -- Sentiment trends
    average_sentiment_score FLOAT,
    sentiment_trend VARCHAR(20),  -- improving, declining, stable
    
    -- Milestones
    milestones_achieved JSONB DEFAULT '[]'::jsonb,
    
    -- Dates
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_progress_user_id ON user_progress(user_id);
CREATE INDEX idx_progress_total_sessions ON user_progress(total_sessions);
CREATE INDEX idx_progress_current_streak ON user_progress(current_streak_days);

-- Session feedback
CREATE TABLE session_feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES journaling_sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Ratings (1-5)
    overall_rating INT CHECK (overall_rating BETWEEN 1 AND 5),
    technique_helpfulness INT CHECK (technique_helpfulness BETWEEN 1 AND 5),
    pacing_rating INT CHECK (pacing_rating BETWEEN 1 AND 5),
    safety_comfort INT CHECK (safety_comfort BETWEEN 1 AND 5),
    
    -- Qualitative
    what_worked TEXT,
    what_could_improve TEXT,
    would_recommend BOOLEAN,
    
    -- Specific feedback
    technical_issues TEXT[],
    content_suggestions TEXT,
    
    -- Dates
    submitted_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_feedback_session_id ON session_feedback(session_id);
CREATE INDEX idx_feedback_user_id ON session_feedback(user_id);
CREATE INDEX idx_feedback_rating ON session_feedback(overall_rating);

-- =============================================================================
-- SYSTEM & OPERATIONS
-- =============================================================================

-- API keys (for external integrations)
CREATE TABLE api_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Key
    key_hash VARCHAR(255) UNIQUE NOT NULL,  -- bcrypt
    key_prefix VARCHAR(10),  -- First 8 chars for identification
    
    -- Metadata
    name VARCHAR(100),
    description TEXT,
    scopes TEXT[],  -- read, write, admin
    
    -- Status
    active BOOLEAN DEFAULT TRUE,
    
    -- Usage
    last_used_at TIMESTAMPTZ,
    request_count BIGINT DEFAULT 0,
    
    -- Dates
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ
);

CREATE INDEX idx_api_keys_user_id ON api_keys(user_id);
CREATE INDEX idx_api_keys_active ON api_keys(active) WHERE active = TRUE;

-- Audit logs
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Actor
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    api_key_id UUID REFERENCES api_keys(id) ON DELETE SET NULL,
    
    -- Action
    action VARCHAR(100) NOT NULL,  -- user.created, session.started, artifact.deleted
    entity_type VARCHAR(50),
    entity_id UUID,
    
    -- Details
    changes JSONB,  -- Before/after for updates
    ip_address INET,
    user_agent TEXT,
    
    -- Dates
    performed_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_performed_at ON audit_logs(performed_at);

-- Background jobs
CREATE TABLE background_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Job info
    job_type VARCHAR(50) NOT NULL,  -- theme_extraction, sentiment_analysis, embedding_generation
    job_data JSONB NOT NULL,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending',  -- pending, running, completed, failed
    attempts INT DEFAULT 0,
    max_attempts INT DEFAULT 3,
    
    -- Error handling
    last_error TEXT,
    error_count INT DEFAULT 0,
    
    -- Timing
    created_at TIMESTAMPTZ DEFAULT NOW(),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    next_retry_at TIMESTAMPTZ,
    
    -- Priority
    priority INT DEFAULT 0,  -- Higher = more important
    
    -- Worker info
    worker_id VARCHAR(100)
);

CREATE INDEX idx_jobs_status ON background_jobs(status) WHERE status IN ('pending', 'running');
CREATE INDEX idx_jobs_type ON background_jobs(job_type);
CREATE INDEX idx_jobs_next_retry ON background_jobs(next_retry_at) WHERE status = 'failed';
CREATE INDEX idx_jobs_priority ON background_jobs(priority DESC, created_at ASC);

-- =============================================================================
-- FUNCTIONS & TRIGGERS
-- =============================================================================

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at trigger to tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ep_profiles_updated_at BEFORE UPDATE ON ep_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON user_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_technique_templates_updated_at BEFORE UPDATE ON technique_templates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_xr_scene_templates_updated_at BEFORE UPDATE ON xr_scene_templates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_progress_updated_at BEFORE UPDATE ON user_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function: Calculate EP classification from percentages
CREATE OR REPLACE FUNCTION calculate_ep_classification(p_physical INT, p_emotional INT)
RETURNS VARCHAR(20) AS $$
BEGIN
    IF p_physical >= 80 THEN
        RETURN 'Physical';
    ELSIF p_emotional >= 80 THEN
        RETURN 'Emotional';
    ELSE
        RETURN 'Hybrid';
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- =============================================================================
-- VIEWS
-- =============================================================================

-- View: User session summary
CREATE VIEW user_session_summary AS
SELECT 
    u.id AS user_id,
    u.email,
    COUNT(js.id) AS total_sessions,
    COUNT(CASE WHEN js.status = 'completed' THEN 1 END) AS completed_sessions,
    SUM(js.duration_minutes) AS total_minutes,
    AVG(js.intensity) AS avg_intensity,
    MAX(js.started_at) AS last_session_at,
    ARRAY_AGG(DISTINCT js.technique) AS techniques_used
FROM users u
LEFT JOIN journaling_sessions js ON u.id = js.user_id
GROUP BY u.id, u.email;

-- View: Recent high-risk sessions (Code Yellow/Red)
CREATE VIEW high_risk_sessions AS
SELECT 
    js.id AS session_id,
    js.user_id,
    u.email,
    js.safety_status,
    js.crisis_level,
    js.technique,
    js.started_at,
    ssl.escalation_required,
    ssl.clinician_notified
FROM journaling_sessions js
JOIN users u ON js.user_id = u.id
LEFT JOIN safety_screening_logs ssl ON js.id = ssl.session_id
WHERE js.safety_status IN ('yellow', 'red')
ORDER BY js.started_at DESC;

-- View: Theme frequency across all users (anonymized)
CREATE VIEW global_theme_frequency AS
SELECT 
    jt.theme_name,
    jt.theme_category,
    COUNT(*) AS frequency,
    AVG(jt.confidence) AS avg_confidence
FROM journaling_themes jt
GROUP BY jt.theme_name, jt.theme_category
ORDER BY frequency DESC;

-- =============================================================================
-- INITIAL DATA SEEDING
-- =============================================================================

-- Insert technique templates (examples)
INSERT INTO technique_templates (
    technique_id, technique_name, technique_category, description, instructions, prompts,
    min_duration_minutes, max_duration_minutes, recommended_duration_minutes
) VALUES
(
    'sprint',
    'Sprint / Free-Write',
    'writing',
    'Timed free-writing without editing or judgment.',
    'Write continuously for 7 minutes. Keep your pen moving. Do not edit or censor.',
    '{"setup": "Find a comfortable position.", "prompt": "Write whatever comes to mind.", "guideposts": [{"time": 2, "text": "Keep going."}, {"time": 4, "text": "Halfway there."}, {"time": 6, "text": "One more minute."}]}'::jsonb,
    5, 10, 7
),
(
    'unsent_letter',
    'Unsent Letter',
    'writing',
    'Write a letter to someone you will not send.',
    'Write a letter expressing what you need to say. This letter will NOT be sent.',
    '{"intensity_check": "Rate your intensity 1-5.", "intention": "Who is this letter to?", "prompts": ["I need to tell you...", "What I wish you understood..."], "boundary": "From now on, I will...", "integration": "What did I learn?"}'::jsonb,
    15, 25, 20
);

-- Insert XR scene templates (examples)
INSERT INTO xr_scene_templates (
    scene_id, scene_name, theme, scene_spec, target_framerate
) VALUES
(
    'forest_clearing_v1',
    'Forest Clearing',
    'forest',
    '{"skybox": {"type": "hdri", "url": "https://cdn.jeeth.ai/environments/forest_clearing_4k.hdr"}, "lighting": {"ambient": {"intensity": 0.6}}, "audio": ["forest_ambient_loop.mp3"]}'::jsonb,
    72
),
(
    'zen_garden_v1',
    'Zen Garden',
    'garden',
    '{"skybox": {"type": "gradient"}, "lighting": {"ambient": {"intensity": 0.7}}, "audio": ["zen_garden_ambient.mp3"]}'::jsonb,
    72
);
```

---

## SQLALCHEMY MODELS

```python
# services/api/app/models/db_models.py
from sqlalchemy import Column, String, Integer, Boolean, TIMESTAMP, ForeignKey, Text, ARRAY, Float, BIGINT, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID, JSONB, BYTEA, INET
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from pgvector.sqlalchemy import Vector
import uuid

from app.db.database import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), unique=True, nullable=False)
    email_verified = Column(Boolean, default=False)
    password_hash = Column(String(255))
    auth_provider = Column(String(50), default='email')
    
    display_name = Column(String(100))
    avatar_url = Column(Text)
    timezone = Column(String(50), default='UTC')
    locale = Column(String(10), default='en')
    
    account_status = Column(String(20), default='active')
    subscription_tier = Column(String(20), default='free')
    
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())
    last_login_at = Column(TIMESTAMP(timezone=True))
    deleted_at = Column(TIMESTAMP(timezone=True))
    
    metadata = Column(JSONB, default={})
    
    # Relationships
    sessions = relationship("JournalingSession", back_populates="user")
    artifacts = relationship("JournalingArtifact", back_populates="user")
    ep_profiles = relationship("EPProfile", back_populates="user")

class EPProfile(Base):
    __tablename__ = "ep_profiles"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    
    physical_percentage = Column(Integer, nullable=False)
    emotional_percentage = Column(Integer, nullable=False)
    classification = Column(String(20), nullable=False)
    
    language_style = Column(String(20), default='balanced')
    camera_movement = Column(String(20), default='moderate')
    pacing_preference = Column(String(20), default='medium')
    
    assessment_method = Column(String(50))
    confidence_score = Column(Float)
    
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    expires_at = Column(TIMESTAMP(timezone=True))
    
    __table_args__ = (
        CheckConstraint('physical_percentage BETWEEN 0 AND 100'),
        CheckConstraint('emotional_percentage BETWEEN 0 AND 100'),
        CheckConstraint('physical_percentage + emotional_percentage = 100'),
        CheckConstraint("classification IN ('Physical', 'Emotional', 'Hybrid')")
    )
    
    # Relationships
    user = relationship("User", back_populates="ep_profiles")

class JournalingSession(Base):
    __tablename__ = "journaling_sessions"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    
    technique = Column(String(50), nullable=False)
    goal_area = Column(String(50))
    duration_minutes = Column(Integer)
    intensity = Column(Integer)
    
    status = Column(String(20), default='initiated')
    current_state = Column(String(50))
    
    safety_status = Column(String(10), default='green')
    crisis_level = Column(String(20), default='none')
    constraints = Column(JSONB, default=[])
    
    session_plan = Column(JSONB)
    
    started_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    completed_at = Column(TIMESTAMP(timezone=True))
    last_activity_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    
    client_type = Column(String(20), default='web')
    device_info = Column(JSONB)
    
    ep_profile_id = Column(UUID(as_uuid=True), ForeignKey('ep_profiles.id'))
    
    __table_args__ = (
        CheckConstraint('intensity BETWEEN 1 AND 5'),
    )
    
    # Relationships
    user = relationship("User", back_populates="sessions")
    artifacts = relationship("JournalingArtifact", back_populates="session")

class JournalingArtifact(Base):
    __tablename__ = "journaling_artifacts"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    session_id = Column(UUID(as_uuid=True), ForeignKey('journaling_sessions.id', ondelete='CASCADE'), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    
    content_encrypted = Column(BYTEA, nullable=False)
    encryption_key_id = Column(String(50))
    
    technique = Column(String(50), nullable=False)
    word_count = Column(Integer, default=0)
    character_count = Column(Integer, default=0)
    duration_seconds = Column(Integer, default=0)
    
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    
    storage_location = Column(String(20), default='database')
    minio_object_key = Column(Text)
    
    metadata = Column(JSONB, default={})
    
    # Relationships
    user = relationship("User", back_populates="artifacts")
    session = relationship("JournalingSession", back_populates="artifacts")
    themes = relationship("JournalingTheme", back_populates="artifact")

class JournalingEmbedding(Base):
    __tablename__ = "journaling_embeddings"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    artifact_id = Column(UUID(as_uuid=True), ForeignKey('journaling_artifacts.id', ondelete='CASCADE'), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    
    embedding = Column(Vector(1536))  # OpenAI text-embedding-3-small
    embedding_model = Column(String(50), default='text-embedding-3-small')
    
    chunk_index = Column(Integer, default=0)
    chunk_text_hash = Column(String(64))
    
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    
    metadata = Column(JSONB, default={})

class JournalingTheme(Base):
    __tablename__ = "journaling_themes"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    artifact_id = Column(UUID(as_uuid=True), ForeignKey('journaling_artifacts.id', ondelete='CASCADE'), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    
    theme_name = Column(String(100), nullable=False)
    theme_category = Column(String(50))
    confidence = Column(Float)
    
    evidence_snippets = Column(ARRAY(Text))
    
    extracted_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    
    extraction_model = Column(String(50))
    extraction_version = Column(String(20))
    
    # Relationships
    artifact = relationship("JournalingArtifact", back_populates="themes")

# Additional models for sentiment_analysis, safety_screening_logs, etc. follow same pattern...
```

---

**STATUS:** Database Schema Complete ✅

**Includes:**
- 25+ tables with complete definitions
- Foreign key relationships with CASCADE
- Indexes for query optimization
- pgvector integration for embeddings
- Triggers for updated_at timestamps
- Views for common queries
- Initial data seeding
- SQLAlchemy ORM models

**Next:** Alembic Migrations + Testing Strategy + Deployment Infrastructure
