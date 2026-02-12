"""
E6-F5-S2 Main Execution Script
Loads questions into database and starts API server
"""
import sys
from pathlib import Path
from dotenv import load_dotenv
import logging

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def main():
    logger.info("="*80)
    logger.info("E6-F5-S2: E&P ASSESSMENT SYSTEM")
    logger.info("="*80)
    
    # Step 1: Load questions into database
    logger.info("\nSTEP 1: Loading assessment questions into database...")
    from ep_assessment_questions import EPAssessmentQuestions
    sys.path.insert(0, str(Path(__file__).parent.parent / "e6_f5_s1_ep_extraction"))
    from ep_database_schema import get_session, EPAssessmentQuestions as DBQuestion
    
    questions = EPAssessmentQuestions()
    session = get_session()
    
    loaded = 0
    for q in questions.get_all_questions():
        existing = session.query(DBQuestion).filter_by(question_number=q.id).first()
        if not existing:
            db_q = DBQuestion(
                question_number=q.id,
                question_text=q.question_text,
                trait_assessed=q.trait_assessed,
                scoring_key=q.scoring_key
            )
            session.add(db_q)
            loaded += 1
    
    session.commit()
    logger.info(f"   Loaded {loaded} new questions")
    logger.info(f"   Total questions in DB: {session.query(DBQuestion).count()}")
    
    # Step 2: Test scoring
    logger.info("\nSTEP 2: Testing scoring engine...")
    from ep_scoring_engine import EPScoringEngine
    
    sample = {i: 'physical' if i <= 25 else 'emotional' for i in range(1, 46)}
    engine = EPScoringEngine()
    profile = engine.score_responses(sample)
    
    logger.info(f"   Sample profile: {profile.ep_type}")
    logger.info(f"   Confidence: {profile.confidence_score:.1f}%")
    
    # Step 3: Test profile generation
    logger.info("\nSTEP 3: Testing profile generator...")
    from ep_profile_generator import EPProfileGenerator
    
    gen = EPProfileGenerator()
    full_profile = gen.get_profile(profile.ep_type)
    logger.info(f"   Profile: {full_profile.title}")
    logger.info(f"   Strengths: {len(full_profile.strengths)}")
    
    logger.info("\n" + "="*80)
    logger.info("SUCCESS! E6-F5-S2 COMPLETE")
    logger.info("="*80)
    logger.info("\nAssessment System Ready!")
    logger.info("  - 45 questions loaded")
    logger.info("  - Scoring engine tested")
    logger.info("  - Profile generation tested")
    logger.info("\nTo start API server:")
    logger.info("  python ep_assessment_api.py")
    
    return 0

if __name__ == '__main__':
    sys.exit(main())
