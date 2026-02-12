# ============================================================================
# E&P Assessment Enhanced Features Installation - FIXED
# Properly escaped Python code for PowerShell
# ============================================================================

Write-Host "🎯 Installing E&P Assessment Enhanced Features..." -ForegroundColor Cyan

$ProjectRoot = "D:\ChatGPT Projects\genai-portfolio\projects\02-clinical-hypno-self-improvement-platform"
$BackendRoot = "$ProjectRoot\backend"

# ============================================================================
# STEP 1: Create Enhanced Service
# ============================================================================

Write-Host "`n📝 Creating enhanced suggestibility service..." -ForegroundColor Yellow

$EnhancedServiceDir = "$BackendRoot\services"
if (-not (Test-Path $EnhancedServiceDir)) {
    New-Item -ItemType Directory -Path $EnhancedServiceDir -Force | Out-Null
}

$EnhancedServiceFile = "$EnhancedServiceDir\ep_assessment_service_enhanced.py"

# Use single quotes to prevent PowerShell from parsing Python code
$ServiceContent = @'
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
    
    def calculate_scores(self, answers: Dict[str, bool]) -> ScoreBreakdown:
        """Calculate E&P Suggestibility scores from questionnaire answers"""
        q1_score = sum(1 for i in range(1, 19) if answers.get(str(i), False))
        q1_percentage = round((q1_score / 18) * 100)
        
        q2_score = sum(1 for i in range(19, 37) if answers.get(str(i), False))
        q2_percentage = round((q2_score / 18) * 100)
        
        combined_score = q1_score + q2_score
        combined_percentage = round((combined_score / 36) * 100)
        
        if combined_score > 0:
            physical_percentage = round((q1_score / combined_score) * 100)
            emotional_percentage = round((q2_score / combined_score) * 100)
        else:
            physical_percentage = 50
            emotional_percentage = 50
        
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
    
    def _classify_suggestibility(self, physical_pct: int, emotional_pct: int) -> str:
        """Classify suggestibility type based on HMI methodology"""
        diff = abs(physical_pct - emotional_pct)
        
        if diff <= 10:
            return "Somnambulistic (Balanced)"
        elif physical_pct > emotional_pct:
            return "Highly Physical Suggestible" if physical_pct >= 70 else "Physical Suggestible"
        else:
            return "Highly Emotional Suggestible" if emotional_pct >= 70 else "Emotional Suggestible"
    
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
    
    def save_assessment(
        self,
        user_id: str,
        answers: Dict[str, bool],
        session_id: Optional[str] = None,
        time_to_complete: Optional[int] = None
    ) -> AssessmentResult:
        """Save assessment with enhanced quality metrics"""
        questionnaire = self.db.query(QuestionnaireVersion).filter(
            QuestionnaireVersion.is_active == 1
        ).first()
        
        if not questionnaire:
            raise ValueError("No active questionnaire version found")
        
        scores = self.calculate_scores(answers)
        quality = self.calculate_quality_metrics(answers, time_to_complete)
        
        assessment = UserAssessment(
            id=uuid.uuid4(),
            user_id=uuid.UUID(user_id),
            session_id=uuid.UUID(session_id) if session_id else None,
            questionnaire_version_id=questionnaire.id,
            q1_score=scores.q1_score,
            q2_score=scores.q2_score,
            combined_score=scores.combined_score,
            physical_percentage=scores.physical_percentage,
            emotional_percentage=scores.emotional_percentage,
            suggestibility_type=scores.suggestibility_type,
            profile=scores.suggestibility_type,
            answers=answers,
            confidence_score=quality.confidence_score,
            answer_pattern_signature=quality.answer_pattern,
            completion_percentage=quality.completion_percentage,
            time_to_complete_seconds=time_to_complete,
            completed_at=datetime.utcnow(),
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
        self.db.add(assessment)
        self.db.commit()
        self.db.refresh(assessment)
        
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
                "language_pattern": "literal and step-by-step"
            }
        elif "Emotional" in sug_type:
            return {
                "style": "emotional_suggestible",
                "tone": "indirect and flowing",
                "use_metaphors": True,
                "use_literal": False,
                "language_pattern": "inferential and metaphorical"
            }
        else:
            return {
                "style": "somnambulistic",
                "tone": "flexible - adaptive mix",
                "use_metaphors": True,
                "use_literal": True,
                "language_pattern": "combine literal and metaphorical"
            }
