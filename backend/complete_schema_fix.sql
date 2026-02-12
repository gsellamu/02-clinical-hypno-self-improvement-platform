-- ============================================================================
-- COMPLETE E&P Assessment Schema Fix
-- This script adds ALL missing columns to user_assessments table
-- ============================================================================

-- First, let's see what we have
\d user_assessments;

-- Begin transaction for safety
BEGIN;

-- Add session_id if missing
DO 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_assessments' AND column_name = 'session_id'
    ) THEN
        ALTER TABLE user_assessments ADD COLUMN session_id UUID NULL;
        CREATE INDEX ix_user_assessments_session_id ON user_assessments(session_id);
        RAISE NOTICE 'Added session_id column';
    ELSE
        RAISE NOTICE 'session_id column already exists';
    END IF;
END
;

-- Add suggestibility_type if missing
DO 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_assessments' AND column_name = 'suggestibility_type'
    ) THEN
        ALTER TABLE user_assessments ADD COLUMN suggestibility_type VARCHAR(100) NOT NULL DEFAULT 'Unknown';
        RAISE NOTICE 'Added suggestibility_type column';
    ELSE
        RAISE NOTICE 'suggestibility_type column already exists';
    END IF;
END
;

-- Add q1_score if missing
DO 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_assessments' AND column_name = 'q1_score'
    ) THEN
        ALTER TABLE user_assessments ADD COLUMN q1_score INTEGER NOT NULL DEFAULT 0;
        RAISE NOTICE 'Added q1_score column';
    ELSE
        RAISE NOTICE 'q1_score column already exists';
    END IF;
END
;

-- Add q2_score if missing
DO 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_assessments' AND column_name = 'q2_score'
    ) THEN
        ALTER TABLE user_assessments ADD COLUMN q2_score INTEGER NOT NULL DEFAULT 0;
        RAISE NOTICE 'Added q2_score column';
    ELSE
        RAISE NOTICE 'q2_score column already exists';
    END IF;
END
;

-- Add combined_score if missing
DO 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_assessments' AND column_name = 'combined_score'
    ) THEN
        ALTER TABLE user_assessments ADD COLUMN combined_score INTEGER NOT NULL DEFAULT 0;
        RAISE NOTICE 'Added combined_score column';
    ELSE
        RAISE NOTICE 'combined_score column already exists';
    END IF;
END
;

-- Add physical_percentage if missing
DO 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_assessments' AND column_name = 'physical_percentage'
    ) THEN
        ALTER TABLE user_assessments ADD COLUMN physical_percentage INTEGER NOT NULL DEFAULT 0;
        RAISE NOTICE 'Added physical_percentage column';
    ELSE
        RAISE NOTICE 'physical_percentage column already exists';
    END IF;
END
;

-- Add emotional_percentage if missing
DO 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_assessments' AND column_name = 'emotional_percentage'
    ) THEN
        ALTER TABLE user_assessments ADD COLUMN emotional_percentage INTEGER NOT NULL DEFAULT 0;
        RAISE NOTICE 'Added emotional_percentage column';
    ELSE
        RAISE NOTICE 'emotional_percentage column already exists';
    END IF;
END
;

-- Add questionnaire_version_id if missing
DO 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_assessments' AND column_name = 'questionnaire_version_id'
    ) THEN
        ALTER TABLE user_assessments ADD COLUMN questionnaire_version_id UUID NOT NULL DEFAULT gen_random_uuid();
        RAISE NOTICE 'Added questionnaire_version_id column';
    ELSE
        RAISE NOTICE 'questionnaire_version_id column already exists';
    END IF;
END
;

-- Add answers if missing (JSONB for better performance)
DO 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_assessments' AND column_name = 'answers'
    ) THEN
        ALTER TABLE user_assessments ADD COLUMN answers JSONB NOT NULL DEFAULT '{}'::jsonb;
        CREATE INDEX ix_user_assessments_answers ON user_assessments USING gin(answers);
        RAISE NOTICE 'Added answers column';
    ELSE
        RAISE NOTICE 'answers column already exists';
    END IF;
END
;

-- Add completed_at if missing
DO 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_assessments' AND column_name = 'completed_at'
    ) THEN
        ALTER TABLE user_assessments ADD COLUMN completed_at TIMESTAMP DEFAULT NOW();
        CREATE INDEX ix_user_assessments_completed_at ON user_assessments(completed_at);
        RAISE NOTICE 'Added completed_at column';
    ELSE
        RAISE NOTICE 'completed_at column already exists';
    END IF;
END
;

-- Commit changes
COMMIT;

-- Verify final structure
\d user_assessments;

-- Show sample of data (if any)
SELECT COUNT(*) as total_assessments FROM user_assessments;

-- Success message
\echo ''
\echo 'âœ… Schema fix complete! All columns have been added.'
\echo ''
