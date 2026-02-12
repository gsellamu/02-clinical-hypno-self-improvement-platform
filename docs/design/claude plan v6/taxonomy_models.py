"""
Epic 8, Feature 1, Story 1, Tasks 2-3:
- Task 2: Create dimension scoring algorithm
- Task 3: Implement dimensional weights & preferences

Pydantic Models + Service Layer
"""

from pydantic import BaseModel, Field, validator, root_validator
from typing import Dict, List, Optional, Tuple
from enum import Enum
from datetime import datetime
import math


# ============================================================================
# ENUMS
# ============================================================================

class DimensionType(str, Enum):
    """Four primary dimensions"""
    MIND = "mind"
    BODY = "body"
    SOCIAL = "social"
    SPIRITUAL = "spiritual"


class ScoringMethod(str, Enum):
    """How was the score determined?"""
    MANUAL = "manual"
    AI_GENERATED = "ai_generated"
    COLLABORATIVE = "collaborative"
    HISTORICAL = "historical"


# ============================================================================
# PYDANTIC MODELS
# ============================================================================

class DimensionBase(BaseModel):
    """Base dimension model"""
    name: DimensionType
    display_name: str
    description: str
    icon: Optional[str] = None
    color: Optional[str] = None
    default_weight: float = Field(0.25, ge=0.0, le=1.0)


class DimensionCreate(DimensionBase):
    """Model for creating a dimension"""
    pass


class DimensionResponse(DimensionBase):
    """Model for dimension API responses"""
    id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class DimensionCategoryBase(BaseModel):
    """Base category model"""
    name: str = Field(..., max_length=100)
    slug: str = Field(..., max_length=100)
    description: Optional[str] = Field(None, max_length=500)
    parent_category_id: Optional[int] = None
    level: int = Field(0, ge=0, le=5)
    sort_order: int = Field(0, ge=0)


class DimensionCategoryCreate(DimensionCategoryBase):
    """Model for creating a category"""
    dimension_id: int


class DimensionCategoryResponse(DimensionCategoryBase):
    """Model for category API responses"""
    id: int
    dimension_id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class DimensionScore(BaseModel):
    """
    Dimensional score for a single dimension
    
    Score represents relevance/applicability (0.0 to 1.0)
    Confidence represents certainty in the score (0.0 to 1.0)
    """
    dimension: DimensionType
    score: float = Field(..., ge=0.0, le=1.0, description="Relevance score")
    confidence: float = Field(0.8, ge=0.0, le=1.0, description="Confidence level")
    category_scores: Dict[str, float] = Field(default_factory=dict)
    
    @validator('score', 'confidence')
    def validate_range(cls, v):
        if not (0.0 <= v <= 1.0):
            raise ValueError("Score must be between 0.0 and 1.0")
        return round(v, 4)


class MultiDimensionalScore(BaseModel):
    """
    Complete 4D score for a condition/item
    
    Scores represent the distribution across all 4 dimensions
    Sum of scores should typically equal 1.0 (normalized)
    """
    mind: DimensionScore
    body: DimensionScore
    social: DimensionScore
    spiritual: DimensionScore
    
    # Overall metadata
    total_score: float = Field(1.0, description="Sum of all dimension scores")
    is_normalized: bool = Field(True, description="Are scores normalized to sum to 1.0?")
    scoring_method: ScoringMethod = ScoringMethod.AI_GENERATED
    scored_by: Optional[str] = None
    scoring_notes: Optional[str] = None
    
    @root_validator
    def validate_scores(cls, values):
        """Validate that scores make sense"""
        mind = values.get('mind')
        body = values.get('body')
        social = values.get('social')
        spiritual = values.get('spiritual')
        
        if all([mind, body, social, spiritual]):
            total = sum([mind.score, body.score, social.score, spiritual.score])
            values['total_score'] = round(total, 4)
            
            # Check if normalized (allow small floating point error)
            if abs(total - 1.0) > 0.01:
                values['is_normalized'] = False
        
        return values
    
    def to_dict(self) -> Dict[str, float]:
        """Convert to simple dict of dimension: score"""
        return {
            "mind": self.mind.score,
            "body": self.body.score,
            "social": self.social.score,
            "spiritual": self.spiritual.score
        }
    
    def normalize(self) -> 'MultiDimensionalScore':
        """Normalize scores to sum to 1.0"""
        total = self.total_score
        if total == 0:
            # Equal distribution if all zeros
            normalized_score = 0.25
            self.mind.score = normalized_score
            self.body.score = normalized_score
            self.social.score = normalized_score
            self.spiritual.score = normalized_score
        else:
            self.mind.score /= total
            self.body.score /= total
            self.social.score /= total
            self.spiritual.score /= total
        
        self.total_score = 1.0
        self.is_normalized = True
        return self


