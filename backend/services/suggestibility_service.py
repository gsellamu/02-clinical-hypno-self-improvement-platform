"""
Business logic for E and P Suggestibility Assessment
"""
from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import Dict, Optional, List
from uuid import UUID, uuid4
from datetime import datetime
import json

from models.questionnaire_models import (
    AssessmentSubmission,
    AssessmentResult,
    SuggestibilityScores,
    Interpretation,
    QuestionnaireVersion,
    QuestionnaireQuestion,
    TherapeuticApproach
)
from utils.scoring_calculator import (
    SuggestibilityScorer,
    get_answer_breakdown
)


class SuggestibilityService:
    """Service for managing E and P Suggestibility assessments."""
    
    def __init__(self, db: Session):
        self.db = db
        self.scorer = SuggestibilityScorer(db)
    
    def get_questionnaire(
        self,
        version: str = "1.0"
    ) -> QuestionnaireVersion:
        """
        Get active questionnaire with all questions.
        """
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
        
        # Build therapeutic approach
        therapy_data = score_results['interpretation']['therapeutic_approach']
        therapeutic_approach = TherapeuticApproach(**therapy_data)
        
        # Build interpretation
        interp_data = score_results['interpretation'].copy()
        interp_data['therapeutic_approach'] = therapeutic_approach
        interpretation = Interpretation(**interp_data)
        
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
                profile,
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
                :profile,
                :answers_json,
                NOW()
            )
        """)
        
        # Convert answers dict to JSON string
        answers_json = json.dumps({str(k): v for k, v in answers.items()})
        
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
                "profile": scores['suggestibility_type'],
                "answers_json": answers_json
            }
        )
        
        self.db.commit()
    
    def get_assessment(
        self,
        assessment_id: UUID
    ) -> Optional[AssessmentResult]:
        """Retrieve saved assessment by ID."""
        
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
                profile,
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
        
        # Extract data
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
            profile,
            answers_json,
            completed_at
        ) = row
        
        # Parse answers
        answers_dict = json.loads(answers_json) if isinstance(answers_json, str) else answers_json
        answers = {int(k): v for k, v in answers_dict.items()}
        
        # Recalculate interpretation
        score_results = self.scorer.calculate_scores(
            answers,
            questionnaire_version_id_str
        )
        
        # Get breakdown
        breakdown = get_answer_breakdown(
            answers,
            self.db,
            questionnaire_version_id_str
        )
        
        # Build objects
        scores = SuggestibilityScores(
            q1_score=q1_score,
            q2_score=q2_score,
            combined_score=combined_score,
            q1_lookup=score_results['q1_lookup'],
            combined_lookup=score_results['combined_lookup'],
            physical_percentage=physical_percentage,
            emotional_percentage=emotional_percentage,
            suggestibility_type=suggestibility_type,
            profile=profile

        )
        
        therapy_data = score_results['interpretation']['therapeutic_approach']
        therapeutic_approach = TherapeuticApproach(**therapy_data)
        
        interp_data = score_results['interpretation'].copy()
        interp_data['therapeutic_approach'] = therapeutic_approach
        interpretation = Interpretation(**interp_data)
        
        result = AssessmentResult(
            assessment_id=id_str,
            user_id=user_id_str if user_id_str else None,
            session_id=session_id,
            questionnaire_version_id=questionnaire_version_id_str,
            scores=scores,
            interpretation=interpretation,
            answer_breakdown=breakdown,
            completed_at=completed_at
        )
        
        return result
