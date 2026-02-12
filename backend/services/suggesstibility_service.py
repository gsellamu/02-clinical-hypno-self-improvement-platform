"""
Business logic for E&P Suggestibility Assessment
"""
from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import Dict, Optional
from uuid import UUID, uuid4
from datetime import datetime

from ..models.questionnaire_models import (
    AssessmentSubmission,
    AssessmentResult,
    SuggestibilityScores,
    Interpretation,
    QuestionnaireVersion,
    QuestionnaireQuestion
)
from ..utils.scoring_calculator import (
    SuggestibilityScorer,
    get_answer_breakdown
)


class SuggestibilityService:
    """Service for managing E&P Suggestibility assessments."""
    
    def __init__(self, db: Session):
        self.db = db
        self.scorer = SuggestibilityScorer(db)
    
    def get_questionnaire(
        self,
        version: str = "1.0"
    ) -> QuestionnaireVersion:
        """
        Get active questionnaire with all questions.
        
        Args:
            version: Questionnaire version (default: "1.0")
            
        Returns:
            Complete questionnaire with questions
        """
        # Get questionnaire version
        query = text("""
            SELECT id, name, version, methodology, source, description, is_active
            FROM questionnaire_versions
            WHERE name = 'HMI E&P Suggestibility Assessment'
                AND version = :version
                AND is_active = true
            LIMIT 1
        """)
        
        version_row = self.db.execute(
            query,
            {"version": version}
        ).fetchone()
        
        if not version_row:
            raise ValueError(f"Questionnaire version {version} not found")
        
        version_id = version_row[0]
        
        # Get all questions
        questions_query = text("""
            SELECT 
                question_number,
                question_text,
                category,
                subcategory,
                weight,
                tooltip,
                example,
                icon,
                psychological_construct,
                clinical_significance
            FROM questionnaire_questions
            WHERE questionnaire_version_id = :version_id
            ORDER BY question_number
        """)
        
        questions_rows = self.db.execute(
            questions_query,
            {"version_id": version_id}
        ).fetchall()
        
        questions = [
            QuestionnaireQuestion(
                question_number=row[0],
                question_text=row[1],
                category=row[2],
                subcategory=row[3],
                weight=row[4],
                tooltip=row[5],
                example=row[6],
                icon=row[7],
                psychological_construct=row[8],
                clinical_significance=row[9]
            )
            for row in questions_rows
        ]
        
        return QuestionnaireVersion(
            id=version_id,
            name=version_row[1],
            version=version_row[2],
            methodology=version_row[3],
            source=version_row[4],
            description=version_row[5],
            is_active=version_row[6],
            questions=questions
        )
    
    def submit_assessment(
        self,
        submission: AssessmentSubmission
    ) -> AssessmentResult:
        """
        Process assessment submission and calculate results.
        
        Args:
            submission: User's assessment answers
            
        Returns:
            Complete assessment results with interpretation
        """
        # Get questionnaire version
        questionnaire = self.get_questionnaire()
        
        # Calculate scores
        score_results = self.scorer.calculate_scores(
            submission.answers,
            str(questionnaire.id)
        )
        
        # Get answer breakdown
        breakdown = get_answer_breakdown(
            submission.answers,
            self.db,
            str(questionnaire.id)
        )
        
        # Generate assessment ID
        assessment_id = uuid4()
        
        # Save to database
        self._save_assessment(
            assessment_id=assessment_id,
            user_id=submission.user_id,
            session_id=submission.session_id,
            questionnaire_version_id=questionnaire.id,
            answers=submission.answers,
            scores=score_results
        )
        
        # Build result
        scores = SuggestibilityScores(**score_results)
        interpretation = Interpretation(**score_results['interpretation'])
        
        result = AssessmentResult(
            assessment_id=assessment_id,
            user_id=submission.user_id,
            session_id=submission.session_id,
            questionnaire_version_id=questionnaire.id,
            scores=scores,
            interpretation=interpretation,
            answer_breakdown=breakdown,
            completed_at=datetime.utcnow()
        )
        
        return result
    
    def _save_assessment(
        self,
        assessment_id: UUID,
        user_id: Optional[UUID],
        session_id: Optional[str],
        questionnaire_version_id: UUID,
        answers: Dict[int, bool],
        scores: Dict
    ):
        """Save assessment results to database."""
        
        # Insert into user_assessments table
        insert_query = text("""
            INSERT INTO user_assessments (
                id,
                user_id,
                session_id,
                questionnaire_version_id,
                q1_score,
                q2_score,
                combined_score,
                physical_percentage,
                emotional_percentage,
                suggestibility_type,
                answers,
                completed_at
            ) VALUES (
                :id,
                :user_id,
                :session_id,
                :questionnaire_version_id,
                :q1_score,
                :q2_score,
                :combined_score,
                :physical_percentage,
                :emotional_percentage,
                :suggestibility_type,
                :answers_json,
                NOW()
            )
        """)
        
        self.db.execute(
            insert_query,
            {
                "id": str(assessment_id),
                "user_id": str(user_id) if user_id else None,
                "session_id": session_id,
                "questionnaire_version_id": str(questionnaire_version_id),
                "q1_score": scores['q1_score'],
                "q2_score": scores['q2_score'],
                "combined_score": scores['combined_score'],
                "physical_percentage": scores['physical_percentage'],
                "emotional_percentage": scores['emotional_percentage'],
                "suggestibility_type": scores['suggestibility_type'],
                "answers_json": str(answers).replace("'", '"')  # Convert to JSON string
            }
        )
        
        self.db.commit()
    
    def get_assessment(
        self,
        assessment_id: UUID
    ) -> Optional[AssessmentResult]:
        """
        Retrieve saved assessment by ID.
    
        Args:
            assessment_id: UUID of the assessment
        
        Returns:
            Complete AssessmentResult or None if not found
        """
        query = text("""
        SELECT 
            id,
            user_id,
            session_id,
            questionnaire_version_id,
            q1_score,
            q2_score,
            combined_score,
            physical_percentage,
            emotional_percentage,
            suggestibility_type,
            answers,
            completed_at
        FROM user_assessments
        WHERE id = :assessment_id
        LIMIT 1
        """)
    
        row = self.db.execute(
        query,
        {"assessment_id": str(assessment_id)}
        ).fetchone()
    
        if not row:
            return None
    
    # Extract data from row
        (
        id_str,
        user_id_str,
        session_id,
        questionnaire_version_id_str,
        q1_score,
        q2_score,
        combined_score,
        physical_percentage,
        emotional_percentage,
        suggestibility_type,
        answers_json,
        completed_at
        ) = row
    
    # Parse answers JSON
        import json
        answers_dict = json.loads(answers_json) if isinstance(answers_json, str) else answers_json
    
    # Convert string keys to integers
        answers = {int(k): v for k, v in answers_dict.items()}
    
    # Recalculate full interpretation (including therapeutic approach, etc.)
        score_results = self.scorer.calculate_scores(
        answers,
        questionnaire_version_id_str
        )
    
    # Get answer breakdown
        breakdown = get_answer_breakdown(
        answers,
        self.db,
        questionnaire_version_id_str
        )
    
    # Build SuggestibilityScores object
        scores = SuggestibilityScores(
        q1_score=q1_score,
        q2_score=q2_score,
        combined_score=combined_score,
        q1_lookup=score_results['q1_lookup'],
        combined_lookup=score_results['combined_lookup'],
        physical_percentage=physical_percentage,
        emotional_percentage=emotional_percentage,
        suggestibility_type=suggestibility_type
        )
    
    # Build Interpretation object
        interpretation = Interpretation(**score_results['interpretation'])
    
    # Build complete result
        result = AssessmentResult(
        assessment_id=UUID(id_str),
        user_id=UUID(user_id_str) if user_id_str else None,
        session_id=session_id,
        questionnaire_version_id=UUID(questionnaire_version_id_str),
        scores=scores,
        interpretation=interpretation,
        answer_breakdown=breakdown,
        completed_at=completed_at
        )
    
        return result


