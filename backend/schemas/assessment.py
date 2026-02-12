"""
E&P Assessment Pydantic Schemas
Request/Response models for API validation
"""
from pydantic import BaseModel, Field, validator
from typing import Optional, List, Dict
from datetime import datetime
from uuid import UUID


# ============================================================================
# REQUEST MODELS
# ============================================================================

class SubmitAssessmentRequest(BaseModel):
    """Request model for submitting E&P assessment"""
    answers: Dict[str, bool] = Field(
        ...,
        description="36 question answers (1-36 as strings, True/False values)",
        example={"1": True, "2": False, "3": True}
    )
    session_id: Optional[str] = Field(
        None,
        description="Optional VR session ID"
    )
    time_to_complete: Optional[int] = Field(
        None,
        ge=0,
        le=7200,
        description="Time to complete in seconds (0-7200)"
    )
    
    @validator('answers')
    def validate_answers(cls, v):
        """Validate that we have exactly 36 answers"""
        if len(v) != 36:
            raise ValueError(f"Expected 36 answers, got {len(v)}")
        
        # Validate keys are 1-36
        required_keys = {str(i) for i in range(1, 37)}
        provided_keys = set(v.keys())
        
        if required_keys != provided_keys:
            missing = required_keys - provided_keys
            extra = provided_keys - required_keys
            error_msg = []
            if missing:
                error_msg.append(f"Missing questions: {sorted(missing)}")
            if extra:
                error_msg.append(f"Extra questions: {sorted(extra)}")
            raise ValueError("; ".join(error_msg))
        
        # Validate all values are boolean
        for key, value in v.items():
            if not isinstance(value, bool):
                raise ValueError(f"Question {key} must be boolean, got {type(value)}")
        
        return v
    
    class Config:
        json_schema_extra = {
            "example": {
                "answers": {str(i): i % 2 == 0 for i in range(1, 37)},
                "session_id": "550e8400-e29b-41d4-a716-446655440000",
                "time_to_complete": 240
            }
        }


class FlagAssessmentRequest(BaseModel):
    """Request to flag assessment for clinical review"""
    reason: str = Field(
        ...,
        min_length=10,
        max_length=500,
        description="Reason for flagging (10-500 characters)"
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "reason": "User reported feeling confused during assessment"
            }
        }


class ReviewAssessmentRequest(BaseModel):
    """Request to mark assessment as reviewed"""
    notes: Optional[str] = Field(
        None,
        max_length=2000,
        description="Clinical review notes (max 2000 characters)"
    )
    approved: bool = Field(
        ...,
        description="Whether assessment is approved or rejected"
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "notes": "Reviewed with patient. Results are valid and clinically appropriate.",
                "approved": True
            }
        }


# ============================================================================
# RESPONSE MODELS
# ============================================================================

class ScoreBreakdown(BaseModel):
    """Assessment scores breakdown"""
    q1_score: int = Field(..., ge=0, le=100, description="Physical Suggestibility score (0-100)")
    q2_score: int = Field(..., ge=0, le=100, description="Emotional Suggestibility score (0-100)")
    combined_score: int = Field(..., ge=0, le=100, description="Combined score (0-100)")
    physical_percentage: int = Field(..., ge=0, le=100, description="Physical percentage")
    emotional_percentage: int = Field(..., ge=0, le=100, description="Emotional percentage")
    suggestibility_type: str = Field(..., description="Classification type")
    
    class Config:
        json_schema_extra = {
            "example": {
                "q1_score": 70,
                "q2_score": 50,
                "combined_score": 60,
                "physical_percentage": 58,
                "emotional_percentage": 42,
                "suggestibility_type": "Physical Suggestible"
            }
        }


class QualityMetrics(BaseModel):
    """Quality metrics for assessment"""
    confidence_score: float = Field(..., ge=0, le=100, description="Confidence score (0-100)")
    answer_pattern: str = Field(..., description="Detected pattern")
    consistency_score: float = Field(..., ge=0, le=100, description="Consistency score (0-100)")
    completion_percentage: float = Field(..., ge=0, le=100, description="Completion percentage")
    needs_review: bool = Field(..., description="Whether assessment needs review")
    review_reasons: List[str] = Field(default_factory=list, description="Reasons for review")
    
    class Config:
        json_schema_extra = {
            "example": {
                "confidence_score": 85.0,
                "answer_pattern": "balanced",
                "consistency_score": 80.0,
                "completion_percentage": 100.0,
                "needs_review": False,
                "review_reasons": []
            }
        }


