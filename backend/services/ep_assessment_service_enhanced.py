"""
E&P Suggestibility Assessment Service - Enhanced Edition
FIXED: Uses your existing models from questionnaire_models
"""
import uuid
from typing import Dict, List, Optional
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
import logging

# Use YOUR existing models
from models.questionnaire_models import (
    AssessmentSubmission,
    AssessmentResult,
    SuggestibilityScores,
    Interpretation,
    QuestionnaireVersion,
    QuestionnaireQuestion,
    TherapeuticApproach
)

logger = logging.getLogger(__name__)


class QualityMetrics:
    """Quality metrics for assessment (lightweight class)"""
    def __init__(
        self,
        confidence_score: float,
        answer_pattern: str,
        consistency_score: float,
        completion_percentage: float,
        needs_review: bool,
        review_reasons: List[str]
    ):
        self.confidence_score = confidence_score
        self.answer_pattern = answer_pattern
        self.consistency_score = consistency_score
        self.completion_percentage = completion_percentage
        self.needs_review = needs_review
        self.review_reasons = review_reasons


class EPAssessmentServiceEnhanced:
    """
    Enhanced E&P Assessment Service
    Uses your existing models with added quality features
    """
    
    def __init__(self, db: Session):
        self.db = db
    
    def calculate_quality_metrics(
        self, 
        answers: Dict[str, bool],
        time_to_complete: Optional[int] = None
    ) -> QualityMetrics:
        """Calculate quality metrics for the assessment"""
        pattern = self._detect_answer_pattern(answers)
        confidence = self._calculate_confidence_score(answers, time_to_complete)
        consistency = self._calculate_consistency(answers)
        completion_pct = (len(answers) / 36) * 100
        needs_review = self._needs_clinical_review(pattern, confidence, time_to_complete)
        
        return QualityMetrics(
            confidence_score=confidence,
            answer_pattern=pattern,
            consistency_score=consistency,
            completion_percentage=completion_pct,
            needs_review=needs_review,
            review_reasons=self._get_review_reasons(pattern, confidence, time_to_complete)
        )
    
    def _detect_answer_pattern(self, answers: Dict[str, bool]) -> str:
        """Detect suspicious answer patterns"""
        if not answers:
            return "empty"
        
        values = [answers.get(str(i), False) for i in range(1, 37)]
        yes_count = sum(values)
        total = len(values)
        yes_ratio = yes_count / total if total > 0 else 0
        
        if yes_count == total:
            return "all_yes"
        elif yes_count == 0:
            return "all_no"
        elif yes_ratio > 0.85:
            return "mostly_yes"
        elif yes_ratio < 0.15:
            return "mostly_no"
        
        alternations = sum(1 for i in range(len(values)-1) if values[i] != values[i+1])
        if alternations >= len(values) * 0.9:
            return "alternating"
        
        max_streak = self._get_max_streak(values)
        if max_streak >= 10:
            return "suspicious"
        
        return "balanced"
    
    def _get_max_streak(self, values: List[bool]) -> int:
        """Get maximum consecutive same answers"""
        if not values:
            return 0
        
        max_streak = 1
        current_streak = 1
        
        for i in range(1, len(values)):
            if values[i] == values[i-1]:
                current_streak += 1
                max_streak = max(max_streak, current_streak)
            else:
                current_streak = 1
        
        return max_streak
    
    def _calculate_confidence_score(
        self, 
        answers: Dict[str, bool],
        time_to_complete: Optional[int] = None
    ) -> float:
        """Calculate confidence score (0-100)"""
        score = 100.0
        
        yes_count = sum(1 for v in answers.values() if v)
        yes_ratio = yes_count / len(answers) if answers else 0
        
        if yes_ratio > 0.9 or yes_ratio < 0.1:
            score -= 40
        elif yes_ratio > 0.8 or yes_ratio < 0.2:
            score -= 20
        
        if time_to_complete:
            if time_to_complete < 120:
                score -= 30
            elif time_to_complete > 1200:
                score -= 10
            elif 180 <= time_to_complete <= 600:
                score += 10
        
        pattern = self._detect_answer_pattern(answers)
        if pattern in ['all_yes', 'all_no', 'alternating']:
            score -= 50
        elif pattern in ['suspicious']:
            score -= 30
        
        return max(0.0, min(100.0, score))
    
    def _calculate_consistency(self, answers: Dict[str, bool]) -> float:
        """Calculate response consistency (0-100)"""
        pattern = self._detect_answer_pattern(answers)
        
        if pattern == "balanced":
            return 85.0
        elif pattern in ['mostly_yes', 'mostly_no']:
            return 70.0
        else:
            return 50.0
    
    def _needs_clinical_review(
        self,
        pattern: str,
        confidence: float,
        time_to_complete: Optional[int]
    ) -> bool:
        """Determine if assessment needs clinical review"""
        if confidence < 60:
            return True
        
        if pattern in ['all_yes', 'all_no', 'alternating', 'suspicious']:
            return True
        
        if time_to_complete and time_to_complete < 90:
            return True
        
        return False
    
    def _get_review_reasons(
        self,
        pattern: str,
        confidence: float,
        time_to_complete: Optional[int]
    ) -> List[str]:
        """Get list of reasons why assessment needs review"""
        reasons = []
        
        if confidence < 60:
            reasons.append(f"Low confidence score ({confidence:.1f})")
        
        if pattern in ['all_yes', 'all_no']:
            reasons.append(f"Extreme answer pattern: {pattern}")
        elif pattern in ['alternating', 'suspicious']:
            reasons.append(f"Suspicious answer pattern: {pattern}")
        
        if time_to_complete:
            if time_to_complete < 90:
                reasons.append(f"Completed too quickly ({time_to_complete}s)")
            elif time_to_complete > 1200:
                reasons.append(f"Took unusually long ({time_to_complete}s)")
        
        return reasons
    
    def save_assessment_with_quality(
        self,
        submission: AssessmentSubmission,
        time_to_complete: Optional[int] = None
    ) -> tuple:
        """
        Save assessment and return both result and quality metrics
        
        Args:
            submission: Your existing AssessmentSubmission object
            time_to_complete: Optional time in seconds
            
        Returns:
            tuple: (AssessmentResult, QualityMetrics)
        """
        # Calculate quality metrics
        quality = self.calculate_quality_metrics(
            submission.answers,
            time_to_complete
        )
        
        # Update submission with quality data if fields exist
        if hasattr(submission, 'confidence_score'):
            submission.confidence_score = quality.confidence_score
        
        if hasattr(submission, 'answer_pattern_signature'):
            submission.answer_pattern_signature = quality.answer_pattern
        
        if hasattr(submission, 'completion_percentage'):
            submission.completion_percentage = quality.completion_percentage
        
        if hasattr(submission, 'time_to_complete_seconds'):
            submission.time_to_complete_seconds = time_to_complete
        
        # Auto-flag if needed
        if quality.needs_review and hasattr(submission, 'clinical_notes'):
            note = f"AUTO-FLAGGED: {', '.join(quality.review_reasons)}"
            submission.clinical_notes = note
            logger.warning(f"Assessment auto-flagged: {quality.review_reasons}")
        
        # Save to database (your existing logic handles this)
        self.db.add(submission)
        self.db.commit()
        self.db.refresh(submission)
        
        # Return submission and quality metrics
        return submission, quality
    
    def get_quality_for_existing_assessment(
        self,
        assessment_id: uuid.UUID
    ) -> Optional[QualityMetrics]:
        """
        Get quality metrics for an existing assessment
        Useful for backfilling quality data
        """
        assessment = self.db.query(AssessmentSubmission).filter(
            AssessmentSubmission.id == assessment_id
        ).first()
        
        if not assessment or not assessment.answers:
            return None
        
        time = None
        if hasattr(assessment, 'time_to_complete_seconds'):
            time = assessment.time_to_complete_seconds
        
        return self.calculate_quality_metrics(assessment.answers, time)
    
    def flag_for_review(
        self,
        assessment_id: uuid.UUID,
        flagged_by: str,
        reason: str
    ) -> bool:
        """Manually flag assessment for clinical review"""
        assessment = self.db.query(AssessmentSubmission).filter(
            AssessmentSubmission.id == assessment_id
        ).first()
        
        if not assessment:
            return False
        
        if not hasattr(assessment, 'clinical_notes'):
            logger.warning("Assessment model doesn't have clinical_notes field")
            return False
        
        timestamp = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
        note = f"[{timestamp}] FLAGGED by {flagged_by}: {reason}"
        
        if assessment.clinical_notes:
            assessment.clinical_notes += f"\n{note}"
        else:
            assessment.clinical_notes = note
        
        if hasattr(assessment, 'updated_at'):
            assessment.updated_at = datetime.utcnow()
        
        self.db.commit()
        return True
    
    def get_quality_statistics(self, days: int = 30) -> Dict:
        """Get quality statistics for assessments"""
        cutoff = datetime.utcnow() - timedelta(days=days)
        
        assessments = self.db.query(AssessmentSubmission).filter(
            AssessmentSubmission.completed_at >= cutoff
        ).all()
        
        if not assessments:
            return {
                "total_assessments": 0,
                "avg_confidence": 0,
                "period_days": days
            }
        
        patterns = {}
        total_confidence = 0
        flagged_count = 0
        
        for a in assessments:
            # Calculate quality on the fly if not stored
            if hasattr(a, 'confidence_score') and a.confidence_score:
                confidence = a.confidence_score
            else:
                quality = self.calculate_quality_metrics(a.answers, None)
                confidence = quality.confidence_score
            
            total_confidence += confidence
            
            # Count patterns
            if hasattr(a, 'answer_pattern_signature') and a.answer_pattern_signature:
                pattern = a.answer_pattern_signature
            else:
                pattern = self._detect_answer_pattern(a.answers)
            
            patterns[pattern] = patterns.get(pattern, 0) + 1
            
            # Count flagged
            if hasattr(a, 'clinical_notes') and a.clinical_notes and "FLAGGED" in a.clinical_notes:
                flagged_count += 1
        
        return {
            "total_assessments": len(assessments),
            "avg_confidence": total_confidence / len(assessments) if assessments else 0,
            "pattern_distribution": patterns,
            "flagged_for_review": flagged_count,
            "flagged_percentage": (flagged_count / len(assessments)) * 100 if assessments else 0,
            "period_days": days
        }
    
    def backfill_quality_metrics(self, limit: int = 100) -> int:
        """
        Backfill quality metrics for existing assessments
        Returns number of assessments updated
        """
        assessments = self.db.query(AssessmentSubmission).filter(
            AssessmentSubmission.confidence_score.is_(None)
        ).limit(limit).all()
        
        count = 0
        for assessment in assessments:
            if not assessment.answers:
                continue
            
            time = None
            if hasattr(assessment, 'time_to_complete_seconds'):
                time = assessment.time_to_complete_seconds
            
            quality = self.calculate_quality_metrics(assessment.answers, time)
            
            if hasattr(assessment, 'confidence_score'):
                assessment.confidence_score = quality.confidence_score
            
            if hasattr(assessment, 'answer_pattern_signature'):
                assessment.answer_pattern_signature = quality.answer_pattern
            
            if hasattr(assessment, 'completion_percentage'):
                assessment.completion_percentage = quality.completion_percentage
            
            count += 1
        
        self.db.commit()
        logger.info(f"Backfilled quality metrics for {count} assessments")
        
        return count
