# Complete E&P Assessment Schema Fix

## ðŸ”´ THE PROBLEM

Your database table is missing **MULTIPLE columns**. We've seen:
1. âŒ session_id missing
2. âŒ suggestibility_type missing
3. Likely MORE columns are missing too!

The Python code expects 12 columns, but your database only has some of them.

## ðŸ” STEP 1: Audit Your Schema

First, let's see exactly what's missing:

```bash
cd backend
python scripts/audit_schema.py
```

This will show you:
- âœ… Columns that exist
- âŒ Columns that are missing
-  Extra columns (if any)

## âœ… STEP 2: Fix Everything At Once

### Option A: Quick SQL Fix (Recommended)

Run this single SQL script that adds ALL missing columns:

```bash
psql -h localhost -U your_user -d your_database -f backend/complete_schema_fix.sql
```

**For Supabase:**
1. Go to SQL Editor
2. Copy/paste contents of complete_schema_fix.sql
3. Execute

This script is SAFE - it checks each column before adding, so it won't break if some columns already exist.

### Option B: Create Tables from Scratch

If you want to start fresh ( THIS DELETES ALL DATA):

```bash
psql -h localhost -U your_user -d your_database -f backend/create_assessments_table.sql
```

### Option C: Use Alembic Migration

If you're using Alembic for version control:

```bash
cd backend
alembic upgrade head
```

## ðŸ“‹ Expected Schema

After fixing, your user_assessments table should have:

```sql
CREATE TABLE user_assessments (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    session_id UUID NULL,
    questionnaire_version_id UUID NOT NULL,
    q1_score INTEGER NOT NULL,
    q2_score INTEGER NOT NULL,
    combined_score INTEGER NOT NULL,
    physical_percentage INTEGER NOT NULL,
    emotional_percentage INTEGER NOT NULL,
    suggestibility_type VARCHAR(100) NOT NULL,
    answers JSONB NOT NULL,
    completed_at TIMESTAMP DEFAULT NOW()
);
```

## ðŸ§ª STEP 3: Verify the Fix

After running the fix, verify it worked:

```bash
# Check table structure
psql -c "\d user_assessments"

# Or run audit again
python scripts/audit_schema.py
```

You should see **ALL 12 columns** listed.

## ðŸš€ STEP 4: Test Your Application

Restart your FastAPI backend and test:

```bash
curl -X POST http://localhost:8000/api/v1/ep-assessment/submit \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d @test_assessment.json
```

## ðŸ“Š What Each Column Does

| Column | Type | Purpose |
|--------|------|---------|
| id | UUID | Unique assessment ID |
| user_id | UUID | User who took assessment |
| session_id | UUID | Optional VR session tracking |
| questionnaire_version_id | UUID | Which version of questionnaire |
| q1_score | INT | Physical Suggestibility score (0-100) |
| q2_score | INT | Emotional Suggestibility score (0-100) |
| combined_score | INT | Total score (0-200) |
| physical_percentage | INT | % Physical (0-100) |
| emotional_percentage | INT | % Emotional (0-100) |
| suggestibility_type | VARCHAR | Classification result |
| nswers | JSONB | All 36 question answers |
| completed_at | TIMESTAMP | When assessment was completed |

## ðŸ”§ Troubleshooting

### Still Getting Errors?

1. **Check you ran the fix:**
   ```bash
   python scripts/audit_schema.py
   ```

2. **Verify database connection:**
   - Check your DATABASE_URL environment variable
   - Test connection: psql  -c "\dt"

3. **Check for typos in column names:**
   - Column names are case-sensitive!
   - Make sure there are no trailing spaces

4. **Clear Python cache:**
   ```bash
   find . -type d -name __pycache__ -exec rm -r {} +
   find . -name "*.pyc" -delete
   ```

5. **Restart everything:**
   ```bash
   # Stop backend
   # Re-run migration
   # Start backend
   ```

### Error: "relation does not exist"

The user_assessments table doesn't exist at all. Use:
```bash
psql -f backend/create_assessments_table.sql
```

### Error: "column already exists"

This is FINE! The fix script checks before adding. Just means you already fixed that column.

## ðŸ“‚ Files Created

| File | Purpose |
|------|---------|
| scripts/audit_schema.py | Check what columns are missing |
| complete_schema_fix.sql | Add all missing columns safely |
| create_assessments_table.sql | Create tables from scratch |
| lembic/versions/TIMESTAMP_complete_ep_assessment_schema.py | Alembic migration |

## ðŸŽ¯ Next Steps

After fixing:

1. âœ… Test assessment submission
2. âœ… Verify AI agents can read communication preferences
3. âœ… Update any other services that use this table
4. âœ… Document your schema in your wiki/docs

## ðŸ’¡ Prevention

To avoid this in the future:

1. **Use migrations** - Always use Alembic for schema changes
2. **Version control** - Commit migrations to git
3. **Test locally first** - Never run migrations directly in production without testing
4. **Keep models in sync** - If you change Python models, create a migration

## ðŸ†˜ Still Stuck?

If you're still seeing errors after following all steps:

1. Share the output of python scripts/audit_schema.py
2. Share the exact error message
3. Share your database type (PostgreSQL? Supabase? Version?)
4. Check if there are any database migrations pending

---

**Ready to fix it? Start with the schema audit!**

```bash
python backend/scripts/audit_schema.py
```