class AssessmentResponse(BaseModel):
    """Complete assessment response"""
    assessment_id: str
    user_id: str
    session_id: Optional[str] = None
    questionnaire_version_id: str
    scores: ScoreBreakdown
    quality_metrics: QualityMetrics
    completed_at: datetime
    
    class Config:
        json_schema_extra = {
            "example": {
                "assessment_id": "550e8400-e29b-41d4-a716-446655440000",
                "user_id": "660e8400-e29b-41d4-a716-446655440001",
                "session_id": "770e8400-e29b-41d4-a716-446655440002",
                "questionnaire_version_id": "880e8400-e29b-41d4-a716-446655440003",
                "scores": {
                    "q1_score": 70,
                    "q2_score": 50,
                    "combined_score": 60,
                    "physical_percentage": 58,
                    "emotional_percentage": 42,
                    "suggestibility_type": "Physical Suggestible"
                },
                "quality_metrics": {
                    "confidence_score": 85.0,
                    "answer_pattern": "balanced",
                    "consistency_score": 80.0,
                    "completion_percentage": 100.0,
                    "needs_review": False,
                    "review_reasons": []
                },
                "completed_at": "2025-11-21T12:00:00Z"
            }
        }


class CommunicationPreferences(BaseModel):
    """AI communication preferences based on E&P profile"""
    style: str = Field(..., description="Communication style (physical_suggestible/emotional_suggestible/balanced)")
    tone: str = Field(..., description="Recommended tone")
    use_metaphors: bool = Field(..., description="Whether to use metaphors")
    use_literal: bool = Field(..., description="Whether to use literal language")
    language_pattern: str = Field(..., description="Language pattern description")
    confidence: float = Field(..., ge=0, le=100, description="Assessment confidence")
    assessment_date: Optional[str] = Field(None, description="When assessment was completed")
    warning: Optional[str] = Field(None, description="Warning message if low confidence")
    
    class Config:
        json_schema_extra = {
            "example": {
                "style": "physical_suggestible",
                "tone": "direct and clear",
                "use_metaphors": False,
                "use_literal": True,
                "language_pattern": "literal and step-by-step",
                "confidence": 85.0,
                "assessment_date": "2025-11-21T12:00:00Z",
                "warning": None
            }
        }


class AssessmentHistory(BaseModel):
    """Assessment history item"""
    assessment_id: str
    completed_at: datetime
    suggestibility_type: str
    confidence_score: float
    needs_review: bool
    
    class Config:
        json_schema_extra = {
            "example": {
                "assessment_id": "550e8400-e29b-41d4-a716-446655440000",
                "completed_at": "2025-11-21T12:00:00Z",
                "suggestibility_type": "Physical Suggestible",
                "confidence_score": 85.0,
                "needs_review": False
            }
        }


class QualityStatistics(BaseModel):
    """Quality statistics for assessments"""
    total_assessments: int
    avg_confidence: float
    pattern_distribution: Dict[str, int]
    flagged_for_review: int
    flagged_percentage: float
    period_days: int
    
    class Config:
        json_schema_extra = {
            "example": {
                "total_assessments": 150,
                "avg_confidence": 78.5,
                "pattern_distribution": {
                    "balanced": 120,
                    "all_yes": 5,
                    "all_no": 3,
                    "suspicious": 22
                },
                "flagged_for_review": 30,
                "flagged_percentage": 20.0,
                "period_days": 30
            }
        }


# ============================================================================
# ERROR MODELS
# ============================================================================

class ErrorResponse(BaseModel):
    """Standard error response"""
    error: str = Field(..., description="Error type")
    message: str = Field(..., description="Error message")
    details: Optional[Dict] = Field(None, description="Additional error details")
    
    class Config:
        json_schema_extra = {
            "example": {
                "error": "ValidationError",
                "message": "Expected 36 answers, got 35",
                "details": {"missing_questions": ["36"]}
            }
        }
