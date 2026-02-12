"""
E&P Suggestibility Assessment Service - Enhanced Edition
Includes quality scoring, pattern detection, and clinical workflow
"""
import uuid
from typing import Dict, List, Optional, Tuple
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import func
import json
import logging

from models.assessment import UserAssessment, QuestionnaireVersion
from schemas.assessment import (
    AssessmentResult,
    ScoreBreakdown,
    QualityMetrics,
    ClinicalReview
)

logger = logging.getLogger(__name__)


class EPAssessmentServiceEnhanced:
    """
    Enhanced E&P Assessment Service with:
    - Automatic quality scoring
    - Answer pattern detection
    - Clinical review workflow
    - Time tracking
    - Fraud detection
    """
    
    def __init__(self, db: Session):
        self.db = db
    
    # ========================================================================
    # CORE ASSESSMENT LOGIC
    # ========================================================================
    
    def calculate_scores(self, answers: Dict[str, bool]) -> ScoreBreakdown:
        """Calculate E&P Suggestibility scores from questionnaire answers"""
        # Physical Suggestibility (Questions 1-18)
        q1_score = sum(1 for i in range(1, 19) if answers.get(str(i), False))
        q1_percentage = round((q1_score / 18) * 100)
        
        # Emotional Suggestibility (Questions 19-36)
        q2_score = sum(1 for i in range(19, 37) if answers.get(str(i), False))
        q2_percentage = round((q2_score / 18) * 100)
        
        # Combined
        combined_score = q1_score + q2_score
        combined_percentage = round((combined_score / 36) * 100)
        
        # Calculate percentages of each type
        if combined_score > 0:
            physical_percentage = round((q1_score / combined_score) * 100)
            emotional_percentage = round((q2_score / combined_score) * 100)
        else:
            physical_percentage = 50
            emotional_percentage = 50
        
        # Classification
        suggestibility_type = self._classify_suggestibility(
            physical_percentage, 
            emotional_percentage
        )
        
        return ScoreBreakdown(
            q1_score=q1_percentage,
            q2_score=q2_percentage,
            combined_score=combined_percentage,
            physical_percentage=physical_percentage,
            emotional_percentage=emotional_percentage,
            suggestibility_type=suggestibility_type
        )
    
    def _classify_suggestibility(
        self, 
        physical_pct: int, 
        emotional_pct: int
    ) -> str:
        """Classify suggestibility type based on HMI methodology"""
        diff = abs(physical_pct - emotional_pct)
        
        if diff <= 10:
            return "Somnambulistic (Balanced)"
        elif physical_pct > emotional_pct:
            return "Highly Physical Suggestible" if physical_pct >= 70 else "Physical Suggestible"
        else:
            return "Highly Emotional Suggestible" if emotional_pct >= 70 else "Emotional Suggestible"
    
    # ========================================================================
    # QUALITY METRICS & PATTERN DETECTION
    # ========================================================================
    
    def calculate_quality_metrics(
        self, 
        answers: Dict[str, bool],
        time_to_complete: Optional[int] = None
    ) -> QualityMetrics:
        """
        Calculate quality metrics for the assessment
        Detects patterns and assigns confidence score
        """
        # Pattern detection
        pattern = self._detect_answer_pattern(answers)
        
        # Confidence score (0-100)
        confidence = self._calculate_confidence_score(answers, time_to_complete)
        
        # Response consistency
        consistency = self._calculate_consistency(answers)
        
        # Completion percentage
        completion_pct = (len(answers) / 36) * 100
        
        # Flags for review
        needs_review = self._needs_clinical_review(
            pattern, confidence, time_to_complete
        )
        
        return QualityMetrics(
            confidence_score=confidence,
            answer_pattern=pattern,
            consistency_score=consistency,
            completion_percentage=completion_pct,
            needs_review=needs_review,
            review_reasons=self._get_review_reasons(pattern, confidence, time_to_complete)
        )
    
    def _detect_answer_pattern(self, answers: Dict[str, bool]) -> str:
        """
        Detect suspicious answer patterns
        Returns: 'balanced', 'all_yes', 'all_no', 'mostly_yes', 'mostly_no', 'alternating', 'suspicious'
        """
        if not answers:
            return "empty"
        
        values = [answers.get(str(i), False) for i in range(1, 37)]
        yes_count = sum(values)
        total = len(values)
        yes_ratio = yes_count / total if total > 0 else 0
        
        # Check for extreme patterns
        if yes_count == total:
            return "all_yes"
        elif yes_count == 0:
            return "all_no"
        elif yes_ratio > 0.85:
            return "mostly_yes"
        elif yes_ratio < 0.15:
            return "mostly_no"
        
        # Check for alternating pattern
        alternations = sum(1 for i in range(len(values)-1) if values[i] != values[i+1])
        if alternations >= len(values) * 0.9:
            return "alternating"
        
        # Check for suspicious blocks (same answer for 10+ consecutive questions)
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
        """
        Calculate confidence score (0-100)
        Based on answer distribution and completion time
        """
        score = 100.0
        
        # Answer distribution factor
        yes_count = sum(1 for v in answers.values() if v)
        yes_ratio = yes_count / len(answers) if answers else 0
        
        # Penalize extreme yes/no ratios
        if yes_ratio > 0.9 or yes_ratio < 0.1:
            score -= 40
        elif yes_ratio > 0.8 or yes_ratio < 0.2:
            score -= 20
        
        # Time factor
        if time_to_complete:
            # Too fast (< 2 min = 120 sec) - likely rushing
            if time_to_complete < 120:
                score -= 30
            # Too slow (> 20 min = 1200 sec) - may be distracted
            elif time_to_complete > 1200:
                score -= 10
            # Optimal: 3-10 minutes
            elif 180 <= time_to_complete <= 600:
                score += 10
        
        # Pattern penalty
        pattern = self._detect_answer_pattern(answers)
        if pattern in ['all_yes', 'all_no', 'alternating']:
            score -= 50
        elif pattern in ['suspicious']:
            score -= 30
        
        return max(0.0, min(100.0, score))
    
    def _calculate_consistency(self, answers: Dict[str, bool]) -> float:
        """
        Calculate response consistency (0-100)
        Looks for logical contradictions in answers
        """
        # TODO: Implement consistency checks based on question pairs
        # For now, return a baseline based on pattern
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
        # Low confidence
        if confidence < 60:
            return True
        
        # Suspicious patterns
        if pattern in ['all_yes', 'all_no', 'alternating', 'suspicious']:
            return True
        
        # Too fast completion
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
    
    # ========================================================================
    # SAVE ASSESSMENT WITH ENHANCED FEATURES
    # ========================================================================
    
    def save_assessment(
        self,
        user_id: str,
        answers: Dict[str, bool],
        session_id: Optional[str] = None,
        time_to_complete: Optional[int] = None,
        ip_address: Optional[str] = None
    ) -> AssessmentResult:
        """
        Save assessment with enhanced quality metrics
        """
        # Get active questionnaire
        questionnaire = self.db.query(QuestionnaireVersion).filter(
            QuestionnaireVersion.is_active == 1
        ).first()
        
        if not questionnaire:
            raise ValueError("No active questionnaire version found")
        
        # Calculate scores
        scores = self.calculate_scores(answers)
        
        # Calculate quality metrics
        quality = self.calculate_quality_metrics(answers, time_to_complete)
        
        # Create assessment record
        assessment = UserAssessment(
            id=uuid.uuid4(),
            user_id=uuid.UUID(user_id),
            session_id=uuid.UUID(session_id) if session_id else None,
            questionnaire_version_id=questionnaire.id,
            
            # Scores
            q1_score=scores.q1_score,
            q2_score=scores.q2_score,
            combined_score=scores.combined_score,
            physical_percentage=scores.physical_percentage,
            emotional_percentage=scores.emotional_percentage,
            suggestibility_type=scores.suggestibility_type,
            profile=scores.suggestibility_type,  # Compatibility
            
            # Raw data
            answers=answers,
            
            # Quality metrics
            confidence_score=quality.confidence_score,
            answer_pattern_signature=quality.answer_pattern,
            completion_percentage=quality.completion_percentage,
            
            # Timing
            time_to_complete_seconds=time_to_complete,
            completed_at=datetime.utcnow(),
            
            # Audit trail
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
        self.db.add(assessment)
        self.db.commit()
        self.db.refresh(assessment)
        
        # Auto-flag for review if needed
        if quality.needs_review:
            self._auto_flag_for_review(assessment.id, quality.review_reasons)
        
        return AssessmentResult(
            assessment_id=assessment.id,
            user_id=assessment.user_id,
            session_id=assessment.session_id,
            questionnaire_version_id=assessment.questionnaire_version_id,
            scores=scores,
            quality_metrics=quality,
            completed_at=assessment.completed_at
        )
    
    def _auto_flag_for_review(self, assessment_id: uuid.UUID, reasons: List[str]):
        """Automatically flag assessment for clinical review"""
        assessment = self.db.query(UserAssessment).filter(
            UserAssessment.id == assessment_id
        ).first()
        
        if assessment:
            note = f"AUTO-FLAGGED: {', '.join(reasons)}"
            assessment.clinical_notes = note
            self.db.commit()
            
            logger.warning(f"Assessment {assessment_id} auto-flagged: {reasons}")
    
    # ========================================================================
    # CLINICAL REVIEW WORKFLOW
    # ========================================================================
    
    def flag_for_review(
        self,
        assessment_id: str,
        flagged_by: str,
        reason: str
    ) -> bool:
        """Manually flag assessment for clinical review"""
        assessment = self.db.query(UserAssessment).filter(
            UserAssessment.id == uuid.UUID(assessment_id)
        ).first()
        
        if not assessment:
            return False
        
        timestamp = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
        note = f"[{timestamp}] FLAGGED by {flagged_by}: {reason}"
        
        if assessment.clinical_notes:
            assessment.clinical_notes += f"\n{note}"
        else:
            assessment.clinical_notes = note
        
        assessment.updated_at = datetime.utcnow()
        self.db.commit()
        
        return True
    
    def mark_reviewed(
        self,
        assessment_id: str,
        reviewer_id: str,
        notes: Optional[str] = None,
        approved: bool = True
    ) -> bool:
        """Mark assessment as reviewed by clinician"""
        assessment = self.db.query(UserAssessment).filter(
            UserAssessment.id == uuid.UUID(assessment_id)
        ).first()
        
        if not assessment:
            return False
        
        assessment.reviewed_by = uuid.UUID(reviewer_id)
        assessment.reviewed_at = datetime.utcnow()
        
        timestamp = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
        status = "APPROVED" if approved else "REJECTED"
        note = f"[{timestamp}] {status} by {reviewer_id}"
        
        if notes:
            note += f": {notes}"
        
        if assessment.clinical_notes:
            assessment.clinical_notes += f"\n{note}"
        else:
            assessment.clinical_notes = note
        
        assessment.updated_at = datetime.utcnow()
        self.db.commit()
        
        return True
    
    def get_pending_reviews(self, limit: int = 50) -> List[AssessmentResult]:
        """Get assessments pending clinical review"""
        assessments = self.db.query(UserAssessment).filter(
            UserAssessment.confidence_score < 60,
            UserAssessment.reviewed_at.is_(None)
        ).order_by(
            UserAssessment.completed_at.desc()
        ).limit(limit).all()
        
        return [self._to_assessment_result(a) for a in assessments]
    
    # ========================================================================
    # ANALYTICS & REPORTING
    # ========================================================================
    
    def get_quality_statistics(self, days: int = 30) -> Dict:
        """Get quality statistics for assessments"""
        cutoff = datetime.utcnow() - timedelta(days=days)
        
        assessments = self.db.query(UserAssessment).filter(
            UserAssessment.completed_at >= cutoff
        ).all()
        
        if not assessments:
            return {}
        
        patterns = {}
        total_confidence = 0
        flagged_count = 0
        
        for a in assessments:
            # Count patterns
            pattern = a.answer_pattern_signature or "unknown"
            patterns[pattern] = patterns.get(pattern, 0) + 1
            
            # Sum confidence
            if a.confidence_score:
                total_confidence += a.confidence_score
            
            # Count flagged
            if a.clinical_notes and "FLAGGED" in a.clinical_notes:
                flagged_count += 1
        
        return {
            "total_assessments": len(assessments),
            "avg_confidence": total_confidence / len(assessments) if assessments else 0,
            "pattern_distribution": patterns,
            "flagged_for_review": flagged_count,
            "flagged_percentage": (flagged_count / len(assessments)) * 100 if assessments else 0,
            "period_days": days
        }
    
    def get_user_assessment_history(
        self,
        user_id: str,
        limit: int = 10
    ) -> List[AssessmentResult]:
        """Get assessment history for user"""
        assessments = self.db.query(UserAssessment).filter(
            UserAssessment.user_id == uuid.UUID(user_id)
        ).order_by(
            UserAssessment.completed_at.desc()
        ).limit(limit).all()
        
        return [self._to_assessment_result(a) for a in assessments]
    
    def _to_assessment_result(self, assessment: UserAssessment) -> AssessmentResult:
        """Convert database record to AssessmentResult"""
        scores = ScoreBreakdown(
            q1_score=assessment.q1_score,
            q2_score=assessment.q2_score,
            combined_score=assessment.combined_score,
            physical_percentage=assessment.physical_percentage,
            emotional_percentage=assessment.emotional_percentage,
            suggestibility_type=assessment.suggestibility_type or assessment.profile
        )
        
        quality = QualityMetrics(
            confidence_score=assessment.confidence_score or 0,
            answer_pattern=assessment.answer_pattern_signature or "unknown",
            consistency_score=0,  # Not stored yet
            completion_percentage=assessment.completion_percentage or 100,
            needs_review=assessment.reviewed_at is None and assessment.confidence_score < 60,
            review_reasons=[]
        )
        
        return AssessmentResult(
            assessment_id=assessment.id,
            user_id=assessment.user_id,
            session_id=assessment.session_id,
            questionnaire_version_id=assessment.questionnaire_version_id,
            scores=scores,
            quality_metrics=quality,
            completed_at=assessment.completed_at
        )
    
    # ========================================================================
    # COMMUNICATION PREFERENCES (for AI Agents)
    # ========================================================================
    
    def get_communication_preferences(self, user_id: str) -> Dict:
        """Get AI communication preferences based on latest assessment"""
        assessment = self.db.query(UserAssessment).filter(
            UserAssessment.user_id == uuid.UUID(user_id)
        ).order_by(
            UserAssessment.completed_at.desc()
        ).first()
        
        if not assessment:
            return {
                "style": "balanced",
                "confidence": 0,
                "message": "No assessment completed"
            }
        
        sug_type = assessment.suggestibility_type or assessment.profile
        confidence = assessment.confidence_score or 0
        
        base_prefs = self._get_communication_style(sug_type)
        base_prefs["confidence"] = confidence
        base_prefs["assessment_date"] = assessment.completed_at.isoformat()
        
        # Add warning if low confidence
        if confidence < 60:
            base_prefs["warning"] = "Low confidence assessment - use with caution"
        
        return base_prefs
    
    def _get_communication_style(self, sug_type: str) -> Dict:
        """Get communication style guidelines"""
        if "Physical" in sug_type:
            return {
                "style": "physical_suggestible",
                "tone": "direct and clear",
                "use_metaphors": False,
                "use_literal": True,
                "language_pattern": "literal and step-by-step",
                "example": "Take a deep breath. Hold for 3 seconds. Exhale slowly."
            }
        elif "Emotional" in sug_type:
            return {
                "style": "emotional_suggestible",
                "tone": "indirect and flowing",
                "use_metaphors": True,
                "use_literal": False,
                "language_pattern": "inferential and metaphorical",
                "example": "You might find yourself drifting like a leaf on a stream..."
            }
        else:
            return {
                "style": "somnambulistic",
                "tone": "flexible - adaptive mix",
                "use_metaphors": True,
                "use_literal": True,
                "language_pattern": "combine literal and metaphorical",
                "example": "As you breathe deeply, notice yourself relaxing more..."
            }
