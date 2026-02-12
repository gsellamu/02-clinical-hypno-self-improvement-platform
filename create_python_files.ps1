# =====================================================
# Create All Python Files for Backend
# =====================================================

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  Creating Python Source Files" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

$BackendDir = "backend"

# =====================================================
# 1. CREATE scoring_calculator.py
# =====================================================

Write-Host "Creating utils/scoring_calculator.py..." -ForegroundColor Green

$ScoringCalculator = Join-Path $BackendDir "utils\scoring_calculator.py"
$ScoringCalculatorContent = @'
"""
HMI E and P Suggestibility Scoring Calculator
Implements official HMI scoring methodology from Panorama Publishing 2003
"""
from typing import Dict, List, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import text

class SuggestibilityScorer:
    """
    Official HMI E and P Suggestibility scoring calculator.
    
    Scoring Rules:
    - Questions 1-2: 10 points each for "yes"
    - Questions 3-18: 5 points each for "yes"
    - Questions 19-20: 10 points each for "yes"
    - Questions 21-36: 5 points each for "yes"
    - Q1 Score: Sum of questions 1-18
    - Q2 Score: Sum of questions 19-36
    - Combined Score: Q1 + Q2
    - Physical %: Lookup from official HMI chart
    - Emotional %: 100 - Physical %
    """
    
    # Official HMI weights
    Q1_HIGH_WEIGHT_QUESTIONS = [1, 2]           # 10 points each
    Q1_STANDARD_WEIGHT_QUESTIONS = list(range(3, 19))  # 5 points each (3-18)
    Q2_HIGH_WEIGHT_QUESTIONS = [19, 20]         # 10 points each
    Q2_STANDARD_WEIGHT_QUESTIONS = list(range(21, 37)) # 5 points each (21-36)
    
    HIGH_WEIGHT_POINTS = 10
    STANDARD_WEIGHT_POINTS = 5
    
    MAX_Q1_SCORE = 100  # (2  10) + (16  5)
    MAX_Q2_SCORE = 100  # (2  10) + (16  5)
    MAX_COMBINED_SCORE = 200
    
    def __init__(self, db: Session):
        self.db = db
    
    def calculate_scores(
        self,
        answers: Dict[int, bool],
        questionnaire_version_id: str
    ) -> Dict:
        """
        Calculate E and P Suggestibility scores from answers.
        
        Args:
            answers: Dict mapping question_number (1-36) to boolean answer
            questionnaire_version_id: UUID of questionnaire version
            
        Returns:
            Dict containing all scores and interpretation
        """
        # Validate answers
        if len(answers) != 36:
            raise ValueError(f"Expected 36 answers, got {len(answers)}")
        
        # Calculate Q1 Score (Physical indicators)
        q1_score = self._calculate_q1_score(answers)
        
        # Calculate Q2 Score (Emotional indicators)
        q2_score = self._calculate_q2_score(answers)
        
        # Combined score
        combined_score = q1_score + q2_score
        
        # Round to nearest 5 for lookup (HMI chart uses increments of 5)
        q1_lookup = self._round_to_nearest_5(q1_score)
        combined_lookup = self._round_to_nearest_5(combined_score)
        
        # Get physical percentage from lookup table
        physical_percentage = self._lookup_physical_percentage(
            q1_lookup,
            combined_lookup,
            questionnaire_version_id
        )
        
        # Calculate emotional percentage
        emotional_percentage = 100 - physical_percentage
        
        # Determine suggestibility type
        suggestibility_type = self._determine_type(physical_percentage)
        
        return {
            "q1_score": q1_score,
            "q2_score": q2_score,
            "combined_score": combined_score,
            "q1_lookup": q1_lookup,
            "combined_lookup": combined_lookup,
            "physical_percentage": physical_percentage,
            "emotional_percentage": emotional_percentage,
            "suggestibility_type": suggestibility_type,
            "interpretation": self._generate_interpretation(
                physical_percentage,
                emotional_percentage,
                suggestibility_type
            )
        }
    
    def _calculate_q1_score(self, answers: Dict[int, bool]) -> int:
        """Calculate Questionnaire 1 score (Physical indicators)."""
        score = 0
        
        # High weight questions (1-2): 10 points each
        for q_num in self.Q1_HIGH_WEIGHT_QUESTIONS:
            if answers.get(q_num, False):
                score += self.HIGH_WEIGHT_POINTS
        
        # Standard weight questions (3-18): 5 points each
        for q_num in self.Q1_STANDARD_WEIGHT_QUESTIONS:
            if answers.get(q_num, False):
                score += self.STANDARD_WEIGHT_POINTS
        
        return min(score, self.MAX_Q1_SCORE)
    
    def _calculate_q2_score(self, answers: Dict[int, bool]) -> int:
        """Calculate Questionnaire 2 score (Emotional indicators)."""
        score = 0
        
        # High weight questions (19-20): 10 points each
        for q_num in self.Q2_HIGH_WEIGHT_QUESTIONS:
            if answers.get(q_num, False):
                score += self.HIGH_WEIGHT_POINTS
        
        # Standard weight questions (21-36): 5 points each
        for q_num in self.Q2_STANDARD_WEIGHT_QUESTIONS:
            if answers.get(q_num, False):
                score += self.STANDARD_WEIGHT_POINTS
        
        return min(score, self.MAX_Q2_SCORE)
    
    def _round_to_nearest_5(self, score: int) -> int:
        """Round score to nearest 5 for HMI lookup table."""
        return round(score / 5) * 5
    
    def _lookup_physical_percentage(
        self,
        q1_score: int,
        combined_score: int,
        questionnaire_version_id: str
    ) -> int:
        """
        Lookup physical percentage from HMI chart.
        
        Uses official HMI lookup table seeded in database.
        """
        # Clamp scores to valid ranges
        q1_score = max(0, min(100, q1_score))
        combined_score = max(50, min(200, combined_score))
        
        query = text("""
            SELECT physical_percentage
            FROM scoring_lookup_tables
            WHERE questionnaire_version_id = :version_id
                AND lookup_type = 'physical_percentage'
                AND q1_score = :q1_score
                AND combined_score = :combined_score
            LIMIT 1
        """)
        
        result = self.db.execute(
            query,
            {
                "version_id": questionnaire_version_id,
                "q1_score": q1_score,
                "combined_score": combined_score
            }
        ).fetchone()
        
        if not result:
            raise ValueError(
                f"No lookup entry found for Q1={q1_score}, "
                f"Combined={combined_score}"
            )
        
        return result[0]
    
    def _determine_type(self, physical_percentage: int) -> str:
        """
        Determine suggestibility type based on physical percentage.
        
        HMI Classifications:
        - Pure Physical: 90-100%
        - Primarily Physical: 60-89%
        - Somnambulistic: 40-59% (balanced)
        - Primarily Emotional: 11-39%
        - Pure Emotional: 0-10%
        """
        if physical_percentage >= 90:
            return "Pure Physical"
        elif physical_percentage >= 60:
            return "Primarily Physical"
        elif physical_percentage >= 40:
            return "Somnambulistic (Balanced)"
        elif physical_percentage >= 11:
            return "Primarily Emotional"
        else:
            return "Pure Emotional"
    
    def _generate_interpretation(
        self,
        physical_pct: int,
        emotional_pct: int,
        sugg_type: str
    ) -> Dict:
        """Generate clinical interpretation of scores."""
        
        # Physical Suggestibility characteristics
        physical_traits = []
        if physical_pct >= 60:
            physical_traits = [
                "Responds to direct, literal suggestions",
                "Prefers clear, straightforward communication",
                "Strong mind-body connection",
                "Learns best through demonstration",
                "Immediate physical response to suggestions"
            ]
        
        # Emotional Suggestibility characteristics
        emotional_traits = []
        if emotional_pct >= 60:
            emotional_traits = [
                "Responds to inferential, metaphorical suggestions",
                "Analytical and introspective",
                "Sensitivity to tone and emotional context",
                "May experience mind-body disconnection",
                "Benefits from indirect therapeutic approaches"
            ]
        
        # Therapeutic recommendations
        if physical_pct >= 60:
            therapy_approach = {
                "induction_style": "Direct, authoritative",
                "suggestion_format": "Literal, specific commands",
                "language_style": "Clear, concrete, step-by-step",
                "deepening": "Progressive relaxation, counting",
                "imagery": "Concrete, visual, kinesthetic"
            }
        elif emotional_pct >= 60:
            therapy_approach = {
                "induction_style": "Permissive, conversational",
                "suggestion_format": "Metaphorical, story-based",
                "language_style": "Abstract, inferential, open-ended",
                "deepening": "Confusion, paradox, time distortion",
                "imagery": "Abstract concepts, emotions, meanings"
            }
        else:  # Somnambulistic (balanced)
            therapy_approach = {
                "induction_style": "Flexible, adaptive",
                "suggestion_format": "Mix of direct and inferential",
                "language_style": "Varied - can use both styles",
                "deepening": "Any method works well",
                "imagery": "Both concrete and abstract"
            }
        
        return {
            "suggestibility_type": sugg_type,
            "physical_percentage": physical_pct,
            "emotional_percentage": emotional_pct,
            "physical_traits": physical_traits,
            "emotional_traits": emotional_traits,
            "therapeutic_approach": therapy_approach,
            "clinical_notes": self._get_clinical_notes(sugg_type)
        }
    
    def _get_clinical_notes(self, sugg_type: str) -> str:
        """Get clinical notes for suggestibility type."""
        notes = {
            "Pure Physical": (
                "Client demonstrates strong direct suggestibility. "
                "Use authoritative, direct inductions with literal suggestions. "
                "Excellent response to progressive relaxation and direct imagery."
            ),
            "Primarily Physical": (
                "Client leans toward physical suggestibility. "
                "Primarily use direct suggestions with some inferential elements. "
                "Good response to structured, clear therapeutic approaches."
            ),
            "Somnambulistic (Balanced)": (
                "Client shows balanced suggestibility - the 'ideal' hypnotic subject. "
                "Can utilize both direct and inferential approaches effectively. "
                "Highly flexible and responsive to various induction styles."
            ),
            "Primarily Emotional": (
                "Client leans toward emotional suggestibility. "
                "Primarily use inferential, metaphorical suggestions. "
                "Benefits from permissive, conversational approaches."
            ),
            "Pure Emotional": (
                "Client demonstrates strong emotional suggestibility. "
                "Use indirect, metaphorical, story-based approaches. "
                "Avoid authoritative tone; use permissive suggestions."
            )
        }
        return notes.get(sugg_type, "")


