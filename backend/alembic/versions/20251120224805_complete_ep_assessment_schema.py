"""Complete E&P Assessment Schema Migration

Revision ID: 20251120224805
Revises: 
Create Date: 2025-11-20 22:48:05

Adds all missing columns to user_assessments table
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID, JSONB

revision = '20251120224805'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    """Add all missing columns to user_assessments table"""
    
    # Create questionnaire_versions table if it doesn't exist
    op.create_table(
        'questionnaire_versions',
        sa.Column('id', UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('version_name', sa.String(100), nullable=False, unique=True),
        sa.Column('description', sa.String(500)),
        sa.Column('questions', JSONB, nullable=False),
        sa.Column('scoring_rules', JSONB, nullable=False),
        sa.Column('is_active', sa.Integer, default=1),
        sa.Column('created_at', sa.DateTime, server_default=sa.text('NOW()')),
    )
    
    op.create_index('ix_questionnaire_versions_active', 'questionnaire_versions', ['is_active'])
    
    # Create user_assessments table if it doesn't exist
    # (This assumes the table might exist with some columns)
    try:
        op.create_table(
            'user_assessments',
            sa.Column('id', UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
            sa.Column('user_id', UUID(as_uuid=True), nullable=False),
            sa.Column('session_id', UUID(as_uuid=True), nullable=True),
            sa.Column('questionnaire_version_id', UUID(as_uuid=True), nullable=False),
            sa.Column('q1_score', sa.Integer, nullable=False),
            sa.Column('q2_score', sa.Integer, nullable=False),
            sa.Column('combined_score', sa.Integer, nullable=False),
            sa.Column('physical_percentage', sa.Integer, nullable=False),
            sa.Column('emotional_percentage', sa.Integer, nullable=False),
            sa.Column('suggestibility_type', sa.String(100), nullable=False),
            sa.Column('answers', JSONB, nullable=False, server_default='{}'),
            sa.Column('completed_at', sa.DateTime, server_default=sa.text('NOW()')),
            sa.ForeignKeyConstraint(['questionnaire_version_id'], ['questionnaire_versions.id'], ondelete='RESTRICT'),
        )
    except Exception as e:
        # Table might already exist, try to add missing columns
        print(f"Table might exist, adding columns individually: {e}")
        
        # Try to add each column individually (will skip if exists)
        columns_to_add = [
            ('session_id', UUID(as_uuid=True), True),
            ('questionnaire_version_id', UUID(as_uuid=True), False),
            ('q1_score', sa.Integer, False),
            ('q2_score', sa.Integer, False),
            ('combined_score', sa.Integer, False),
            ('physical_percentage', sa.Integer, False),
            ('emotional_percentage', sa.Integer, False),
            ('suggestibility_type', sa.String(100), False),
            ('answers', JSONB, False),
            ('completed_at', sa.DateTime, True),
        ]
        
        for col_name, col_type, nullable in columns_to_add:
            try:
                op.add_column('user_assessments', sa.Column(col_name, col_type, nullable=nullable))
            except Exception:
                pass  # Column already exists
    
    # Create indexes
    indexes = [
        ('ix_user_assessments_user_id', ['user_id']),
        ('ix_user_assessments_session_id', ['session_id']),
        ('ix_user_assessments_completed_at', ['completed_at']),
        ('ix_user_assessments_suggestibility_type', ['suggestibility_type']),
    ]
    
    for index_name, columns in indexes:
        try:
            op.create_index(index_name, 'user_assessments', columns)
        except Exception:
            pass  # Index might already exist


def downgrade():
    """Remove the tables and indexes"""
    op.drop_index('ix_user_assessments_suggestibility_type', 'user_assessments')
    op.drop_index('ix_user_assessments_completed_at', 'user_assessments')
    op.drop_index('ix_user_assessments_session_id', 'user_assessments')
    op.drop_index('ix_user_assessments_user_id', 'user_assessments')
    op.drop_table('user_assessments')
    
    op.drop_index('ix_questionnaire_versions_active', 'questionnaire_versions')
    op.drop_table('questionnaire_versions')