def get_user_assessments(
    self,
    user_id: UUID,
    limit: int = 10,
    offset: int = 0
) -> Dict:
    """
    Get all assessments for a user.
    
    Args:
        user_id: User's UUID
        limit: Max number of results
        offset: Pagination offset
        
    Returns:
        Dict with assessments list and metadata
    """
    # Get total count
    count_query = text("""
        SELECT COUNT(*)
        FROM user_assessments
        WHERE user_id = :user_id
    """)
    
    total_count = self.db.execute(
        count_query,
        {"user_id": str(user_id)}
    ).scalar()
    
    # Get assessments
    query = text("""
        SELECT id
        FROM user_assessments
        WHERE user_id = :user_id
        ORDER BY completed_at DESC
        LIMIT :limit
        OFFSET :offset
    """)
    
    rows = self.db.execute(
        query,
        {
            "user_id": str(user_id),
            "limit": limit,
            "offset": offset
        }
    ).fetchall()
    
    # Fetch full details for each
    assessments = []
    for (assessment_id_str,) in rows:
        assessment = self.get_assessment(UUID(assessment_id_str))
        if assessment:
            assessments.append(assessment)
    
    # Get latest assessment
    latest = assessments[0] if assessments else None
    
    # Calculate trend if multiple assessments exist
    trend_analysis = None
    if len(assessments) > 1:
        trend_analysis = self._calculate_trend(assessments)
    
    return {
        "assessments": assessments,
        "total_count": total_count,
        "latest_assessment": latest,
        "trend_analysis": trend_analysis
    }