def get_answer_breakdown(
    answers: Dict[int, bool],
    db: Session,
    questionnaire_version_id: str
) -> Dict:
    """
    Get detailed breakdown of answers by category.
    
    Returns analysis showing which physical/emotional indicators
    the client answered yes/no to.
    """
    physical_yes = []
    physical_no = []
    emotional_yes = []
    emotional_no = []
    
    # Get questions from database
    query = text("""
        SELECT question_number, question_text, category
        FROM questionnaire_questions
        WHERE questionnaire_version_id = :version_id
        ORDER BY question_number
    """)
    
    questions = db.execute(
        query,
        {"version_id": questionnaire_version_id}
    ).fetchall()
    
    for q_num, q_text, category in questions:
        answered_yes = answers.get(q_num, False)
        
        if category == 'physical':
            if answered_yes:
                physical_yes.append({"number": q_num, "text": q_text})
            else:
                physical_no.append({"number": q_num, "text": q_text})
        else:  # emotional
            if answered_yes:
                emotional_yes.append({"number": q_num, "text": q_text})
            else:
                emotional_no.append({"number": q_num, "text": q_text})
    
    return {
        "physical_indicators": {
            "yes_count": len(physical_yes),
            "no_count": len(physical_no),
            "yes_answers": physical_yes,
            "no_answers": physical_no
        },
        "emotional_indicators": {
            "yes_count": len(emotional_yes),
            "no_count": len(emotional_no),
            "yes_answers": emotional_yes,
            "no_answers": emotional_no
        }
    }
