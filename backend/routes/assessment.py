"""
E&P Assessment API Routes
Complete REST API for E&P Suggestibility Assessment System
"""
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from typing import List, Optional
import logging

from database import get_db
from auth.dependencies import get_current_user, require_role
from services.ep_assessment_service_enhanced import EPAssessmentServiceEnhanced
from schemas.assessment import (
    SubmitAssessmentRequest,
    AssessmentResponse,
    CommunicationPreferences,
    AssessmentHistory,
    FlagAssessmentRequest,
    ReviewAssessmentRequest,
    QualityStatistics,
    ErrorResponse
)


logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api/v1/assessment",
    tags=["E&P Assessment"],
    responses={
        401: {"description": "Unauthorized", "model": ErrorResponse},
        403: {"description": "Forbidden", "model": ErrorResponse},
        404: {"description": "Not Found", "model": ErrorResponse},
        500: {"description": "Internal Server Error", "model": ErrorResponse}
    }
)


# ============================================================================
# CORE ASSESSMENT ENDPOINTS
# ============================================================================

@router.post(
    "/ep/submit",
    response_model=AssessmentResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Submit E&P Assessment",
    description="""
    Submit E&P Suggestibility Assessment with 36 question answers.
    
    The system will:
    - Calculate Physical vs Emotional suggestibility scores
    - Determine suggestibility type (Physical/Emotional/Balanced)
    - Calculate quality metrics (confidence, pattern detection)
    - Auto-flag suspicious assessments for clinical review
    - Update user profile with results
    
    **Required:** All 36 questions (1-36) must be answered with boolean values.
    
    **Optional:** Provide completion time for better quality scoring.
    """
)
async def submit_assessment(
    request: SubmitAssessmentRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Submit new E&P assessment"""
    try:
        service = EPAssessmentServiceEnhanced(db)
        
        result = service.save_assessment(
            user_id=current_user["id"],
            answers=request.answers,
            session_id=request.session_id,
            time_to_complete=request.time_to_complete
        )
        
        logger.info(f"Assessment submitted: user={current_user['id']}, profile={result.scores.suggestibility_type}")
        
        return AssessmentResponse(
            assessment_id=str(result.assessment_id),
            user_id=str(result.user_id),
            session_id=str(result.session_id) if result.session_id else None,
            questionnaire_version_id=str(result.questionnaire_version_id),
            scores=result.scores,
            quality_metrics=result.quality_metrics,
            completed_at=result.completed_at
        )
        
    except ValueError as e:
        logger.error(f"Validation error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        logger.error(f"Error submitting assessment: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error processing assessment"
        )


@router.get(
    "/ep/results/latest",
    response_model=AssessmentResponse,
    summary="Get Latest Assessment",
    description="Retrieve user's most recent E&P assessment with complete results."
)
async def get_latest_assessment(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's most recent assessment"""
    try:
        service = EPAssessmentServiceEnhanced(db)
        assessments = service.get_user_assessment_history(current_user["id"], limit=1)
        
        if not assessments:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="No assessments found for this user"
            )
        
        result = assessments[0]
        
        return AssessmentResponse(
            assessment_id=str(result.assessment_id),
            user_id=str(result.user_id),
            session_id=str(result.session_id) if result.session_id else None,
            questionnaire_version_id=str(result.questionnaire_version_id),
            scores=result.scores,
            quality_metrics=result.quality_metrics,
            completed_at=result.completed_at
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error retrieving assessment: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error retrieving assessment"
        )


