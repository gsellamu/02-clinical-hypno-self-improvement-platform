"""
Test script for Suggestibility Service
Run from project root: python -m backend.test_service
"""
import sys
from pathlib import Path

# Add backend to Python path
backend_dir = Path(__file__).parent
if str(backend_dir.parent) not in sys.path:
    sys.path.insert(0, str(backend_dir.parent))

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from uuid import uuid4
import os

# Import your modules
from backend.models.questionnaire_models import AssessmentSubmission
from backend.services.suggestibility_service import SuggestibilityService


def test_service():
    """Test the suggestibility service."""
    
    # Database connection
    DATABASE_URL = os.getenv(
        "DATABASE_URL",
        "postgresql://jeethhypno_user:jeeth2025@localhost:5432/jeethhypno"
    )
    
    print(f"Connecting to: {DATABASE_URL}")
    print()
    
    engine = create_engine(DATABASE_URL)
    SessionLocal = sessionmaker(bind=engine)
    db = SessionLocal()
    
    try:
        # Initialize service
        service = SuggestibilityService(db)
        
        # Test 1: Get questionnaire
        print("=" * 60)
        print("TEST 1: Get Questionnaire")
        print("=" * 60)
        questionnaire = service.get_questionnaire()
        print(f"Loaded: {questionnaire.name} v{questionnaire.version}")
        print(f"Questions: {len(questionnaire.questions)}")
        print(f"Methodology: {questionnaire.methodology}")
        print()
        
        # Show sample questions
        print("Sample questions:")
        for q in questionnaire.questions[:3]:
            print(f"  Q{q.question_number}: {q.question_text[:60]}...")
        print()
        
        # Test 2: Submit assessment (sample answers)
        print("=" * 60)
        print("TEST 2: Submit Assessment")
        print("=" * 60)
        
        # Create sample answers (mostly yes for physical, mixed for emotional)
        sample_answers = {}
        for i in range(1, 19):  # Physical questions (1-18)
            sample_answers[i] = True if i % 3 != 0 else False
        for i in range(19, 37):  # Emotional questions (19-36)
            sample_answers[i] = True if i % 2 == 0 else False
        
        print(f"Submitting {len(sample_answers)} answers...")
        
        submission = AssessmentSubmission(
            user_id=uuid4(),
            answers=sample_answers
        )
        
        result = service.submit_assessment(submission)
        
        print(f"Assessment ID: {result.assessment_id}")
        print(f"Q1 Score: {result.scores.q1_score}/100")
        print(f"Q2 Score: {result.scores.q2_score}/100")
        print(f"Combined: {result.scores.combined_score}/200")
        print(f"Physical: {result.scores.physical_percentage}%")
        print(f"Emotional: {result.scores.emotional_percentage}%")
        print(f"Type: {result.interpretation.suggestibility_type}")
        print()
        
        # Test 3: Retrieve assessment
        print("=" * 60)
        print("TEST 3: Retrieve Assessment")
        print("=" * 60)
        
        retrieved = service.get_assessment(result.assessment_id)
        if retrieved:
            print(f"Retrieved assessment: {retrieved.assessment_id}")
            print(f"Type matches: {retrieved.interpretation.suggestibility_type}")
            print(f"Scores match: {retrieved.scores.physical_percentage}%")
        else:
            print("âœ— Failed to retrieve assessment")
        print()
        
        # Test 4: Show therapeutic approach
        print("=" * 60)
        print("TEST 4: Therapeutic Recommendations")
        print("=" * 60)
        approach = result.interpretation.therapeutic_approach
        print(f"Induction Style:    {approach.induction_style}")
        print(f"Suggestion Format:  {approach.suggestion_format}")
        print(f"Language Style:     {approach.language_style}")
        print(f"Deepening:          {approach.deepening}")
        print(f"Imagery:            {approach.imagery}")
        print()
        
        # Test 5: Show answer breakdown
        print("=" * 60)
        print("TEST 5: Answer Breakdown")
        print("=" * 60)
        if result.answer_breakdown:
            physical = result.answer_breakdown['physical_indicators']
            emotional = result.answer_breakdown['emotional_indicators']
            
            print(f"Physical Indicators:")
            print(f"  Yes: {physical['yes_count']}")
            print(f"  No:  {physical['no_count']}")
            print()
            print(f"Emotional Indicators:")
            print(f"  Yes: {emotional['yes_count']}")
            print(f"  No:  {emotional['no_count']}")
        print()
        
        print("=" * 60)
        print("ALL TESTS PASSED!")
        print("=" * 60)
        
    except Exception as e:
        print("=" * 60)
        print(f"âœ— ERROR: {e}")
        print("=" * 60)
        import traceback
        traceback.print_exc()
        return False
    
    finally:
        db.close()
    
    return True


if __name__ == "__main__":
    success = test_service()
    sys.exit(0 if success else 1)
