"""
Enhanced E&P Assessment Service
Handles scoring, quality metrics, fraud detection, and clinical validation
"""

from typing import Dict, Optional, List, Tuple
from datetime import datetime
from uuid import UUID, uuid4
from sqlalchemy.orm import Session
from sqlalchemy import desc

from models.questionnaire_models import (
    UserAssessment,
    QuestionnaireVersion,
    QuestionnaireQuestion
)


class EPAssessmentServiceEnhanced:
    """
    Enhanced E&P Assessment Service
    
    Features:
    - Automatic scoring using Sichort methodology
    - Quality metrics (confidence scores)
    - Fraud detection (pattern recognition)
    - Clinical review workflow
    - Integration with multi-agent system
    """
    
    def __init__(self, db: Session):
        self.db = db
    
    
    # ========================================================================
    # CORE ASSESSMENT SUBMISSION
    # ========================================================================
    
    def save_assessment(
        self,
        user_id: UUID,
        answers: Dict[str, bool],
        session_id: Optional[UUID] = None,
        time_to_complete: Optional[int] = None,
        questionnaire_version_id: Optional[UUID] = None
    ) -> UserAssessment:
        """
        Save E&P Assessment with automatic scoring and quality metrics
        
        Args:
            user_id: User ID
            answers: Dict of question answers (q1-q36: bool)
            session_id: Optional VR session ID
            time_to_complete: Time in seconds
            questionnaire_version_id: Questionnaire version (defaults to latest active)
            
        Returns:
            UserAssessment with scores and quality metrics
        """
        # Validate answers
        self._validate_answers(answers)
        
        # Get questionnaire version
        if not questionnaire_version_id:
            questionnaire_version_id = self._get_latest_version_id()
        
        # Calculate scores
        q1_score, q2_score = self._calculate_scores(answers)
        combined_score = q1_score + q2_score
        
        # Determine profile
        profile, suggestibility_type = self._determine_profile(q1_score, q2_score)
        
        # Calculate percentages
        physical_percentage, emotional_percentage = self._calculate_percentages(
            q1_score, q2_score
        )
        
        # Quality metrics
        confidence_score = self._calculate_confidence_score(
            answers, time_to_complete
        )
        pattern_signature = self._detect_answer_pattern(answers)
        
        # Create assessment
        assessment = UserAssessment(
            id=uuid4(),
            user_id=user_id,
            session_id=session_id,
            questionnaire_version_id=questionnaire_version_id,
            profile=profile,
            q1_score=q1_score,
            q2_score=q2_score,
            combined_score=combined_score,
            physical_percentage=physical_percentage,
            emotional_percentage=emotional_percentage,
            suggestibility_type=suggestibility_type,
            answers=answers,
            confidence_score=confidence_score,
            answer_pattern_signature=pattern_signature,
            completion_percentage=100.0,
            time_to_complete_seconds=time_to_complete,
            created_at=datetime.utcnow(),
            completed_at=datetime.utcnow()
        )
        
        self.db.add(assessment)
        self.db.commit()
        self.db.refresh(assessment)
        
        # Update user profile
        self._update_user_ep_profile(user_id, assessment)
        
        return assessment
    
    
    # ========================================================================
    # SCORING LOGIC (Sichort Methodology)
    # ========================================================================
    
    def _calculate_scores(self, answers: Dict[str, bool]) -> Tuple[int, int]:
        """
        Calculate Q1 (Physical) and Q2 (Emotional) scores
        
        Physical Questions (Q1): 1-18
        Emotional Questions (Q2): 19-36
        
        Scoring:
        - Weight 10 questions: 1-16, 19-34 (YES = 10 points)
        - Weight 5 questions: 17-18, 35-36 (NO = 5 points)
        """
        q1_score = 0
        q2_score = 0
        
        # Physical Questions (1-18)
        for i in range(1, 17):  # Questions 1-16 (weight 10)
            if answers.get(f"q{i}", False):
                q1_score += 10
        
        # Questions 17-18 (weight 5, inverted scoring)
        if not answers.get("q17", True):
            q1_score += 5
        if not answers.get("q18", True):
            q1_score += 5
        
        # Emotional Questions (19-36)
        for i in range(19, 35):  # Questions 19-34 (weight 10)
            if answers.get(f"q{i}", False):
                q2_score += 10
        
        # Questions 35-36 (weight 5, inverted scoring)
        if not answers.get("q35", True):
            q2_score += 5
        if not answers.get("q36", True):
            q2_score += 5
        
        return q1_score, q2_score
    
    
    def _determine_profile(self, q1_score: int, q2_score: int) -> Tuple[str, str]:
        """
        Determine E&P profile based on scores
        
        Classification:
        - Physical Suggestible: Q1 > Q2 by 10+ points
        - Emotional Suggestible: Q2 > Q1 by 10+ points
        - Somnambulistic: Within 10 points of each other
        """
        diff = q1_score - q2_score
        
        if diff >= 10:
            return "Physical Suggestible", "Physical"
        elif diff <= -10:
            return "Emotional Suggestible", "Emotional"
        else:
            return "Somnambulistic", "Somnambulistic"
    
    
    def _calculate_percentages(self, q1_score: int, q2_score: int) -> Tuple[int, int]:
        """Calculate percentage breakdown"""
        total = q1_score + q2_score
        if total == 0:
            return 50, 50
        
        physical_pct = int((q1_score / total) * 100)
        emotional_pct = 100 - physical_pct
        
        return physical_pct, emotional_pct
    
    
    # ========================================================================
    # QUALITY METRICS & FRAUD DETECTION
    # ========================================================================
    
    def _calculate_confidence_score(
        self,
        answers: Dict[str, bool],
        time_to_complete: Optional[int]
    ) -> float:
        """
        Calculate confidence score (0-100) based on quality indicators
        
        Factors:
        - Answer pattern diversity
        - Completion time (too fast or slow is suspicious)
        - Response consistency
        """
        score = 100.0
        
        # Pattern detection
        pattern = self._detect_answer_pattern(answers)
        if pattern in ["all_yes", "all_no"]:
            score -= 50
        elif pattern == "alternating":
            score -= 30
        elif pattern == "mostly_yes":
            score -= 20
        elif pattern == "mostly_no":
            score -= 20
        
        # Time validation
        if time_to_complete:
            if time_to_complete < 120:  # < 2 minutes (too fast)
                score -= 30
            elif time_to_complete > 1800:  # > 30 minutes (too slow/distracted)
                score -= 15
        
        return max(0.0, min(100.0, score))
    
    
    def _detect_answer_pattern(self, answers: Dict[str, bool]) -> str:
        """
        Detect suspicious answer patterns
        
        Returns:
        - 'all_yes': All answers are True
        - 'all_no': All answers are False
        - 'alternating': Alternating True/False pattern
        - 'mostly_yes': >80% True
        - 'mostly_no': >80% False
        - 'balanced': Normal distribution
        """
        values = [answers.get(f"q{i}", False) for i in range(1, 37)]
        true_count = sum(values)
        
        # Check for uniform answers
        if true_count == 36:
            return "all_yes"
        if true_count == 0:
            return "all_no"
        
        # Check for alternating pattern
        alternating = all(
            values[i] != values[i + 1] for i in range(len(values) - 1)
        )
        if alternating:
            return "alternating"
        
        # Check for skewed distribution
        true_pct = true_count / 36
        if true_pct > 0.8:
            return "mostly_yes"
        if true_pct < 0.2:
            return "mostly_no"
        
        return "balanced"
    
    
    # ========================================================================
    # RETRIEVAL METHODS
    # ========================================================================
    
    def get_latest_assessment(self, user_id: UUID) -> Optional[UserAssessment]:
        """Get user's most recent assessment"""
        return (
            self.db.query(UserAssessment)
            .filter(UserAssessment.user_id == user_id)
            .order_by(desc(UserAssessment.created_at))
            .first()
        )
    
    
    def get_communication_preferences(self, user_id: UUID) -> Optional[Dict]:
        """
        Get communication preferences for multi-agent system
        
        This is the KEY endpoint for Phase 2 agent integration!
        
        Returns structured preferences for:
        - Language patterns
        - Communication style
        - Induction preferences
        - Tone/pace adjustments
        """
        assessment = self.get_latest_assessment(user_id)
        if not assessment:
            return None
        
        # Build preferences based on profile
        if assessment.suggestibility_type == "Physical":
            return {
                "suggestibility_type": "Physical Suggestible",
                "communication_style": "Direct and Literal",
                "language_patterns": [
                    "Use concrete, specific language",
                    "Focus on body sensations and physical experiences",
                    "Give clear, direct instructions",
                    "Use authoritative tone",
                    "Minimize metaphors and abstractions"
                ],
                "preferred_inductions": [
                    "Progressive muscle relaxation",
                    "Eye fixation",
                    "Counting down",
                    "Body scan"
                ],
                "voice_characteristics": {
                    "tone": "Firm and confident",
                    "pace": "Steady and measured",
                    "volume": "Clear and authoritative"
                },
                "avoid": [
                    "Inferential language",
                    "Complex metaphors",
                    "Permissive suggestions",
                    "Vague instructions"
                ]
            }
        
        elif assessment.suggestibility_type == "Emotional":
            return {
                "suggestibility_type": "Emotional Suggestible",
                "communication_style": "Inferential and Metaphorical",
                "language_patterns": [
                    "Use metaphors and stories",
                    "Focus on feelings and emotions",
                    "Give permissive suggestions",
                    "Use gentle, guiding language",
                    "Allow for interpretation"
                ],
                "preferred_inductions": [
                    "Guided imagery",
                    "Metaphorical journey",
                    "Safe place visualization",
                    "Emotional recall"
                ],
                "voice_characteristics": {
                    "tone": "Warm and nurturing",
                    "pace": "Slower with pauses",
                    "volume": "Soft and soothing"
                },
                "avoid": [
                    "Direct commands",
                    "Literal instructions",
                    "Authoritative tone",
                    "Body-focused suggestions"
                ]
            }
        
        else:  # Somnambulistic
            return {
                "suggestibility_type": "Somnambulistic",
                "communication_style": "Flexible and Adaptive",
                "language_patterns": [
                    "Balance literal and inferential",
                    "Use both body and emotion focus",
                    "Vary between direct and permissive",
                    "Adapt based on response"
                ],
                "preferred_inductions": [
                    "Combination approaches",
                    "Fractionation",
                    "Confusion techniques",
                    "Any method works well"
                ],
                "voice_characteristics": {
                    "tone": "Balanced - neither too firm nor too soft",
                    "pace": "Natural conversational",
                    "volume": "Moderate"
                },
                "avoid": [
                    "Extreme approaches",
                    "Overuse of one style"
                ]
            }
    
    
    def get_assessment_history(
        self,
        user_id: UUID,
        limit: int = 10,
        offset: int = 0
    ) -> List[UserAssessment]:
        """Get assessment history with pagination"""
        return (
            self.db.query(UserAssessment)
            .filter(UserAssessment.user_id == user_id)
            .order_by(desc(UserAssessment.created_at))
            .limit(limit)
            .offset(offset)
            .all()
        )
    
    
    # ========================================================================
    # CLINICAL REVIEW WORKFLOW
    # ========================================================================
    
    def flag_for_review(
        self,
        assessment_id: UUID,
        reason: str,
        flagged_by: UUID
    ) -> UserAssessment:
        """Flag assessment for clinical review"""
        assessment = self.db.query(UserAssessment).get(assessment_id)
        if not assessment:
            raise ValueError(f"Assessment {assessment_id} not found")
        
        assessment.clinical_notes = f"FLAGGED: {reason}"
        assessment.updated_at = datetime.utcnow()
        
        self.db.commit()
        self.db.refresh(assessment)
        
        return assessment
    
    
    def clinical_review(
        self,
        assessment_id: UUID,
        reviewer_id: UUID,
        status: str,
        notes: Optional[str] = None
    ) -> UserAssessment:
        """Submit clinical review of assessment"""
        assessment = self.db.query(UserAssessment).get(assessment_id)
        if not assessment:
            raise ValueError(f"Assessment {assessment_id} not found")
        
        assessment.reviewed_by = reviewer_id
        assessment.reviewed_at = datetime.utcnow()
        assessment.clinical_notes = notes or ""
        assessment.updated_at = datetime.utcnow()
        
        self.db.commit()
        self.db.refresh(assessment)
        
        return assessment
    
    
    def get_pending_reviews(self) -> List[UserAssessment]:
        """Get assessments pending clinical review"""
        return (
            self.db.query(UserAssessment)
            .filter(
                UserAssessment.clinical_notes.like("FLAGGED:%"),
                UserAssessment.reviewed_at.is_(None)
            )
            .order_by(desc(UserAssessment.created_at))
            .all()
        )
    
    
    # ========================================================================
    # ANALYTICS
    # ========================================================================
    
    def get_quality_statistics(self, days: int = 30) -> Dict:
        """Get quality metrics for analytics"""
        from datetime import timedelta
        cutoff_date = datetime.utcnow() - timedelta(days=days)
        
        assessments = (
            self.db.query(UserAssessment)
            .filter(UserAssessment.created_at >= cutoff_date)
            .all()
        )
        
        if not assessments:
            return {
                "total_assessments": 0,
                "average_confidence": 0,
                "fraud_pattern_rate": 0
            }
        
        total = len(assessments)
        avg_confidence = sum(a.confidence_score or 0 for a in assessments) / total
        fraud_patterns = sum(
            1 for a in assessments
            if a.answer_pattern_signature in ["all_yes", "all_no", "alternating"]
        )
        
        return {
            "total_assessments": total,
            "average_confidence": round(avg_confidence, 2),
            "fraud_pattern_rate": round((fraud_patterns / total) * 100, 2),
            "by_profile": {
                "Physical Suggestible": sum(
                    1 for a in assessments if a.suggestibility_type == "Physical"
                ),
                "Emotional Suggestible": sum(
                    1 for a in assessments if a.suggestibility_type == "Emotional"
                ),
                "Somnambulistic": sum(
                    1 for a in assessments if a.suggestibility_type == "Somnambulistic"
                )
            }
        }
    
    
    # ========================================================================
    # HELPER METHODS
    # ========================================================================
    
    def _validate_answers(self, answers: Dict[str, bool]) -> None:
        """Validate answer format"""
        # Check we have exactly 36 answers
        if len(answers) != 36:
            raise ValueError(f"Expected 36 answers, got {len(answers)}")
        
        # Check keys are q1-q36
        expected_keys = {f"q{i}" for i in range(1, 37)}
        actual_keys = set(answers.keys())
        if actual_keys != expected_keys:
            raise ValueError(f"Invalid answer keys. Expected q1-q36")
        
        # Check all values are boolean
        if not all(isinstance(v, bool) for v in answers.values()):
            raise ValueError("All answer values must be boolean")
    
    
    def _get_latest_version_id(self) -> UUID:
        """Get latest active questionnaire version"""
        version = (
            self.db.query(QuestionnaireVersion)
            .filter(QuestionnaireVersion.is_active == True)
            .order_by(desc(QuestionnaireVersion.created_at))
            .first()
        )
        
        if not version:
            raise ValueError("No active questionnaire version found")
        
        return version.id
    
    
    def _update_user_ep_profile(
        self,
        user_id: UUID,
        assessment: UserAssessment
    ) -> None:
        """
        Update user profile with E&P results
        
        This would integrate with your User model
        Currently a no-op - implement when User model is ready
        """
        # TODO: Implement when User model is available
        # user = self.db.query(User).get(user_id)
        # user.has_completed_ep = True
        # user.ep_results = {
        #     "profile": assessment.profile,
        #     "confidence_score": assessment.confidence_score
        # }
        # self.db.commit()
        pass
