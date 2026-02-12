"""
Test Enhanced E&P Assessment Features
"""
import pytest
from datetime import datetime
from services.ep_assessment_service_enhanced import EPAssessmentServiceEnhanced


def test_quality_metrics():
    """Test quality metric calculation"""
    service = EPAssessmentServiceEnhanced(None)
    
    # Test balanced answers
    balanced_answers = {
    **{str(i): True for i in range(1, 19)},   # Q1-18: Yes
    **{str(i): False for i in range(19, 37)}  # Q19-36: No
    }
    quality = service.calculate_quality_metrics(balanced_answers, time_to_complete=300)
    print (f" quality = ${quality.answer_pattern}")
    assert quality.answer_pattern == "balanced"
    assert quality.confidence_score > 70
    assert not quality.needs_review
    
    # Test all yes answers
    all_yes = {str(i): True for i in range(1, 37)}
    quality = service.calculate_quality_metrics(all_yes, time_to_complete=300)
    
    assert quality.answer_pattern == "all_yes"
    assert quality.confidence_score < 60
    assert quality.needs_review
    
    # Test too fast completion
    quality = service.calculate_quality_metrics(balanced_answers, time_to_complete=60)
    assert quality.needs_review
    assert "too quickly" in str(quality.review_reasons).lower()


def test_pattern_detection():
    """Test answer pattern detection"""
    service = EPAssessmentServiceEnhanced(None)
    
    # All yes
    all_yes = {str(i): True for i in range(1, 37)}
    pattern = service._detect_answer_pattern(all_yes)
    assert pattern == "all_yes"
    
    # All no
    all_no = {str(i): False for i in range(1, 37)}
    pattern = service._detect_answer_pattern(all_no)
    assert pattern == "all_no"
    
    # Alternating
    alternating = {str(i): i % 2 == 0 for i in range(1, 37)}
    pattern = service._detect_answer_pattern(alternating)
    assert pattern == "alternating"
    
    # Balanced
    balanced = {
        **{str(i): True for i in range(1, 19)},
        **{str(i): False for i in range(19, 37)}
    }
    pattern = service._detect_answer_pattern(balanced)
    assert pattern in ["balanced", "suspicious"]


def test_confidence_calculation():
    """Test confidence score calculation"""
    service = EPAssessmentServiceEnhanced(None)
    
    # Good answers, good time
    balanced = {str(i): i % 2 == 0 for i in range(1, 37)}
    confidence = service._calculate_confidence_score(balanced, 300)
    assert confidence >= 80
    
    # All yes, too fast
    all_yes = {str(i): True for i in range(1, 37)}
    confidence = service._calculate_confidence_score(all_yes, 60)
    assert confidence < 40


if __name__ == "__main__":
    print("Testing Enhanced E&P Assessment Features...")
    test_quality_metrics()
    print("âœ… Quality metrics test passed")
    
    test_pattern_detection()
    print("âœ… Pattern detection test passed")
    
    test_confidence_calculation()
    print("âœ… Confidence calculation test passed")
    
    print("\nðŸŽ‰ All tests passed!")