'@

# Write the file
$ServiceContent | Out-File -FilePath $EnhancedServiceFile -Encoding UTF8

Write-Host "✅ Created: $EnhancedServiceFile" -ForegroundColor Green

# ============================================================================
# STEP 2: Create Schemas
# ============================================================================

Write-Host "`n📝 Creating enhanced schemas..." -ForegroundColor Yellow

$SchemasDir = "$BackendRoot\schemas"
if (-not (Test-Path $SchemasDir)) {
    New-Item -ItemType Directory -Path $SchemasDir -Force | Out-Null
}

$SchemasFile = "$SchemasDir\assessment.py"

$SchemasContent = @'
"""
E&P Assessment Schemas - Enhanced with Quality Metrics
"""
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from uuid import UUID


class ScoreBreakdown(BaseModel):
    """Assessment scores breakdown"""
    q1_score: int = Field(..., description="Physical Suggestibility score (0-100)")
    q2_score: int = Field(..., description="Emotional Suggestibility score (0-100)")
    combined_score: int = Field(..., description="Combined score (0-100)")
    physical_percentage: int = Field(..., description="Physical percentage")
    emotional_percentage: int = Field(..., description="Emotional percentage")
    suggestibility_type: str = Field(..., description="Classification")


class QualityMetrics(BaseModel):
    """Quality metrics for assessment"""
    confidence_score: float = Field(..., ge=0, le=100)
    answer_pattern: str
    consistency_score: float = Field(..., ge=0, le=100)
    completion_percentage: float = Field(..., ge=0, le=100)
    needs_review: bool
    review_reasons: List[str] = Field(default_factory=list)


class AssessmentResult(BaseModel):
    """Complete assessment result"""
    assessment_id: UUID
    user_id: UUID
    session_id: Optional[UUID] = None
    questionnaire_version_id: UUID
    scores: ScoreBreakdown
    quality_metrics: QualityMetrics
    completed_at: datetime
    
    class Config:
        from_attributes = True
'@

$SchemasContent | Out-File -FilePath $SchemasFile -Encoding UTF8

Write-Host "✅ Created: $SchemasFile" -ForegroundColor Green

# ============================================================================
# STEP 3: Create Test File
# ============================================================================

Write-Host "`n📝 Creating test file..." -ForegroundColor Yellow

$TestFile = "$BackendRoot\test_enhanced_features.py"

$TestContent = @'
"""
Test Enhanced E&P Assessment Features
"""
from services.ep_assessment_service_enhanced import EPAssessmentServiceEnhanced


def test_pattern_detection():
    """Test answer pattern detection"""
    service = EPAssessmentServiceEnhanced(None)
    
    # All yes
    all_yes = {str(i): True for i in range(1, 37)}
    pattern = service._detect_answer_pattern(all_yes)
    assert pattern == "all_yes"
    print(f"  All yes pattern: {pattern}")
    
    # All no
    all_no = {str(i): False for i in range(1, 37)}
    pattern = service._detect_answer_pattern(all_no)
    assert pattern == "all_no"
    print(f"  All no pattern: {pattern}")
    
    # Balanced
    balanced = {str(i): i % 2 == 0 for i in range(1, 37)}
    pattern = service._detect_answer_pattern(balanced)
    print(f"  Balanced pattern: {pattern}")


def test_confidence_scoring():
    """Test confidence score calculation"""
    service = EPAssessmentServiceEnhanced(None)
    
    # Good answers, good time
    balanced = {str(i): i % 2 == 0 for i in range(1, 37)}
    confidence = service._calculate_confidence_score(balanced, 300)
    print(f"  Balanced answers (300s): confidence = {confidence:.1f}")
    assert confidence >= 80
    
    # All yes, too fast
    all_yes = {str(i): True for i in range(1, 37)}
    confidence = service._calculate_confidence_score(all_yes, 60)
    print(f"  All yes (60s): confidence = {confidence:.1f}")
    assert confidence < 40


