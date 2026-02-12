# Database Schema Design
## Therapeutic Journaling Platform - Hypno Resilient Mind 12

**Version:** 1.0
**Date:** 2026-02-11
**Database:** PostgreSQL 15.x

---

## OVERVIEW

**Total Tables:** 35
**Foreign Keys:** 48
**Indexes:** 87
**Partitions:** 2 (audit_logs, session_events)

---

## 1. CORE TABLES

### 1.1 users
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    date_of_birth DATE,
    location_country VARCHAR(100),
    preferred_language VARCHAR(10) DEFAULT 'en',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login_at TIMESTAMPTZ,
    status VARCHAR(20) DEFAULT 'active', -- active, suspended, deleted
    consent_marketing BOOLEAN DEFAULT FALSE,
    consent_data_processing BOOLEAN NOT NULL,
    consent_emergency_contact BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_created_at ON users(created_at DESC);
```

---

### 1.2 sessions
```sql
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_number INTEGER, -- 1, 2, 3... for this user
    modality VARCHAR(20) DEFAULT 'web', -- web, vr, desktop
    environment_id VARCHAR(50), -- cozy_cabin, beach_sunset, etc.
    status VARCHAR(30) DEFAULT 'created',
    -- created, intake_pending, safety_screening, active,
    -- exercise_in_progress, reflecting, hitl_review, completed, timed_out
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    duration_minutes INTEGER, -- calculated
    safety_status VARCHAR(10), -- green, yellow, red
    requires_hitl_review BOOLEAN DEFAULT FALSE,
    hitl_reviewed_at TIMESTAMPTZ,
    hitl_reviewer_id UUID, -- FK to clinicians table
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_status ON sessions(status);
CREATE INDEX idx_sessions_safety_status ON sessions(safety_status);
CREATE INDEX idx_sessions_hitl_review ON sessions(requires_hitl_review) WHERE requires_hitl_review = TRUE;
CREATE INDEX idx_sessions_started_at ON sessions(started_at DESC);
```

---

### 1.3 session_events
**Partitioned by week for performance**

```sql
CREATE TABLE session_events (
    id BIGSERIAL,
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL,
    -- state_transition, agent_execution, user_interaction, error, etc.
    from_state VARCHAR(30),
    to_state VARCHAR(30),
    event_data JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY RANGE (created_at);

CREATE INDEX idx_session_events_session_id ON session_events(session_id);
CREATE INDEX idx_session_events_type ON session_events(event_type);
CREATE INDEX idx_session_events_created_at ON session_events(created_at DESC);

-- Create partitions (example for 2026)
CREATE TABLE session_events_2026_w01 PARTITION OF session_events
    FOR VALUES FROM ('2026-01-01') TO ('2026-01-08');
CREATE TABLE session_events_2026_w02 PARTITION OF session_events
    FOR VALUES FROM ('2026-01-08') TO ('2026-01-15');
-- ... (automated partition creation via cron)
```

---

## 2. INTAKE & ASSESSMENT TABLES

### 2.1 session_intents
```sql
CREATE TABLE session_intents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    goal_category VARCHAR(50), -- relationships, career, personal, health
    intensity_level INTEGER CHECK (intensity_level BETWEEN 1 AND 5),
    readiness_score INTEGER CHECK (readiness_score BETWEEN 1 AND 10),
    contraindications TEXT[],
    recommended_techniques TEXT[],
    estimated_duration_minutes INTEGER,
    agent_confidence_score DECIMAL(3, 2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_session_intents_session_id ON session_intents(session_id);
CREATE INDEX idx_session_intents_goal_category ON session_intents(goal_category);
```

---

## 3. AGENT EXECUTION TABLES

### 3.1 agent_outputs
```sql
CREATE TABLE agent_outputs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    agent_name VARCHAR(50) NOT NULL,
    -- safety_guardian, intake_triage, journaling_coach, etc.
    agent_version VARCHAR(20) DEFAULT 'v1.0',
    sequence_number INTEGER, -- execution order in workflow
    input_data JSONB, -- anonymized input to agent
    output_data JSONB NOT NULL, -- agent's response
    llm_model VARCHAR(100), -- claude-sonnet-4-5-20250514
    llm_temperature DECIMAL(3, 2),
    input_tokens INTEGER,
    output_tokens INTEGER,
    llm_duration_seconds DECIMAL(10, 3),
    total_duration_seconds DECIMAL(10, 3),
    cost_estimate_usd DECIMAL(10, 6),
    status VARCHAR(20) DEFAULT 'success', -- success, failed, retry
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_agent_outputs_session_id ON agent_outputs(session_id);
CREATE INDEX idx_agent_outputs_agent_name ON agent_outputs(agent_name);
CREATE INDEX idx_agent_outputs_status ON agent_outputs(status);
CREATE INDEX idx_agent_outputs_created_at ON agent_outputs(created_at DESC);
```

---

### 3.2 mcp_tool_calls
```sql
CREATE TABLE mcp_tool_calls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_output_id UUID NOT NULL REFERENCES agent_outputs(id) ON DELETE CASCADE,
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    tool_name VARCHAR(100) NOT NULL,
    -- rag_retrieve, create_session_plan, tts_render, etc.
    tool_version VARCHAR(20) DEFAULT 'v1.0',
    input_params JSONB,
    output_result JSONB,
    execution_time_ms INTEGER,
    status VARCHAR(20) DEFAULT 'success',
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_mcp_tool_calls_agent_output_id ON mcp_tool_calls(agent_output_id);
CREATE INDEX idx_mcp_tool_calls_tool_name ON mcp_tool_calls(tool_name);
```

---

## 4. JOURNALING EXERCISES TABLES

### 4.1 exercises
```sql
CREATE TABLE exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    technique VARCHAR(50) NOT NULL,
    -- sprint, unsent_letter, sentence_stems, list_of_100, etc.
    technique_config JSONB, -- timebox, recipient, tone, etc.
    opening_prompt TEXT,
    guideposts TEXT[],
    grounding_close TEXT,
    status VARCHAR(20) DEFAULT 'in_progress',
    -- in_progress, completed, abandoned
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    duration_minutes INTEGER,
    word_count INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_exercises_session_id ON exercises(session_id);
CREATE INDEX idx_exercises_user_id ON exercises(user_id);
CREATE INDEX idx_exercises_technique ON exercises(technique);
CREATE INDEX idx_exercises_status ON exercises(status);
```

---

### 4.2 exercise_artifacts
```sql
CREATE TABLE exercise_artifacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    artifact_type VARCHAR(50) NOT NULL,
    -- text_entry, audio_recording, canvas_drawing, vr_volumetric
    content_text TEXT, -- for text-based exercises
    content_encrypted BYTEA, -- for sensitive content (unsent letters)
    encryption_key_id UUID, -- FK to user's encryption keys
    minio_object_key VARCHAR(255), -- for audio/video/images
    sensitivity_level VARCHAR(20) DEFAULT 'standard',
    -- standard, high, crisis
    file_size_bytes BIGINT,
    mime_type VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_exercise_artifacts_exercise_id ON exercise_artifacts(exercise_id);
CREATE INDEX idx_exercise_artifacts_user_id ON exercise_artifacts(user_id);
CREATE INDEX idx_exercise_artifacts_artifact_type ON exercise_artifacts(artifact_type);
CREATE INDEX idx_exercise_artifacts_sensitivity_level ON exercise_artifacts(sensitivity_level);
```

---

## 5. REFLECTION & ANALYSIS TABLES

### 5.1 reflections
```sql
CREATE TABLE reflections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recurring_themes TEXT[],
    emotional_tone VARCHAR(100),
    action_items TEXT[],
    unresolved_questions TEXT[],
    sentiment_score DECIMAL(5, 3), -- -1.0 to 1.0
    word_count INTEGER,
    next_session_recommendation TEXT,
    agent_summary TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_reflections_session_id ON reflections(session_id);
CREATE INDEX idx_reflections_user_id ON reflections(user_id);
CREATE INDEX idx_reflections_sentiment_score ON reflections(sentiment_score);
```

---

### 5.2 user_progress
```sql
CREATE TABLE user_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    total_sessions INTEGER DEFAULT 0,
    completed_sessions INTEGER DEFAULT 0,
    total_minutes INTEGER DEFAULT 0,
    techniques_used TEXT[],
    avg_sentiment_score DECIMAL(5, 3),
    sentiment_trend VARCHAR(20), -- improving, declining, stable
    last_session_at TIMESTAMPTZ,
    streak_days INTEGER DEFAULT 0, -- consecutive days with sessions
    longest_streak_days INTEGER DEFAULT 0,
    achievements TEXT[], -- badges, milestones
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX idx_user_progress_last_session ON user_progress(last_session_at DESC);
CREATE INDEX idx_user_progress_sentiment_trend ON user_progress(sentiment_trend);
```

---

## 6. SAFETY & CRISIS TABLES

### 6.1 safety_screenings
```sql
CREATE TABLE safety_screenings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    input_hash VARCHAR(64) NOT NULL, -- SHA-256 hash (privacy)
    safety_status VARCHAR(10) NOT NULL, -- green, yellow, red
    crisis_level VARCHAR(20), -- none, low, medium, severe
    constraints TEXT[],
    response_mode VARCHAR(20), -- standard, cautious, crisis
    recommended_action VARCHAR(20), -- continue, review, escalate
    confidence_score DECIMAL(3, 2),
    detection_signals JSONB, -- what triggered the status
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_safety_screenings_session_id ON safety_screenings(session_id);
CREATE INDEX idx_safety_screenings_user_id ON safety_screenings(user_id);
CREATE INDEX idx_safety_screenings_safety_status ON safety_screenings(safety_status);
CREATE INDEX idx_safety_screenings_crisis_level ON safety_screenings(crisis_level);
```

---

### 6.2 crisis_logs
**Privacy-preserving: NO raw user input**

```sql
CREATE TABLE crisis_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    crisis_level VARCHAR(20) NOT NULL, -- low, medium, severe
    input_hash VARCHAR(64) NOT NULL, -- SHA-256 (no plaintext)
    response_template_id VARCHAR(50), -- CRISIS_SUICIDAL_IDEATION_v3
    escalation_status VARCHAR(30), -- none, hitl_pending, clinician_notified, resolved
    escalation_chain_executed JSONB, -- log, Slack, email, ticket
    resources_provided TEXT[], -- hotline numbers, crisis resources
    user_acknowledged BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

CREATE INDEX idx_crisis_logs_user_id ON crisis_logs(user_id);
CREATE INDEX idx_crisis_logs_crisis_level ON crisis_logs(crisis_level);
CREATE INDEX idx_crisis_logs_escalation_status ON crisis_logs(escalation_status);
CREATE INDEX idx_crisis_logs_created_at ON crisis_logs(created_at DESC);
```

---

## 7. HITL REVIEW TABLES

### 7.1 hitl_escalations
```sql
CREATE TABLE hitl_escalations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    user_id_anonymized VARCHAR(100) NOT NULL, -- User #47291
    escalation_reason VARCHAR(100),
    priority VARCHAR(20) NOT NULL, -- low, medium, high, urgent
    review_deadline TIMESTAMPTZ NOT NULL,
    review_status VARCHAR(30) DEFAULT 'pending',
    -- pending, in_review, approved, rejected, escalated
    assigned_to_clinician_id UUID, -- FK to clinicians table
    assigned_at TIMESTAMPTZ,
    reviewed_at TIMESTAMPTZ,
    clinician_action VARCHAR(50),
    -- approve_as_is, approve_with_edits, reject_and_replace, escalate
    clinician_notes TEXT, -- encrypted, internal only
    session_context JSONB, -- anonymized session data
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_hitl_escalations_review_status ON hitl_escalations(review_status);
CREATE INDEX idx_hitl_escalations_priority_deadline ON hitl_escalations(priority, review_deadline);
CREATE INDEX idx_hitl_escalations_assigned_to ON hitl_escalations(assigned_to_clinician_id);
CREATE INDEX idx_hitl_escalations_created_at ON hitl_escalations(created_at DESC);
```

---

### 7.2 clinicians
```sql
CREATE TABLE clinicians (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    license_type VARCHAR(100), -- LCSW, LMFT, PhD, etc.
    license_number VARCHAR(100),
    license_state VARCHAR(50),
    specialties TEXT[],
    role VARCHAR(20) DEFAULT 'reviewer', -- reviewer, senior, supervisor
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_clinicians_email ON clinicians(email);
CREATE INDEX idx_clinicians_status ON clinicians(status);
```

---

## 8. XR/VR TABLES

### 8.1 vr_sessions
```sql
CREATE TABLE vr_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    environment_id VARCHAR(50) NOT NULL, -- cozy_cabin, beach_sunset
    environment_config JSONB, -- lighting, audio, camera
    interaction_mode VARCHAR(30), -- gaze, hand_tracking, controller
    spatial_audio_enabled BOOLEAN DEFAULT TRUE,
    cinematic_mode_enabled BOOLEAN DEFAULT FALSE,
    camera_path_data JSONB, -- for cinematic mode
    performance_metrics JSONB, -- fps, latency, dropped frames
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    duration_minutes INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_vr_sessions_parent_session_id ON vr_sessions(parent_session_id);
CREATE INDEX idx_vr_sessions_user_id ON vr_sessions(user_id);
CREATE INDEX idx_vr_sessions_environment_id ON vr_sessions(environment_id);
```

---

### 8.2 bilateral_drawings
```sql
CREATE TABLE bilateral_drawings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vr_session_id UUID REFERENCES vr_sessions(id) ON DELETE SET NULL,
    left_hand_strokes JSONB, -- 3D stroke data
    right_hand_strokes JSONB,
    symmetry_enabled BOOLEAN DEFAULT TRUE,
    canvas_1_minio_key VARCHAR(255), -- rendered image
    canvas_2_minio_key VARCHAR(255),
    combined_minio_key VARCHAR(255),
    stroke_count INTEGER,
    duration_seconds INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_bilateral_drawings_exercise_id ON bilateral_drawings(exercise_id);
CREATE INDEX idx_bilateral_drawings_vr_session_id ON bilateral_drawings(vr_session_id);
```

---

## 9. CONTENT & ASSETS TABLES

### 9.1 tts_cache
```sql
CREATE TABLE tts_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    text_hash VARCHAR(64) UNIQUE NOT NULL, -- SHA-256 of text
    voice_id VARCHAR(50) NOT NULL, -- ElevenLabs voice
    text_preview VARCHAR(255), -- first 255 chars (for debugging)
    minio_object_key VARCHAR(255) NOT NULL,
    audio_duration_seconds DECIMAL(10, 3),
    file_size_bytes BIGINT,
    mime_type VARCHAR(50) DEFAULT 'audio/mpeg',
    cache_hits INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_accessed_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_tts_cache_text_hash ON tts_cache(text_hash);
CREATE INDEX idx_tts_cache_voice_id ON tts_cache(voice_id);
CREATE INDEX idx_tts_cache_last_accessed ON tts_cache(last_accessed_at DESC);
```

---

### 9.2 prompt_registry
```sql
CREATE TABLE prompt_registry (
    id VARCHAR(100) PRIMARY KEY, -- TJ-EX-UNSENT-LETTER-v1
    purpose TEXT NOT NULL,
    category VARCHAR(50), -- exercise, safety, grounding
    version INTEGER DEFAULT 1,
    status VARCHAR(20) DEFAULT 'active', -- active, deprecated, testing
    inputs TEXT[], -- expected input parameters
    outputs TEXT[], -- expected output fields
    guardrails TEXT[],
    system_prompt TEXT,
    developer_prompt TEXT,
    format VARCHAR(50) DEFAULT 'markdown',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID, -- FK to users or clinicians
    last_updated_at TIMESTAMPTZ,
    usage_count INTEGER DEFAULT 0
);

CREATE INDEX idx_prompt_registry_category ON prompt_registry(category);
CREATE INDEX idx_prompt_registry_status ON prompt_registry(status);
```

---

## 10. AUDIT & COMPLIANCE TABLES

### 10.1 audit_logs
**Partitioned by month for compliance**

```sql
CREATE TABLE audit_logs (
    id BIGSERIAL,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    clinician_id UUID REFERENCES clinicians(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    -- login, logout, session_create, session_complete, hitl_review, etc.
    resource_type VARCHAR(50),
    resource_id UUID,
    ip_address INET,
    user_agent TEXT,
    request_method VARCHAR(10),
    request_path VARCHAR(500),
    response_status INTEGER,
    changes_made JSONB,
    is_phi_access BOOLEAN DEFAULT FALSE,
    phi_access_reason VARCHAR(255)
) PARTITION BY RANGE (timestamp);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp DESC);
CREATE INDEX idx_audit_logs_phi_access ON audit_logs(is_phi_access) WHERE is_phi_access = TRUE;

-- Create partitions (example for 2026)
CREATE TABLE audit_logs_2026_01 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
CREATE TABLE audit_logs_2026_02 PARTITION OF audit_logs
    FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');
-- ... (automated partition creation via cron)
```

---

### 10.2 consent_records
```sql
CREATE TABLE consent_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    consent_type VARCHAR(100) NOT NULL,
    -- data_processing, marketing, emergency_contact, research
    consent_version VARCHAR(20) NOT NULL, -- v1.0, v2.0
    consent_given BOOLEAN NOT NULL,
    consent_text TEXT, -- full consent language
    ip_address INET,
    user_agent TEXT,
    consented_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    withdrawn_at TIMESTAMPTZ
);

CREATE INDEX idx_consent_records_user_id ON consent_records(user_id);
CREATE INDEX idx_consent_records_consent_type ON consent_records(consent_type);
```

---

## 11. NOTIFICATIONS & MESSAGING TABLES

### 11.1 notifications
```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL,
    -- session_reviewed, reminder, achievement, system
    title VARCHAR(255),
    body TEXT,
    action_url VARCHAR(500),
    read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(user_id, read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
```

---

## 12. ANALYTICS TABLES

### 12.1 daily_metrics
```sql
CREATE TABLE daily_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    metric_date DATE UNIQUE NOT NULL,
    total_sessions_started INTEGER DEFAULT 0,
    total_sessions_completed INTEGER DEFAULT 0,
    completion_rate DECIMAL(5, 2), -- percentage
    avg_session_duration_minutes INTEGER,
    crisis_escalations INTEGER DEFAULT 0,
    hitl_reviews_pending INTEGER DEFAULT 0,
    hitl_reviews_completed INTEGER DEFAULT 0,
    new_users INTEGER DEFAULT 0,
    active_users INTEGER DEFAULT 0,
    avg_user_satisfaction DECIMAL(3, 2), -- out of 5.0
    total_cost_usd DECIMAL(10, 2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_daily_metrics_date ON daily_metrics(metric_date DESC);
```

---

## SUMMARY

**Database Size Estimate (1 year, 10k users):**
- Core tables (users, sessions, exercises): ~5 GB
- Agent outputs (LLM traces): ~20 GB
- Artifacts (encrypted text): ~10 GB
- Audit logs (partitioned): ~15 GB
- Indexes: ~8 GB
- **Total:** ~58 GB

**Performance:**
- 95% of queries < 50ms
- Connection pooling: 100-500 connections
- Replication: 1 primary + 2 read replicas

**Backup:**
- Full backup: daily at 2 AM UTC
- WAL archiving: continuous
- Retention: 30 days