class DimensionWeights(BaseModel):
    """
    User-specific or context-specific weights for each dimension
    
    Weights determine relative importance in search/recommendation
    Sum of weights should equal 1.0 (normalized)
    """
    mind: float = Field(0.25, ge=0.0, le=1.0)
    body: float = Field(0.25, ge=0.0, le=1.0)
    social: float = Field(0.25, ge=0.0, le=1.0)
    spiritual: float = Field(0.25, ge=0.0, le=1.0)
    
    # Metadata
    is_explicit: bool = Field(False, description="Set by user vs inferred")
    is_normalized: bool = Field(True, description="Sum equals 1.0")
    
    @root_validator
    def validate_weights(cls, values):
        """Validate that weights sum to 1.0"""
        total = sum([
            values.get('mind', 0.25),
            values.get('body', 0.25),
            values.get('social', 0.25),
            values.get('spiritual', 0.25)
        ])
        
        values['is_normalized'] = abs(total - 1.0) < 0.01
        
        if not values['is_normalized']:
            raise ValueError(f"Weights must sum to 1.0, got {total}")
        
        return values
    
    def to_dict(self) -> Dict[str, float]:
        """Convert to simple dict"""
        return {
            "mind": self.mind,
            "body": self.body,
            "social": self.social,
            "spiritual": self.spiritual
        }
    
    @classmethod
    def equal_weights(cls) -> 'DimensionWeights':
        """Create equal weights (0.25 each)"""
        return cls(
            mind=0.25, body=0.25, social=0.25, spiritual=0.25,
            is_explicit=False, is_normalized=True
        )
    
    @classmethod
    def from_preferences(cls, preferences: Dict[str, float]) -> 'DimensionWeights':
        """Create weights from user preferences"""
        total = sum(preferences.values())
        if total == 0:
            return cls.equal_weights()
        
        # Normalize
        return cls(
            mind=preferences.get('mind', 0.25) / total,
            body=preferences.get('body', 0.25) / total,
            social=preferences.get('social', 0.25) / total,
            spiritual=preferences.get('spiritual', 0.25) / total,
            is_explicit=True,
            is_normalized=True
        )


class UserDimensionPreferenceBase(BaseModel):
    """Base model for user preferences"""
    dimension: DimensionType
    weight: float = Field(..., ge=0.0, le=1.0)
    is_explicit: bool = False
    effectiveness_score: Optional[float] = Field(None, ge=0.0, le=1.0)
    preference_reason: Optional[str] = Field(None, max_length=200)


class UserDimensionPreferenceCreate(UserDimensionPreferenceBase):
    """Model for creating user preference"""
    user_id: str


class UserDimensionPreferenceResponse(UserDimensionPreferenceBase):
    """Model for preference API responses"""
    id: int
    user_id: str
    dimension_id: int
    last_adjusted: datetime
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


# ============================================================================
# SCORING ALGORITHM - TASK 2
# ============================================================================