if __name__ == "__main__":
    print("Testing Enhanced E&P Assessment Features...\n")
    
    print("Test 1: Pattern Detection")
    test_pattern_detection()
    print("  Passed!\n")
    
    print("Test 2: Confidence Scoring")
    test_confidence_scoring()
    print("  Passed!\n")
    
    print("All tests passed!")
'@

$TestContent | Out-File -FilePath $TestFile -Encoding UTF8

Write-Host "✅ Created: $TestFile" -ForegroundColor Green

# ============================================================================
# STEP 4: Create Documentation
# ============================================================================

Write-Host "`n📝 Creating documentation..." -ForegroundColor Yellow

$DocsFile = "$ProjectRoot\ENHANCED_FEATURES_README.md"

$DocsContent = @'
# E&P Assessment Enhanced Features

## What's New

Your E&P Assessment now includes:

### 1. Automatic Quality Scoring
- Confidence score 0-100 for every assessment
- Based on answer patterns and completion time
- Auto-flags suspicious assessments

### 2. Pattern Detection
Detects:
- all_yes - Answered yes to everything
- all_no - Answered no to everything  
- alternating - yes/no/yes/no pattern
- suspicious - 10+ consecutive same answers
- balanced - Normal distribution

### 3. Time Validation
- Too fast (< 90 sec) flagged
- Too slow (> 20 min) flagged
- Optimal: 3-10 minutes

### 4. Quality Metrics
Every assessment returns:
```json
{
  "quality_metrics": {
    "confidence_score": 85.0,
    "answer_pattern": "balanced",
    "needs_review": false,
    "review_reasons": []
  }
}
```

## Testing

Run tests:
```bash
python backend/test_enhanced_features.py
```

## Usage

```python
from services.ep_assessment_service_enhanced import EPAssessmentServiceEnhanced

service = EPAssessmentServiceEnhanced(db)

# Save with quality metrics
result = service.save_assessment(
    user_id="user-uuid",
    answers=answers_dict,
    time_to_complete=240
)

# Check quality
if result.quality_metrics.confidence_score < 60:
    print("Low quality - needs review")
```

## Benefits

- Better data quality
- Fraud detection
- AI safety (don't personalize on bad data)
- Clinical oversight
- Audit trail
'@

$DocsContent | Out-File -FilePath $DocsFile -Encoding UTF8

Write-Host "✅ Created: $DocsFile" -ForegroundColor Green

# ============================================================================
# Summary
# ============================================================================

Write-Host "`n============================================================================" -ForegroundColor Green
Write-Host "✅ ENHANCED FEATURES INSTALLED!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green

Write-Host "`nFiles Created:" -ForegroundColor Cyan
Write-Host "  1. $EnhancedServiceFile" -ForegroundColor White
Write-Host "  2. $SchemasFile" -ForegroundColor White
Write-Host "  3. $TestFile" -ForegroundColor White
Write-Host "  4. $DocsFile" -ForegroundColor White

Write-Host "`nFeatures Added:" -ForegroundColor Yellow
Write-Host "  ✅ Automatic quality scoring" -ForegroundColor Green
Write-Host "  ✅ Pattern detection (fraud prevention)" -ForegroundColor Green
Write-Host "  ✅ Time validation" -ForegroundColor Green
Write-Host "  ✅ Auto-flagging suspicious assessments" -ForegroundColor Green
Write-Host "  ✅ Clinical review workflow" -ForegroundColor Green

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "  1. Test: python backend\test_enhanced_features.py" -ForegroundColor White
Write-Host "  2. Read: ENHANCED_FEATURES_README.md" -ForegroundColor White
Write-Host "  3. Integrate with your existing services" -ForegroundColor White

Write-Host "`n============================================================================`n" -ForegroundColor Green