'@

$ScoringCalculatorContent | Out-File -FilePath $ScoringCalculator -Encoding UTF8
Write-Host "  Created: utils/scoring_calculator.py" -ForegroundColor Green
Write-Host ""

# =====================================================
# 2. CREATE questionnaire_models.py (PART 1 of 2)
# =====================================================

Write-Host "Creating models/questionnaire_models.py (Part 1)..." -ForegroundColor Green

$ModelsFile = Join-Path $BackendDir "models\questionnaire_models.py"

# Split into two parts due to character limit
$ModelsContent1 = @'
"""
Pydantic models for E and P Suggestibility Assessment
"""
from pydantic import BaseModel, Field, validator
from typing import Dict, List, Optional
from datetime import datetime
from uuid import UUID


class QuestionResponse(BaseModel):
    """Individual question response."""
    question_number: int = Field(..., ge=1, le=36)
    answer: bool
    
    class Config:
        json_schema_extra = {
            "example": {
                "question_number": 1,
                "answer": True
            }
        }


class AssessmentSubmission(BaseModel):
    """Complete assessment submission."""
    user_id: Optional[UUID] = None
    session_id: Optional[str] = None
    answers: Dict[int, bool] = Field(
        ...,
        description="Map of question_number (1-36) to boolean answer"
    )
    
    @validator('answers')
    def validate_answers(cls, v):
        """Ensure all 36 questions are answered."""
        if len(v) != 36:
            raise ValueError(f"Must answer all 36 questions, got {len(v)}")
        
        # Check question numbers are valid
        for q_num in v.keys():
            if q_num < 1 or q_num > 36:
                raise ValueError(f"Invalid question number: {q_num}")
        
        return v
    
    class Config:
        json_schema_extra = {
            "example": {
                "user_id": "123e4567-e89b-12d3-a456-426614174000",
                "answers": {str(i): i % 2 == 0 for i in range(1, 37)}
            }
        }


