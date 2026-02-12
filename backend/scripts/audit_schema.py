"""
Schema Audit Script - Check for missing columns
"""
import psycopg2
from psycopg2.extras import RealDictCursor
import os
from typing import Set, Dict, List


def get_database_url() -> str:
    """Get database URL from environment or config"""
    # Adjust this to match your database configuration
    return os.getenv(
        "DATABASE_URL",
        "postgresql://jeethhypno_user:jeeth2025@localhost:5432/jeethhypno"
    )


def get_actual_columns(cursor, table_name: str) -> Set[str]:
    """Get columns that actually exist in database"""
    cursor.execute(f"""
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = '{table_name}'
        ORDER BY ordinal_position
    """)
    return {row['column_name'] for row in cursor.fetchall()}


def get_expected_columns() -> Set[str]:
    """Columns expected by the Python code"""
    return {
        'id',
        'user_id',
        'session_id',
        'questionnaire_version_id',
        'q1_score',
        'q2_score',
        'combined_score',
        'physical_percentage',
        'emotional_percentage',
        'suggestibility_type',
        'answers',
        'completed_at'
    }


def audit_schema():
    """Audit the schema and report mismatches"""
    conn = psycopg2.connect(get_database_url(), cursor_factory=RealDictCursor)
    cursor = conn.cursor()
    
    try:
        # Check if table exists
        cursor.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_name = 'user_assessments'
            )
        """)
        table_exists = cursor.fetchone()['exists']
        
        if not table_exists:
            print("âŒ Table 'user_assessments' does not exist!")
            print("   You need to run the CREATE TABLE script.")
            return
        
        # Get actual and expected columns
        actual_columns = get_actual_columns(cursor, 'user_assessments')
        expected_columns = get_expected_columns()
        
        # Find differences
        missing_columns = expected_columns - actual_columns
        extra_columns = actual_columns - expected_columns
        
        # Report results
        print("\n" + "="*70)
        print("ðŸ“Š SCHEMA AUDIT RESULTS")
        print("="*70)
        
        print(f"\nâœ… Columns that exist ({len(actual_columns)}):")
        for col in sorted(actual_columns):
            marker = "âœ“" if col in expected_columns else "âš "
            print(f"  {marker} {col}")
        
        if missing_columns:
            print(f"\nâŒ MISSING COLUMNS ({len(missing_columns)}):")
            for col in sorted(missing_columns):
                print(f"  âœ— {col}")
        else:
            print("\nâœ… No missing columns!")
        
        if extra_columns:
            print(f"\nâš ï¸  EXTRA COLUMNS ({len(extra_columns)}):")
            for col in sorted(extra_columns):
                print(f"  + {col}")
        
        print("\n" + "="*70)
        
        # Show column details
        if actual_columns:
            print("\nðŸ“‹ FULL TABLE STRUCTURE:")
            cursor.execute("""
                SELECT 
                    column_name,
                    data_type,
                    is_nullable,
                    column_default
                FROM information_schema.columns
                WHERE table_name = 'user_assessments'
                ORDER BY ordinal_position
            """)
            
            for row in cursor.fetchall():
                nullable = "NULL" if row['is_nullable'] == 'YES' else "NOT NULL"
                default = f" DEFAULT {row['column_default']}" if row['column_default'] else ""
                print(f"  {row['column_name']}: {row['data_type']} {nullable}{default}")
        
        return {
            'missing': missing_columns,
            'extra': extra_columns,
            'actual': actual_columns
        }
        
    finally:
        cursor.close()
        conn.close()


if __name__ == "__main__":
    audit_schema()
