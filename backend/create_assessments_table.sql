-- ============================================================================
-- CREATE E&P Assessment Tables from Scratch
-- Use this if you want to drop and recreate the tables
-- ============================================================================

-- WARNING: This will DELETE all existing assessment data!
-- Uncomment the DROP commands only if you're sure

-- DROP TABLE IF EXISTS user_assessments CASCADE;
-- DROP TABLE IF EXISTS questionnaire_versions CASCADE;

-- ============================================================================
-- Table: questionnaire_versions
-- Stores different versions of the E&P questionnaire
-- ============================================================================

CREATE TABLE IF NOT EXISTS questionnaire_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    version_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(500),
    questions JSONB NOT NULL,
    scoring_rules JSONB NOT NULL,
    is_active INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_questionnaire_versions_active 
ON questionnaire_versions(is_active);

-- Insert default questionnaire version
INSERT INTO questionnaire_versions (
    version_name,
    description,
    questions,
    scoring_rules,
    is_active
) VALUES (
    'HMI Standard v1.0',
    'Standard HMI E&P Suggestibility Assessment - 36 questions',
    '{
        "q1": {"text": "Question 1 text...", "type": "physical"},
        "q2": {"text": "Question 2 text...", "type": "physical"}
    }'::jsonb,
    '{
        "physical_questions": [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18],
        "emotional_questions": [19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36],
        "weights": {"equal": true}
    }'::jsonb,
    1
) ON CONFLICT (version_name) DO NOTHING;

-- ============================================================================
-- Table: user_assessments
-- Stores completed E&P Suggestibility assessments
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_assessments (
    -- Primary identifiers
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    session_id UUID NULL,
    questionnaire_version_id UUID NOT NULL REFERENCES questionnaire_versions(id) ON DELETE RESTRICT,
    
    -- Scores
    q1_score INTEGER NOT NULL CHECK (q1_score >= 0 AND q1_score <= 100),
    q2_score INTEGER NOT NULL CHECK (q2_score >= 0 AND q2_score <= 100),
    combined_score INTEGER NOT NULL CHECK (combined_score >= 0 AND combined_score <= 200),
    physical_percentage INTEGER NOT NULL CHECK (physical_percentage >= 0 AND physical_percentage <= 100),
    emotional_percentage INTEGER NOT NULL CHECK (emotional_percentage >= 0 AND emotional_percentage <= 100),
    
    -- Classification
    suggestibility_type VARCHAR(100) NOT NULL,
    
    -- Raw data
    answers JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- Metadata
    completed_at TIMESTAMP DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT chk_percentages_sum CHECK (physical_percentage + emotional_percentage = 100)
);

-- ============================================================================
-- Indexes for Performance
-- ============================================================================

CREATE INDEX IF NOT EXISTS ix_user_assessments_user_id 
ON user_assessments(user_id);

CREATE INDEX IF NOT EXISTS ix_user_assessments_session_id 
ON user_assessments(session_id);

CREATE INDEX IF NOT EXISTS ix_user_assessments_completed_at 
ON user_assessments(completed_at DESC);

CREATE INDEX IF NOT EXISTS ix_user_assessments_suggestibility_type 
ON user_assessments(suggestibility_type);

-- GIN index for JSONB answers column (enables fast JSON queries)
CREATE INDEX IF NOT EXISTS ix_user_assessments_answers 
ON user_assessments USING gin(answers);

-- ============================================================================
-- Verify Creation
-- ============================================================================

\d questionnaire_versions;
\d user_assessments;

SELECT 
    'questionnaire_versions' as table_name,
    COUNT(*) as row_count 
FROM questionnaire_versions
UNION ALL
SELECT 
    'user_assessments' as table_name,
    COUNT(*) as row_count 
FROM user_assessments;

\echo ''
\echo 'âœ… Tables created successfully!'
\echo ''