@router.get(
    "/ep/history",
    response_model=List[AssessmentHistory],
    summary="Get Assessment History",
    description="Retrieve user's complete assessment history with quality metrics."
)
async def get_assessment_history(
    limit: int = Query(10, ge=1, le=50, description="Number of assessments to retrieve"),
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's assessment history"""
    try:
        service = EPAssessmentServiceEnhanced(db)
        assessments = service.get_user_assessment_history(current_user["id"], limit)
        
        return [
            AssessmentHistory(
                assessment_id=str(a.assessment_id),
                completed_at=a.completed_at,
                suggestibility_type=a.scores.suggestibility_type,
                confidence_score=a.quality_metrics.confidence_score,
                needs_review=a.quality_metrics.needs_review
            )
            for a in assessments
        ]
        
    except Exception as e:
        logger.error(f"Error retrieving history: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error retrieving assessment history"
        )


# ============================================================================
# AI INTEGRATION ENDPOINT (CRITICAL FOR MULTI-AGENT SYSTEM)
# ============================================================================

@router.get(
    "/ep/communication-preferences",
    response_model=CommunicationPreferences,
    summary="Get AI Communication Preferences",
    description="""
    Get AI communication preferences based on user's E&P profile.
    
    **CRITICAL:** This endpoint is used by ALL AI agents to personalize communication.
    
    Returns:
    - Physical Suggestible â†’ Direct, literal language
    - Emotional Suggestible â†’ Metaphorical, inferential language
    - Balanced â†’ Mix of both styles
    
    Also returns confidence score to determine if results should be trusted.
    """
)
async def get_communication_preferences(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get AI communication preferences
    
    This endpoint is used by:
    - Suggestibility Adapter Agent
    - Script Generation Agent
    - Session Orchestrator
    - All agents in SessionGenerationCrew
    """
    try:
        service = EPAssessmentServiceEnhanced(db)
        prefs = service.get_communication_preferences(current_user["id"])
        
        if prefs.get("confidence", 0) == 0:
            logger.warning(f"No assessment found for user {current_user['id']}")
        
        return CommunicationPreferences(**prefs)
        
    except Exception as e:
        logger.error(f"Error retrieving preferences: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error retrieving communication preferences"
        )


# ============================================================================
# CLINICAL REVIEW ENDPOINTS
# ============================================================================

@router.post(
    "/ep/{assessment_id}/flag",
    status_code=status.HTTP_200_OK,
    summary="Flag Assessment for Review",
    description="Flag an assessment for clinical review with a reason."
)
async def flag_assessment(
    assessment_id: str,
    request: FlagAssessmentRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Flag assessment for clinical review"""
    try:
        service = EPAssessmentServiceEnhanced(db)
        
        success = service.flag_for_review(
            assessment_id=assessment_id,
            flagged_by=current_user["id"],
            reason=request.reason
        )
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Assessment not found"
            )
        
        logger.info(f"Assessment {assessment_id} flagged by {current_user['id']}")
        
        return {
            "success": True,
            "message": "Assessment flagged for review",
            "assessment_id": assessment_id
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error flagging assessment: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error flagging assessment"
        )


@router.post(
    "/ep/{assessment_id}/review",
    status_code=status.HTTP_200_OK,
    summary="Mark Assessment as Reviewed",
    description="Mark assessment as reviewed (clinicians only). Approve or reject with clinical notes."
)
async def review_assessment(
    assessment_id: str,
    request: ReviewAssessmentRequest,
    current_user: dict = Depends(require_role("clinician")),
    db: Session = Depends(get_db)
):
    """Mark assessment as reviewed (clinicians only)"""
    try:
        service = EPAssessmentServiceEnhanced(db)
        
        success = service.mark_reviewed(
            assessment_id=assessment_id,
            reviewer_id=current_user["id"],
            notes=request.notes,
            approved=request.approved
        )
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Assessment not found"
            )
        
        status_text = "approved" if request.approved else "rejected"
        logger.info(f"Assessment {assessment_id} {status_text} by {current_user['id']}")
        
        return {
            "success": True,
            "message": f"Assessment {status_text}",
            "assessment_id": assessment_id,
            "status": status_text
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error reviewing assessment: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error reviewing assessment"
        )


@router.get(
    "/ep/pending-reviews",
    response_model=List[AssessmentResponse],
    summary="Get Pending Reviews",
    description="Get all assessments pending clinical review (clinicians/admins only)."
)
async def get_pending_reviews(
    limit: int = Query(50, ge=1, le=100, description="Maximum number of assessments to return"),
    current_user: dict = Depends(require_role("clinician")),
    db: Session = Depends(get_db)
):
    """Get assessments pending clinical review"""
    try:
        service = EPAssessmentServiceEnhanced(db)
        assessments = service.get_pending_reviews(limit)
        
        return [
            AssessmentResponse(
                assessment_id=str(a.assessment_id),
                user_id=str(a.user_id),
                session_id=str(a.session_id) if a.session_id else None,
                questionnaire_version_id=str(a.questionnaire_version_id),
                scores=a.scores,
                quality_metrics=a.quality_metrics,
                completed_at=a.completed_at
            )
            for a in assessments
        ]
        
    except Exception as e:
        logger.error(f"Error retrieving pending reviews: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error retrieving pending reviews"
        )


# ============================================================================
# ANALYTICS ENDPOINTS
# ============================================================================

@router.get(
    "/analytics/quality",
    response_model=QualityStatistics,
    summary="Get Quality Statistics",
    description="Get quality statistics for assessments over specified time period (admins only)."
)
async def get_quality_statistics(
    days: int = Query(30, ge=1, le=365, description="Number of days to analyze"),
    current_user: dict = Depends(require_role("admin")),
    db: Session = Depends(get_db)
):
    """Get quality statistics (admins only)"""
    try:
        service = EPAssessmentServiceEnhanced(db)
        stats = service.get_quality_statistics(days)
        
        return QualityStatistics(**stats)
        
    except Exception as e:
        logger.error(f"Error retrieving statistics: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error retrieving quality statistics"
        )


# ============================================================================
# HEALTH CHECK
# ============================================================================

@router.get(
    "/health",
    summary="Health Check",
    description="Check if E&P Assessment API is operational."
)
async def health_check():
    """API health check"""
    return {
        "status": "healthy",
        "service": "E&P Assessment API",
        "version": "1.0.0"
    }