class DimensionalScoringEngine:
    """
    Core engine for calculating dimensional scores
    
    Uses multiple scoring methods:
    1. Keyword-based scoring (symptom/condition keywords)
    2. Category-based scoring (which categories does it belong to?)
    3. Semantic scoring (LLM-based understanding)
    4. Historical effectiveness (what worked for similar users?)
    """
    
    # Keyword mappings for each dimension
    DIMENSION_KEYWORDS = {
        DimensionType.MIND: [
            "anxiety", "depression", "stress", "worry", "fear", "panic",
            "trauma", "ptsd", "ocd", "obsessive", "compulsive", "adhd",
            "focus", "concentration", "mood", "emotional", "mental",
            "cognitive", "thinking", "thoughts", "memory", "eating",
            "addiction", "habits", "phobia", "bipolar", "psychosis"
        ],
        DimensionType.BODY: [
            "pain", "chronic", "sleep", "insomnia", "fatigue", "tired",
            "physical", "somatic", "health", "medical", "illness", "disease",
            "autoimmune", "digestive", "ibs", "migraine", "headache",
            "weight", "exercise", "performance", "sexual", "libido",
            "surgery", "recovery", "healing", "symptoms", "body"
        ],
        DimensionType.SOCIAL: [
            "relationship", "communication", "conflict", "social", "people",
            "family", "marriage", "partner", "friend", "work", "workplace",
            "assertiveness", "boundaries", "speaking", "presentation",
            "interaction", "connection", "isolation", "lonely", "rejection",
            "group", "team", "collaboration", "networking", "dating"
        ],
        DimensionType.SPIRITUAL: [
            "meaning", "purpose", "spiritual", "transcendence", "growth",
            "consciousness", "awareness", "mindfulness", "meditation",
            "existential", "life", "death", "grief", "loss", "transition",
            "values", "beliefs", "faith", "soul", "spirit", "enlightenment",
            "integration", "shadow", "archetypes", "self-actualization"
        ]
    }
    
    @classmethod
    def score_from_text(
        cls,
        text: str,
        method: str = "keyword"
    ) -> MultiDimensionalScore:
        """
        Score text content across 4 dimensions
        
        Args:
            text: The text to analyze (condition name, description, etc.)
            method: Scoring method ('keyword', 'semantic', 'hybrid')
        
        Returns:
            MultiDimensionalScore with scores for all 4 dimensions
        """
        text_lower = text.lower()
        
        if method == "keyword":
            return cls._keyword_scoring(text_lower)
        elif method == "semantic":
            # TODO: Implement LLM-based semantic scoring
            return cls._keyword_scoring(text_lower)
        else:
            return cls._keyword_scoring(text_lower)
    
    @classmethod
    def _keyword_scoring(cls, text: str) -> MultiDimensionalScore:
        """
        Score based on keyword matching
        
        Simple but effective: count how many dimension-specific
        keywords appear in the text
        """
        scores = {}
        
        for dimension, keywords in cls.DIMENSION_KEYWORDS.items():
            # Count keyword matches
            matches = sum(1 for keyword in keywords if keyword in text)
            
            # Calculate score (with diminishing returns)
            if matches == 0:
                score = 0.1  # Minimum baseline
            else:
                # Logarithmic scoring for diminishing returns
                score = min(0.9, 0.2 + (0.15 * math.log(matches + 1)))
            
            scores[dimension] = DimensionScore(
                dimension=dimension,
                score=score,
                confidence=0.7 if matches > 0 else 0.5
            )
        
        multi_score = MultiDimensionalScore(
            mind=scores[DimensionType.MIND],
            body=scores[DimensionType.BODY],
            social=scores[DimensionType.SOCIAL],
            spiritual=scores[DimensionType.SPIRITUAL],
            scoring_method=ScoringMethod.AI_GENERATED
        )
        
        # Normalize scores
        return multi_score.normalize()
    
    @classmethod
    def score_from_categories(
        cls,
        category_ids: List[int],
        category_dimension_map: Dict[int, DimensionType]
    ) -> MultiDimensionalScore:
        """
        Score based on category membership
        
        Args:
            category_ids: List of category IDs the condition belongs to
            category_dimension_map: Mapping of category_id -> dimension
        
        Returns:
            MultiDimensionalScore based on category distribution
        """
        dimension_counts = {dim: 0 for dim in DimensionType}
        
        for cat_id in category_ids:
            dimension = category_dimension_map.get(cat_id)
            if dimension:
                dimension_counts[dimension] += 1
        
        total = sum(dimension_counts.values())
        if total == 0:
            # Equal distribution if no categories
            return MultiDimensionalScore(
                mind=DimensionScore(dimension=DimensionType.MIND, score=0.25),
                body=DimensionScore(dimension=DimensionType.BODY, score=0.25),
                social=DimensionScore(dimension=DimensionType.SOCIAL, score=0.25),
                spiritual=DimensionScore(dimension=DimensionType.SPIRITUAL, score=0.25),
                scoring_method=ScoringMethod.COLLABORATIVE
            )
        
        return MultiDimensionalScore(
            mind=DimensionScore(
                dimension=DimensionType.MIND,
                score=dimension_counts[DimensionType.MIND] / total,
                confidence=0.9
            ),
            body=DimensionScore(
                dimension=DimensionType.BODY,
                score=dimension_counts[DimensionType.BODY] / total,
                confidence=0.9
            ),
            social=DimensionScore(
                dimension=DimensionType.SOCIAL,
                score=dimension_counts[DimensionType.SOCIAL] / total,
                confidence=0.9
            ),
            spiritual=DimensionScore(
                dimension=DimensionType.SPIRITUAL,
                score=dimension_counts[DimensionType.SPIRITUAL] / total,
                confidence=0.9
            ),
            scoring_method=ScoringMethod.COLLABORATIVE,
            is_normalized=True
        )
    
    @classmethod
    def combine_scores(
        cls,
        scores: List[MultiDimensionalScore],
        weights: Optional[List[float]] = None
    ) -> MultiDimensionalScore:
        """
        Combine multiple dimensional scores with optional weights
        
        Useful for:
        - Combining keyword + category + semantic scores
        - Ensemble scoring methods
        - Weighted averaging
        """
        if not scores:
            raise ValueError("Must provide at least one score")
        
        if weights is None:
            weights = [1.0 / len(scores)] * len(scores)
        
        if len(weights) != len(scores):
            raise ValueError("Weights must match number of scores")
        
        # Weighted average for each dimension
        combined = {
            "mind": sum(s.mind.score * w for s, w in zip(scores, weights)),
            "body": sum(s.body.score * w for s, w in zip(scores, weights)),
            "social": sum(s.social.score * w for s, w in zip(scores, weights)),
            "spiritual": sum(s.spiritual.score * w for s, w in zip(scores, weights))
        }
        
        # Average confidence
        avg_confidence = sum(
            (s.mind.confidence + s.body.confidence + s.social.confidence + s.spiritual.confidence) / 4
            for s in scores
        ) / len(scores)
        
        result = MultiDimensionalScore(
            mind=DimensionScore(dimension=DimensionType.MIND, score=combined["mind"], confidence=avg_confidence),
            body=DimensionScore(dimension=DimensionType.BODY, score=combined["body"], confidence=avg_confidence),
            social=DimensionScore(dimension=DimensionType.SOCIAL, score=combined["social"], confidence=avg_confidence),
            spiritual=DimensionScore(dimension=DimensionType.SPIRITUAL, score=combined["spiritual"], confidence=avg_confidence),
            scoring_method=ScoringMethod.COLLABORATIVE
        )
        
        return result.normalize()


