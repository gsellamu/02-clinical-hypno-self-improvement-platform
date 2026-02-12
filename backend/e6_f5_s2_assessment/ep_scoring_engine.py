"""
E&P Scoring Engine
Calculates trait scores and determines E&P personality type
"""
from typing import Dict, List, Tuple
from dataclasses import dataclass
import json

@dataclass
class TraitScore:
    """Scores for a single trait"""
    trait_name: str
    physical_score: int
    emotional_score: int
    total_questions: int
    physical_percentage: float
    emotional_percentage: float
    dominant_type: str  # 'Physical' or 'Emotional'

@dataclass
class EPProfile:
    """Complete E&P personality profile"""
    ep_type: str  # 'PP', 'PE', 'EP', 'EE'
    primary_type: str  # 'Physical' or 'Emotional'
    secondary_type: str  # 'Physical' or 'Emotional'
    trait_scores: Dict[str, TraitScore]
    overall_physical_percentage: float
    overall_emotional_percentage: float
    confidence_score: float  # How clear the type is (0-100)

class EPScoringEngine:
    """Calculates E&P scores from assessment responses"""
    
    def __init__(self):
        self.trait_weights = {
            'logical': 1.0,
            'physical': 1.2,  # Physical trait weighted slightly higher per HMI
            'emotional': 1.2,  # Emotional trait weighted slightly higher per HMI
            'communication': 1.0
        }
    
    def score_responses(self, responses: Dict[int, str]) -> EPProfile:
        """
        Score assessment responses and determine EP type
        
        Args:
            responses: Dict mapping question_id to response ('physical' or 'emotional')
        
        Returns:
            EPProfile with complete scoring and type determination
        """
        # Calculate scores for each trait
        trait_scores = self._calculate_trait_scores(responses)
        
        # Determine primary and secondary types
        primary_type, secondary_type = self._determine_types(trait_scores)
        
        # Calculate EP type
        ep_type = self._calculate_ep_type(primary_type, secondary_type)
        
        # Calculate overall percentages
        overall_physical, overall_emotional = self._calculate_overall_percentages(trait_scores)
        
        # Calculate confidence score
        confidence = self._calculate_confidence(trait_scores, overall_physical, overall_emotional)
        
        return EPProfile(
            ep_type=ep_type,
            primary_type=primary_type,
            secondary_type=secondary_type,
            trait_scores=trait_scores,
            overall_physical_percentage=overall_physical,
            overall_emotional_percentage=overall_emotional,
            confidence_score=confidence
        )
    
    def _calculate_trait_scores(self, responses: Dict[int, str]) -> Dict[str, TraitScore]:
        """Calculate scores for each of the Four Core Traits"""
        
        # Question ranges for each trait
        trait_ranges = {
            'logical': range(1, 11),      # Questions 1-10
            'physical': range(11, 23),    # Questions 11-22
            'emotional': range(23, 35),   # Questions 23-34
            'communication': range(35, 46) # Questions 35-45
        }
        
        trait_scores = {}
        
        for trait_name, question_range in trait_ranges.items():
            physical_score = 0
            emotional_score = 0
            total_questions = 0
            
            for q_id in question_range:
                if q_id in responses:
                    total_questions += 1
                    if responses[q_id].lower() == 'physical':
                        physical_score += 1
                    else:
                        emotional_score += 1
            
            # Calculate percentages
            if total_questions > 0:
                physical_pct = (physical_score / total_questions) * 100
                emotional_pct = (emotional_score / total_questions) * 100
            else:
                physical_pct = 0
                emotional_pct = 0
            
            # Determine dominant type for this trait
            dominant = 'Physical' if physical_score > emotional_score else 'Emotional'
            
            trait_scores[trait_name] = TraitScore(
                trait_name=trait_name,
                physical_score=physical_score,
                emotional_score=emotional_score,
                total_questions=total_questions,
                physical_percentage=physical_pct,
                emotional_percentage=emotional_pct,
                dominant_type=dominant
            )
        
        return trait_scores
    
    def _determine_types(self, trait_scores: Dict[str, TraitScore]) -> Tuple[str, str]:
        """Determine Primary and Secondary types based on HMI methodology"""
        
        # Calculate weighted scores
        weighted_physical = 0
        weighted_emotional = 0
        total_weight = 0
        
        for trait_name, score in trait_scores.items():
            weight = self.trait_weights.get(trait_name, 1.0)
            weighted_physical += score.physical_score * weight
            weighted_emotional += score.emotional_score * weight
            total_weight += score.total_questions * weight
        
        # Primary type: Overall dominant type
        primary_type = 'Physical' if weighted_physical > weighted_emotional else 'Emotional'
        
        # Secondary type: Look at trait where they score opposite to primary
        # This is simplified - full HMI uses caretaker analysis
        trait_dominance = {
            trait_name: score.dominant_type 
            for trait_name, score in trait_scores.items()
        }
        
        # Count traits that are Physical vs Emotional
        physical_traits = sum(1 for t in trait_dominance.values() if t == 'Physical')
        emotional_traits = sum(1 for t in trait_dominance.values() if t == 'Emotional')
        
        # If traits are mixed (not all same), secondary is the minority
        if physical_traits > 0 and emotional_traits > 0:
            if primary_type == 'Physical':
                secondary_type = 'Emotional' if emotional_traits >= 1 else 'Physical'
            else:
                secondary_type = 'Physical' if physical_traits >= 1 else 'Emotional'
        else:
            # If all traits same as primary, secondary is also same
            secondary_type = primary_type
        
        return primary_type, secondary_type
    
    def _calculate_ep_type(self, primary_type: str, secondary_type: str) -> str:
        """Calculate the two-letter EP type"""
        primary_letter = 'P' if primary_type == 'Physical' else 'E'
        secondary_letter = 'P' if secondary_type == 'Physical' else 'E'
        return primary_letter + secondary_letter
    
    def _calculate_overall_percentages(self, trait_scores: Dict[str, TraitScore]) -> Tuple[float, float]:
        """Calculate overall Physical and Emotional percentages"""
        total_physical = sum(score.physical_score for score in trait_scores.values())
        total_emotional = sum(score.emotional_score for score in trait_scores.values())
        total_responses = total_physical + total_emotional
        
        if total_responses > 0:
            physical_pct = (total_physical / total_responses) * 100
            emotional_pct = (total_emotional / total_responses) * 100
        else:
            physical_pct = 0
            emotional_pct = 0
        
        return physical_pct, emotional_pct
    
    def _calculate_confidence(self, trait_scores: Dict[str, TraitScore], 
                             overall_physical: float, overall_emotional: float) -> float:
        """
        Calculate confidence score (how clear the type determination is)
        Higher score = more definitive type
        """
        # Confidence based on how far from 50/50 the overall split is
        difference = abs(overall_physical - overall_emotional)
        
        # Also consider consistency across traits
        dominant_types = [score.dominant_type for score in trait_scores.values()]
        physical_count = sum(1 for t in dominant_types if t == 'Physical')
        emotional_count = sum(1 for t in dominant_types if t == 'Emotional')
        consistency = abs(physical_count - emotional_count) / len(dominant_types)
        
        # Combine both factors
        confidence = (difference + (consistency * 100)) / 2
        
        return min(100, max(0, confidence))
    
    def export_results(self, profile: EPProfile, filepath: str):
        """Export scoring results to JSON"""
        results = {
            'ep_type': profile.ep_type,
            'primary_type': profile.primary_type,
            'secondary_type': profile.secondary_type,
            'overall_physical_percentage': profile.overall_physical_percentage,
            'overall_emotional_percentage': profile.overall_emotional_percentage,
            'confidence_score': profile.confidence_score,
            'trait_scores': {
                trait_name: {
                    'physical_score': score.physical_score,
                    'emotional_score': score.emotional_score,
                    'physical_percentage': score.physical_percentage,
                    'emotional_percentage': score.emotional_percentage,
                    'dominant_type': score.dominant_type
                }
                for trait_name, score in profile.trait_scores.items()
            }
        }
        
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(results, f, indent=2, ensure_ascii=False)

if __name__ == '__main__':
    # Test with sample responses
    print("Testing E&P Scoring Engine...")
    
    # Sample responses (mostly Physical)
    sample_responses = {i: 'physical' for i in range(1, 31)}
    sample_responses.update({i: 'emotional' for i in range(31, 46)})
    
    engine = EPScoringEngine()
    profile = engine.score_responses(sample_responses)
    
    print(f"\nResults:")
    print(f"  EP Type: {profile.ep_type}")
    print(f"  Primary: {profile.primary_type}")
    print(f"  Secondary: {profile.secondary_type}")
    print(f"  Physical: {profile.overall_physical_percentage:.1f}%")
    print(f"  Emotional: {profile.overall_emotional_percentage:.1f}%")
    print(f"  Confidence: {profile.confidence_score:.1f}%")
    
    print(f"\nTrait Breakdown:")
    for trait_name, score in profile.trait_scores.items():
        print(f"  {trait_name.capitalize()}: {score.dominant_type} "
              f"({score.physical_percentage:.0f}% P / {score.emotional_percentage:.0f}% E)")
    
    # Export
    engine.export_results(profile, 'sample_ep_profile.json')
    print(f"\nExported to: sample_ep_profile.json")
