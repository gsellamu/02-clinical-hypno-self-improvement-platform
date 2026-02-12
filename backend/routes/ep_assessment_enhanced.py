"""
E&P Assessment Enhanced API Routes
Includes quality metrics, clinical review, and analytics endpoints
"""
from fastapi import APIRouter, Depends, HTTPException, Query, Body
from sqlalchemy.orm import Session
from typing import Optional, List
from pydantic import BaseModel, Field

from database import get_db
from auth import get_current_user, require_role
from services.ep_assessment_service_enhanced import EPAssessmentServiceEnhanced
from schemas.assessment import AssessmentResult, QualityStatistics


router = APIRouter(prefix="/api/v1/ep-assessment", tags=["E&P Assessment Enhanced"])


# ============================================================================
# Request/Response Models
# ============================================================================

class SubmitAssessmentRequest(BaseModel):
    """Request model for submitting assessment"""
    answers: dict = Field(..., description="36 question answers")
    session_id: Optional[str] = Field(None, description="Optional VR session ID")
    time_to_complete: Optional[int] = Field(None, description="Time in seconds")
    
    class Config:
        json_schema_extra = {
            "example": {
                "answers": {"1": True, "2": False, "3": True},
                "session_id": "uuid-here",
                "time_to_complete": 240
            }
        }


class FlagReviewRequest(BaseModel):
    """Request to flag assessment for review"""
    reason: str = Field(..., description="Reason for flagging")


class MarkReviewedRequest(BaseModel):
    """Request to mark assessment as reviewed"""
    notes: Optional[str] = Field(None, description="Review notes")
    approved: bool = Field(True, description="Approved or rejected")


# ============================================================================
# Assessment Endpoints
# ============================================================================

@router.post("/submit", response_model=AssessmentResult)
async def submit_assessment(
    request: SubmitAssessmentRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Submit E&P Suggestibility Assessment
    Automatically calculates quality metrics and flags suspicious patterns
    """
    if len(request.answers) != 36:
        raise HTTPException(400, f"Expected 36 answers, got {len(request.answers)}")
    
    service = EPAssessmentServiceEnhanced(db)
    
    try:
        result = service.save_assessment(
            user_id=current_user["id"],
            answers=request.answers,
            session_id=request.session_id,
            time_to_complete=request.time_to_complete
        )
        
        return result
        
    except ValueError as e:
        raise HTTPException(400, str(e))
    except Exception as e:
        raise HTTPException(500, f"Error saving assessment: {str(e)}")


@router.get("/results/latest", response_model=AssessmentResult)
async def get_latest_assessment(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's most recent assessment with quality metrics"""
    service = EPAssessmentServiceEnhanced(db)
    
    assessments = service.get_user_assessment_history(current_user["id"], limit=1)
    
    if not assessments:
        raise HTTPException(404, "No assessments found")
    
    return assessments[0]


@router.get("/results", response_model=List[AssessmentResult])
async def get_assessment_history(
    limit: int = Query(10, ge=1, le=50),
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's assessment history"""
    service = EPAssessmentServiceEnhanced(db)
    return service.get_user_assessment_history(current_user["id"], limit)


# ============================================================================
# Clinical Review Endpoints
# ============================================================================

@router.post("/{assessment_id}/flag")
async def flag_for_review(
    assessment_id: str,
    request: FlagReviewRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Flag assessment for clinical review"""
    service = EPAssessmentServiceEnhanced(db)
    
    success = service.flag_for_review(
        assessment_id=assessment_id,
        flagged_by=current_user["id"],
        reason=request.reason
    )
    
    if not success:
        raise HTTPException(404, "Assessment not found")
    
    return {"success": True, "message": "Assessment flagged for review"}


@router.post("/{assessment_id}/review")
async def mark_reviewed(
    assessment_id: str,
    request: MarkReviewedRequest,
    current_user: dict = Depends(require_role("clinician")),
    db: Session = Depends(get_db)
):
    """Mark assessment as reviewed (clinicians only)"""
    service = EPAssessmentServiceEnhanced(db)
    
    success = service.mark_reviewed(
        assessment_id=assessment_id,
        reviewer_id=current_user["id"],
        notes=request.notes,
        approved=request.approved
    )
    
    if not success:
        raise HTTPException(404, "Assessment not found")
    
    return {
        "success": True,
        "message": f"Assessment {'approved' if request.approved else 'rejected'}"
    }


@router.get("/pending-reviews", response_model=List[AssessmentResult])
async def get_pending_reviews(
    limit: int = Query(50, ge=1, le=100),
    current_user: dict = Depends(require_role("clinician")),
    db: Session = Depends(get_db)
):
    """Get assessments pending clinical review (clinicians only)"""
    service = EPAssessmentServiceEnhanced(db)
    return service.get_pending_reviews(limit)


# ============================================================================
# Analytics Endpoints
# ============================================================================

@router.get("/analytics/quality")
async def get_quality_statistics(
    days: int = Query(30, ge=1, le=365),
    current_user: dict = Depends(require_role("admin")),
    db: Session = Depends(get_db)
):
    """
    Get quality statistics for assessments
    Shows confidence scores, patterns, and flagged assessments
    """
    service = EPAssessmentServiceEnhanced(db)
    return service.get_quality_statistics(days)


@router.get("/communication-preferences")
async def get_communication_preferences(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get AI communication preferences based on user's suggestibility type
    Used by AI agents to personalize language patterns
    """
    service = EPAssessmentServiceEnhanced(db)
    return service.get_communication_preferences(current_user["id"])