# ============================================================================
# DIMENSIONAL WEIGHTING ENGINE - TASK 3
# ============================================================================

class DimensionalWeightingEngine:
    """
    Engine for calculating and applying dimensional weights
    
    Weights determine relative importance of each dimension in:
    - Search/recommendation ranking
    - Personalization
    - Treatment planning
    """
    
    @staticmethod
    def calculate_relevance_score(
        item_scores: MultiDimensionalScore,
        user_weights: DimensionWeights
    ) -> float:
        """
        Calculate relevance score using dot product
        
        Score = Σ (item_score_i * user_weight_i) for all dimensions
        
        Higher score = more relevant to user's dimensional preferences
        """
        score = (
            item_scores.mind.score * user_weights.mind +
            item_scores.body.score * user_weights.body +
            item_scores.social.score * user_weights.social +
            item_scores.spiritual.score * user_weights.spiritual
        )
        
        return round(score, 4)
    
    @staticmethod
    def calculate_distance(
        scores1: MultiDimensionalScore,
        scores2: MultiDimensionalScore
    ) -> float:
        """
        Calculate Euclidean distance between two dimensional scores
        
        Useful for:
        - Finding similar conditions
        - Clustering
        - Recommendation diversity
        """
        distance = math.sqrt(
            (scores1.mind.score - scores2.mind.score) ** 2 +
            (scores1.body.score - scores2.body.score) ** 2 +
            (scores1.social.score - scores2.social.score) ** 2 +
            (scores1.spiritual.score - scores2.spiritual.score) ** 2
        )
        
        return round(distance, 4)
    
    @staticmethod
    def infer_weights_from_query(query: str) -> DimensionWeights:
        """
        Infer dimensional weights from user's search query
        
        Uses keyword analysis to determine what dimensions
        the user cares about most
        """
        engine = DimensionalScoringEngine()
        query_scores = engine.score_from_text(query)
        
        # Convert scores to weights
        return DimensionWeights(
            mind=query_scores.mind.score,
            body=query_scores.body.score,
            social=query_scores.social.score,
            spiritual=query_scores.spiritual.score,
            is_explicit=False
        )
    
    @staticmethod
    def adjust_weights_from_history(
        current_weights: DimensionWeights,
        historical_effectiveness: Dict[DimensionType, float],
        learning_rate: float = 0.2
    ) -> DimensionWeights:
        """
        Adjust weights based on historical effectiveness
        
        Implements simple reinforcement learning:
        - Dimensions that worked well → increase weight
        - Dimensions that didn't work → decrease weight
        
        Args:
            current_weights: Current user weights
            historical_effectiveness: Effectiveness score per dimension
            learning_rate: How much to adjust (0.0 to 1.0)
        """
        adjustments = {
            "mind": current_weights.mind * (1 + learning_rate * (historical_effectiveness.get(DimensionType.MIND, 0.5) - 0.5)),
            "body": current_weights.body * (1 + learning_rate * (historical_effectiveness.get(DimensionType.BODY, 0.5) - 0.5)),
            "social": current_weights.social * (1 + learning_rate * (historical_effectiveness.get(DimensionType.SOCIAL, 0.5) - 0.5)),
            "spiritual": current_weights.spiritual * (1 + learning_rate * (historical_effectiveness.get(DimensionType.SPIRITUAL, 0.5) - 0.5))
        }
        
        # Normalize
        total = sum(adjustments.values())
        
        return DimensionWeights(
            mind=adjustments["mind"] / total,
            body=adjustments["body"] / total,
            social=adjustments["social"] / total,
            spiritual=adjustments["spiritual"] / total,
            is_explicit=False
        )
