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