def _calculate_trend(self, assessments: List[AssessmentResult]) -> Dict:
    """
    Calculate trend analysis across multiple assessments.
    
    Tracks changes in physical/emotional percentages over time.
    """
    if len(assessments) < 2:
        return None
    
    # Sort by date (oldest first)
    sorted_assessments = sorted(assessments, key=lambda a: a.completed_at)
    
    first = sorted_assessments[0]
    latest = sorted_assessments[-1]
    
    physical_change = (
        latest.scores.physical_percentage - 
        first.scores.physical_percentage
    )
    
    emotional_change = (
        latest.scores.emotional_percentage - 
        first.scores.emotional_percentage
    )
    
    # Determine trend direction
    if abs(physical_change) < 5:
        trend_direction = "stable"
    elif physical_change > 0:
        trend_direction = "more_physical"
    else:
        trend_direction = "more_emotional"
    
    return {
        "total_assessments": len(assessments),
        "first_assessment_date": first.completed_at.isoformat(),
        "latest_assessment_date": latest.completed_at.isoformat(),
        "physical_change": physical_change,
        "emotional_change": emotional_change,
        "trend_direction": trend_direction,
        "average_physical": sum(
            a.scores.physical_percentage for a in sorted_assessments
        ) / len(sorted_assessments),
        "average_emotional": sum(
            a.scores.emotional_percentage for a in sorted_assessments
        ) / len(sorted_assessments)
    }


def main():
    # Initialize service
    service = SuggestibilityService(db)

# Get specific assessment
    assessment = service.get_assessment(
        assessment_id=UUID("123e4567-e89b-12d3-a456-426614174000")
    )

    if assessment:
        print(f"Type: {assessment.interpretation.suggestibility_type}")
        print(f"Physical: {assessment.scores.physical_percentage}%")
        print(f"Emotional: {assessment.scores.emotional_percentage}%")

# Get user's history
    history = service.get_user_assessments(
        user_id=UUID("user-uuid"),
        limit=10
    )

    print(f"Total assessments: {history['total_count']}")
    print(f"Latest: {history['latest_assessment'].interpretation.suggestibility_type}")

    if history['trend_analysis']:
        print(f"Trend: {history['trend_analysis']['trend_direction']}")
    return

if __name__ == "__main__":
    main()


    