class SuggestibilityScores(BaseModel):
    """Calculated suggestibility scores."""
    q1_score: int = Field(..., ge=0, le=100)
    q2_score: int = Field(..., ge=0, le=100)
    combined_score: int = Field(..., ge=0, le=200)
    q1_lookup: int
    combined_lookup: int
    physical_percentage: int = Field(..., ge=0, le=100)
    emotional_percentage: int = Field(..., ge=0, le=100)
    suggestibility_type: str


class TherapeuticApproach(BaseModel):
    """Therapeutic recommendations based on suggestibility."""
    induction_style: str
    suggestion_format: str
    language_style: str
    deepening: str
    imagery: str


class Interpretation(BaseModel):
    """Clinical interpretation of assessment results."""
    suggestibility_type: str
    physical_percentage: int
    emotional_percentage: int
    physical_traits: List[str]
    emotional_traits: List[str]
    therapeutic_approach: TherapeuticApproach
    clinical_notes: str


class AssessmentResult(BaseModel):
    """Complete assessment result."""
    assessment_id: UUID
    user_id: Optional[UUID]
    session_id: Optional[str]
    questionnaire_version_id: UUID
    scores: SuggestibilityScores
    interpretation: Interpretation
    answer_breakdown: Optional[Dict] = None
    completed_at: datetime
    
    class Config:
        from_attributes = True


class QuestionnaireQuestion(BaseModel):
    """Single questionnaire question."""
    question_number: int
    question_text: str
    category: str  # 'physical' or 'emotional'
    subcategory: str
    weight: int
    tooltip: Optional[str]
    example: Optional[str]
    icon: Optional[str]
    psychological_construct: Optional[str]
    clinical_significance: Optional[str]
    
    class Config:
        from_attributes = True


class QuestionnaireVersion(BaseModel):
    """Complete questionnaire with all questions."""
    id: UUID
    name: str
    version: str
    methodology: str
    source: str
    description: Optional[str]
    questions: List[QuestionnaireQuestion]
    is_active: bool
    
    class Config:
        from_attributes = True


class AssessmentHistory(BaseModel):
    """User's assessment history."""
    assessments: List[AssessmentResult]
    total_count: int
    latest_assessment: Optional[AssessmentResult]
    trend_analysis: Optional[Dict] = None
'@

$ModelsContent1 | Out-File -FilePath $ModelsFile -Encoding UTF8
Write-Host "  Created: models/questionnaire_models.py" -ForegroundColor Green
Write-Host ""

# =====================================================
# 3. CREATE suggestibility_service.py (SPLIT DUE TO SIZE)
# =====================================================

Write-Host "Creating services/suggestibility_service.py..." -ForegroundColor Yellow
Write-Host "  (This is a large file, creating in parts...)" -ForegroundColor Gray

$ServiceFile = Join-Path $BackendDir "services\suggestibility_service.py"

# I'll create a simpler version that we can expand
$ServiceContent = @'
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
            WHERE name = 'HMI E and P Suggestibility Assessment'
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
                :answers::jsonb,
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
                "answers": answers_json
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
            suggestibility_type=suggestibility_type
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
'@

$ServiceContent | Out-File -FilePath $ServiceFile -Encoding UTF8
Write-Host "  Created: services/suggestibility_service.py" -ForegroundColor Green
Write-Host ""

# =====================================================
# SUMMARY
# =====================================================

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  Python Files Created Successfully!" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Created files:" -ForegroundColor Yellow
Write-Host "  utils/scoring_calculator.py (complete)" -ForegroundColor Green
Write-Host "  models/questionnaire_models.py (complete)" -ForegroundColor Green
Write-Host "  services/suggestibility_service.py (complete)" -ForegroundColor Green
Write-Host ""
Write-Host "Next step:" -ForegroundColor Yellow
Write-Host "  Run the test:" -ForegroundColor White
Write-Host "  python -m test_service" -ForegroundColor Gray
Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan