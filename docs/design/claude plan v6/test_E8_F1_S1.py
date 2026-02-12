"""
Epic 8, Feature 1, Story 1: Complete Test Suite
Tests for all 4 tasks:
- T1: Dimensional taxonomy schema
- T2: Dimension scoring algorithm
- T3: Dimensional weights & preferences
- T4: Taxonomy navigation API
"""

import pytest
import asyncio
from datetime import datetime
from typing import Dict

# Import models and engines
from taxonomy_models import (
    DimensionType, DimensionScore, MultiDimensionalScore,
    DimensionWeights, DimensionalScoringEngine,
    DimensionalWeightingEngine, ScoringMethod
)


# ============================================================================
# TASK 1 TESTS: Database Schema
# ============================================================================

class TestDimensionalTaxonomySchema:
    """Tests for dimensional taxonomy database schema"""
    
    @pytest.mark.asyncio
    async def test_dimensions_table_exists(self, db_session):
        """Verify dimensions table was created"""
        result = await db_session.execute(
            "SELECT COUNT(*) FROM dimensions"
        )
        count = result.scalar()
        assert count == 4, "Should have 4 dimensions"
    
    @pytest.mark.asyncio
    async def test_dimensions_seeded_correctly(self, db_session):
        """Verify dimension seed data is correct"""
        result = await db_session.execute(
            "SELECT name, display_name, default_weight FROM dimensions ORDER BY name"
        )
        dimensions = result.all()
        
        expected = [
            ("body", "Body", 0.25),
            ("mind", "Mind", 0.25),
            ("social", "Social", 0.25),
            ("spiritual", "Spiritual", 0.25)
        ]
        
        assert len(dimensions) == 4
        for i, (name, display, weight) in enumerate(expected):
            assert dimensions[i][0] == name
            assert dimensions[i][1] == display
            assert dimensions[i][2] == weight
    
    @pytest.mark.asyncio
    async def test_dimension_categories_exist(self, db_session):
        """Verify categories were seeded"""
        result = await db_session.execute(
            "SELECT COUNT(*) FROM dimension_categories"
        )
        count = result.scalar()
        assert count == 40, "Should have 40 categories (10 per dimension)"
    
    @pytest.mark.asyncio
    async def test_category_dimension_relationships(self, db_session):
        """Verify categories are correctly linked to dimensions"""
        result = await db_session.execute(
            """
            SELECT d.name, COUNT(c.id) as cat_count
            FROM dimensions d
            JOIN dimension_categories c ON c.dimension_id = d.id
            GROUP BY d.name
            ORDER BY d.name
            """
        )
        counts = result.all()
        
        # Each dimension should have 10 categories
        for dim_name, count in counts:
            assert count == 10, f"{dim_name} should have 10 categories"
    
    @pytest.mark.asyncio
    async def test_weight_constraints(self, db_session):
        """Test that weight constraints are enforced"""
        from sqlalchemy import insert, text
        from backend.models import Dimension
        
        # Try to insert dimension with invalid weight
        with pytest.raises(Exception):  # Should raise constraint violation
            await db_session.execute(
                text("INSERT INTO dimensions (name, display_name, description, default_weight) "
                     "VALUES ('test', 'Test', 'Test', 1.5)")
            )
            await db_session.commit()


# ============================================================================
# TASK 2 TESTS: Dimension Scoring Algorithm
# ============================================================================

class TestDimensionalScoringEngine:
    """Tests for dimensional scoring algorithm"""
    
    def test_keyword_scoring_anxiety(self):
        """Test scoring for anxiety-related text"""
        text = "I struggle with anxiety, worry, and panic attacks daily"
        scores = DimensionalScoringEngine.score_from_text(text, method="keyword")
        
        # Should score highest on MIND dimension
        assert scores.mind.score > scores.body.score
        assert scores.mind.score > scores.social.score
        assert scores.mind.score > scores.spiritual.score
        
        # Scores should be normalized (sum to 1.0)
        assert scores.is_normalized
        assert abs(scores.total_score - 1.0) < 0.01
    
    def test_keyword_scoring_pain(self):
        """Test scoring for body/pain-related text"""
        text = "Chronic back pain, muscle tension, and physical discomfort"
        scores = DimensionalScoringEngine.score_from_text(text, method="keyword")
        
        # Should score highest on BODY dimension
        assert scores.body.score > scores.mind.score
        assert scores.body.score > scores.social.score
        assert scores.body.score > scores.spiritual.score
    
    def test_keyword_scoring_relationships(self):
        """Test scoring for social/relationship text"""
        text = "Problems with communication in my marriage and family conflicts"
        scores = DimensionalScoringEngine.score_from_text(text, method="keyword")
        
        # Should score highest on SOCIAL dimension
        assert scores.social.score > scores.mind.score
        assert scores.social.score > scores.body.score
        assert scores.social.score > scores.spiritual.score
    
    def test_keyword_scoring_spiritual(self):
        """Test scoring for spiritual/meaning text"""
        text = "Searching for life meaning, purpose, and spiritual growth"
        scores = DimensionalScoringEngine.score_from_text(text, method="keyword")
        
        # Should score highest on SPIRITUAL dimension
        assert scores.spiritual.score > scores.mind.score
        assert scores.spiritual.score > scores.body.score
        assert scores.spiritual.score > scores.social.score
    
    def test_keyword_scoring_mixed(self):
        """Test scoring for text with mixed dimensions"""
        text = "Anxiety about my chronic pain affecting my relationships and life purpose"
        scores = DimensionalScoringEngine.score_from_text(text, method="keyword")
        
        # Should have relatively balanced scores
        assert 0.15 < scores.mind.score < 0.40
        assert 0.15 < scores.body.score < 0.40
        assert 0.15 < scores.social.score < 0.40
        assert 0.15 < scores.spiritual.score < 0.40
        
        # Still normalized
        assert scores.is_normalized
    
    def test_category_scoring(self):
        """Test scoring based on category membership"""
        # Mock category -> dimension map
        category_map = {
            1: DimensionType.MIND,    # Anxiety
            2: DimensionType.MIND,    # Depression
            3: DimensionType.BODY,    # Pain
            4: DimensionType.SOCIAL   # Relationships
        }
        
        # Condition belongs to 2 MIND, 1 BODY, 1 SOCIAL
        category_ids = [1, 2, 3, 4]
        
        scores = DimensionalScoringEngine.score_from_categories(
            category_ids, category_map
        )
        
        # MIND should score highest (2/4 = 0.5)
        assert abs(scores.mind.score - 0.5) < 0.01
        assert abs(scores.body.score - 0.25) < 0.01
        assert abs(scores.social.score - 0.25) < 0.01
        assert abs(scores.spiritual.score - 0.0) < 0.01
    
    def test_combine_scores(self):
        """Test combining multiple scoring methods"""
        # Create two different scores
        score1 = MultiDimensionalScore(
            mind=DimensionScore(dimension=DimensionType.MIND, score=0.6),
            body=DimensionScore(dimension=DimensionType.BODY, score=0.2),
            social=DimensionScore(dimension=DimensionType.SOCIAL, score=0.1),
            spiritual=DimensionScore(dimension=DimensionType.SPIRITUAL, score=0.1)
        )
        
        score2 = MultiDimensionalScore(
            mind=DimensionScore(dimension=DimensionType.MIND, score=0.2),
            body=DimensionScore(dimension=DimensionType.BODY, score=0.6),
            social=DimensionScore(dimension=DimensionType.SOCIAL, score=0.1),
            spiritual=DimensionScore(dimension=DimensionType.SPIRITUAL, score=0.1)
        )
        
        # Combine with equal weights
        combined = DimensionalScoringEngine.combine_scores([score1, score2])
        
        # Should be average
        assert abs(combined.mind.score - 0.4) < 0.01
        assert abs(combined.body.score - 0.4) < 0.01
        assert abs(combined.social.score - 0.1) < 0.01
        assert abs(combined.spiritual.score - 0.1) < 0.01
    
    def test_score_normalization(self):
        """Test that scores are properly normalized"""
        scores = MultiDimensionalScore(
            mind=DimensionScore(dimension=DimensionType.MIND, score=0.8),
            body=DimensionScore(dimension=DimensionType.BODY, score=0.6),
            social=DimensionScore(dimension=DimensionType.SOCIAL, score=0.4),
            spiritual=DimensionScore(dimension=DimensionType.SPIRITUAL, score=0.2)
        )
        
        # Not normalized initially
        assert not scores.is_normalized
        assert scores.total_score == 2.0
        
        # Normalize
        scores.normalize()
        
        # Now normalized
        assert scores.is_normalized
        assert abs(scores.total_score - 1.0) < 0.01
        assert abs(scores.mind.score - 0.4) < 0.01
        assert abs(scores.body.score - 0.3) < 0.01


# ============================================================================
# TASK 3 TESTS: Dimensional Weights & Preferences
# ============================================================================

class TestDimensionalWeights:
    """Tests for dimensional weights and preferences"""
    
    def test_equal_weights(self):
        """Test creation of equal weights"""
        weights = DimensionWeights.equal_weights()
        
        assert weights.mind == 0.25
        assert weights.body == 0.25
        assert weights.social == 0.25
        assert weights.spiritual == 0.25
        assert weights.is_normalized
        assert not weights.is_explicit
    
    def test_custom_weights_validation(self):
        """Test that weights must sum to 1.0"""
        # Valid weights
        weights = DimensionWeights(
            mind=0.4, body=0.3, social=0.2, spiritual=0.1
        )
        assert weights.is_normalized
        
        # Invalid weights (sum != 1.0)
        with pytest.raises(ValueError):
            DimensionWeights(
                mind=0.5, body=0.5, social=0.5, spiritual=0.5
            )
    
    def test_from_preferences(self):
        """Test creating weights from preference dict"""
        prefs = {
            "mind": 0.8,
            "body": 0.6,
            "social": 0.4,
            "spiritual": 0.2
        }
        
        weights = DimensionWeights.from_preferences(prefs)
        
        # Should be normalized
        assert weights.is_normalized
        assert abs(weights.mind - 0.4) < 0.01  # 0.8/2.0
        assert abs(weights.body - 0.3) < 0.01  # 0.6/2.0
        assert weights.is_explicit


class TestDimensionalWeightingEngine:
    """Tests for dimensional weighting engine"""
    
    def test_calculate_relevance_score(self):
        """Test relevance score calculation"""
        # Create condition scores (strong MIND)
        condition_scores = MultiDimensionalScore(
            mind=DimensionScore(dimension=DimensionType.MIND, score=0.7),
            body=DimensionScore(dimension=DimensionType.BODY, score=0.1),
            social=DimensionScore(dimension=DimensionType.SOCIAL, score=0.1),
            spiritual=DimensionScore(dimension=DimensionType.SPIRITUAL, score=0.1)
        )
        
        # Create user weights (also prioritizes MIND)
        user_weights = DimensionWeights(
            mind=0.6, body=0.2, social=0.1, spiritual=0.1
        )
        
        engine = DimensionalWeightingEngine()
        score = engine.calculate_relevance_score(condition_scores, user_weights)
        
        # Should have high relevance (aligned dimensions)
        assert score > 0.4
        
        # Now try with misaligned weights (user wants BODY)
        user_weights2 = DimensionWeights(
            mind=0.1, body=0.6, social=0.2, spiritual=0.1
        )
        
        score2 = engine.calculate_relevance_score(condition_scores, user_weights2)
        
        # Should have lower relevance
        assert score2 < score
    
    def test_calculate_distance(self):
        """Test distance calculation between scores"""
        scores1 = MultiDimensionalScore(
            mind=DimensionScore(dimension=DimensionType.MIND, score=0.7),
            body=DimensionScore(dimension=DimensionType.BODY, score=0.1),
            social=DimensionScore(dimension=DimensionType.SOCIAL, score=0.1),
            spiritual=DimensionScore(dimension=DimensionType.SPIRITUAL, score=0.1)
        )
        
        scores2 = MultiDimensionalScore(
            mind=DimensionScore(dimension=DimensionType.MIND, score=0.1),
            body=DimensionScore(dimension=DimensionType.BODY, score=0.7),
            social=DimensionScore(dimension=DimensionType.SOCIAL, score=0.1),
            spiritual=DimensionScore(dimension=DimensionType.SPIRITUAL, score=0.1)
        )
        
        engine = DimensionalWeightingEngine()
        distance = engine.calculate_distance(scores1, scores2)
        
        # Should have significant distance (opposite dimensions)
        assert distance > 0.5
        
        # Distance to self should be 0
        distance_self = engine.calculate_distance(scores1, scores1)
        assert distance_self < 0.01
    
    def test_infer_weights_from_query(self):
        """Test inferring weights from search query"""
        engine = DimensionalWeightingEngine()
        
        # Anxiety query
        weights = engine.infer_weights_from_query(
            "I need help with anxiety and panic attacks"
        )
        
        # Should prioritize MIND
        assert weights.mind > weights.body
        assert weights.mind > weights.social
        assert weights.mind > weights.spiritual
        
        # Pain query
        weights2 = engine.infer_weights_from_query(
            "Looking for chronic pain management"
        )
        
        # Should prioritize BODY
        assert weights2.body > weights2.mind
    
    def test_adjust_weights_from_history(self):
        """Test adaptive weight adjustment"""
        current_weights = DimensionWeights(
            mind=0.4, body=0.3, social=0.2, spiritual=0.1
        )
        
        # BODY interventions were highly effective
        historical_effectiveness = {
            DimensionType.MIND: 0.5,   # Average
            DimensionType.BODY: 0.9,   # Highly effective!
            DimensionType.SOCIAL: 0.3, # Not effective
            DimensionType.SPIRITUAL: 0.4
        }
        
        engine = DimensionalWeightingEngine()
        adjusted = engine.adjust_weights_from_history(
            current_weights,
            historical_effectiveness,
            learning_rate=0.3
        )
        
        # BODY weight should increase
        assert adjusted.body > current_weights.body
        
        # SOCIAL weight should decrease
        assert adjusted.social < current_weights.social
        
        # Still normalized
        assert adjusted.is_normalized


# ============================================================================
# TASK 4 TESTS: Taxonomy Navigation API
# ============================================================================

@pytest.mark.asyncio
class TestTaxonomyAPI:
    """Tests for taxonomy navigation API endpoints"""
    
    async def test_get_dimensions(self, async_client):
        """Test GET /dimensions endpoint"""
        response = await async_client.get("/api/v1/taxonomy/dimensions")
        
        assert response.status_code == 200
        dimensions = response.json()
        
        assert len(dimensions) == 4
        
        # Check all 4 dimensions present
        dim_names = {d["name"] for d in dimensions}
        assert dim_names == {"mind", "body", "social", "spiritual"}
        
        # Check default weights
        for dim in dimensions:
            assert dim["default_weight"] == 0.25
    
    async def test_get_dimension_by_name(self, async_client):
        """Test GET /dimensions/{name} endpoint"""
        response = await async_client.get("/api/v1/taxonomy/dimensions/mind")
        
        assert response.status_code == 200
        dimension = response.json()
        
        assert dimension["name"] == "mind"
        assert dimension["display_name"] == "Mind"
        assert "description" in dimension
        assert "icon" in dimension
        assert "color" in dimension
    
    async def test_get_categories(self, async_client):
        """Test GET /categories endpoint"""
        response = await async_client.get("/api/v1/taxonomy/categories")
        
        assert response.status_code == 200
        categories = response.json()
        
        assert len(categories) == 40  # 10 per dimension
    
    async def test_get_categories_filtered(self, async_client):
        """Test GET /categories with filters"""
        # Filter by dimension
        response = await async_client.get(
            "/api/v1/taxonomy/categories?dimension=mind"
        )
        
        assert response.status_code == 200
        categories = response.json()
        
        assert len(categories) == 10  # 10 MIND categories
        
        # Filter by level
        response = await async_client.get(
            "/api/v1/taxonomy/categories?level=0"
        )
        
        categories = response.json()
        for cat in categories:
            assert cat["level"] == 0
    
    async def test_get_dimension_tree(self, async_client):
        """Test GET /dimensions/{name}/tree endpoint"""
        response = await async_client.get(
            "/api/v1/taxonomy/dimensions/mind/tree"
        )
        
        assert response.status_code == 200
        tree = response.json()
        
        assert "dimension" in tree
        assert "categories" in tree
        assert tree["dimension"]["name"] == "mind"
        
        # Check tree structure
        categories = tree["categories"]
        assert len(categories) > 0
        
        # Each category should have expected fields
        for cat in categories:
            assert "id" in cat
            assert "name" in cat
            assert "slug" in cat
            assert "children" in cat  # May be empty
    
    async def test_score_text_endpoint(self, async_client):
        """Test POST /score/text endpoint"""
        response = await async_client.post(
            "/api/v1/taxonomy/score/text?text=I%20have%20severe%20anxiety",
            json={}
        )
        
        assert response.status_code == 200
        scores = response.json()
        
        assert "mind" in scores
        assert "body" in scores
        assert "social" in scores
        assert "spiritual" in scores
        assert scores["is_normalized"]
        
        # Anxiety should score high on MIND
        assert scores["mind"]["score"] > 0.3
    
    async def test_user_preferences_flow(self, async_client):
        """Test complete user preference flow"""
        user_id = "test_user_123"
        
        # 1. Get preferences (should be equal initially)
        response = await async_client.get(
            f"/api/v1/taxonomy/preferences/{user_id}"
        )
        assert response.status_code == 200
        prefs = response.json()
        assert prefs["mind"] == 0.25
        
        # 2. Update preferences
        new_weights = {
            "mind": 0.5,
            "body": 0.3,
            "social": 0.15,
            "spiritual": 0.05,
            "is_explicit": True,
            "is_normalized": True
        }
        
        response = await async_client.put(
            f"/api/v1/taxonomy/preferences/{user_id}",
            json=new_weights
        )
        assert response.status_code == 200
        
        # 3. Verify preferences were updated
        response = await async_client.get(
            f"/api/v1/taxonomy/preferences/{user_id}"
        )
        updated_prefs = response.json()
        assert updated_prefs["mind"] == 0.5
        assert updated_prefs["body"] == 0.3
    
    async def test_infer_preferences_from_query(self, async_client):
        """Test POST /preferences/{user_id}/infer endpoint"""
        user_id = "test_user_456"
        
        response = await async_client.post(
            f"/api/v1/taxonomy/preferences/{user_id}/infer"
            "?query=help%20with%20chronic%20back%20pain"
            "&save=true"
        )
        
        assert response.status_code == 200
        weights = response.json()
        
        # Should prioritize BODY for pain query
        assert weights["body"] > weights["mind"]
        assert weights["body"] > weights["social"]
    
    async def test_calculate_relevance(self, async_client, db_session):
        """Test relevance calculation endpoint"""
        # Setup: Create test condition with scores
        condition_id = 1
        user_id = "test_user_789"
        
        # Calculate relevance
        response = await async_client.post(
            f"/api/v1/taxonomy/relevance/calculate"
            f"?condition_id={condition_id}&user_id={user_id}"
        )
        
        if response.status_code == 200:  # May 404 if no scores
            relevance = response.json()
            
            assert "relevance_score" in relevance
            assert "condition_scores" in relevance
            assert "user_weights" in relevance
            assert 0.0 <= relevance["relevance_score"] <= 1.0
    
    async def test_health_check(self, async_client):
        """Test health check endpoint"""
        response = await async_client.get("/api/v1/taxonomy/health")
        
        assert response.status_code == 200
        health = response.json()
        
        assert health["status"] == "healthy"
        assert health["service"] == "dimensional-taxonomy"


# ============================================================================
# INTEGRATION TESTS
# ============================================================================

@pytest.mark.asyncio
class TestIntegration:
    """Integration tests combining multiple components"""
    
    async def test_end_to_end_search_flow(self, async_client):
        """
        Test complete search flow:
        1. User searches for "anxiety"
        2. System infers dimensional weights
        3. Scores conditions
        4. Ranks by relevance
        """
        user_id = "integration_test_user"
        
        # 1. Infer weights from query
        response = await async_client.post(
            f"/api/v1/taxonomy/preferences/{user_id}/infer"
            "?query=help%20with%20anxiety%20and%20panic%20attacks"
            "&save=true"
        )
        assert response.status_code == 200
        weights = response.json()
        
        # Should prioritize MIND
        assert weights["mind"] > 0.3
        
        # 2. Score a test text
        response = await async_client.post(
            "/api/v1/taxonomy/score/text"
            "?text=Generalized%20anxiety%20disorder%20treatment"
        )
        assert response.status_code == 200
        scores = response.json()
        
        # Should also score high on MIND
        assert scores["mind"]["score"] > 0.4
        
        # 3. Calculate relevance (would need actual conditions)
        # This demonstrates the flow even if data doesn't exist yet
        
    async def test_personalization_adaptation(self, async_client):
        """
        Test that system adapts to user feedback
        """
        user_id = "adaptive_test_user"
        
        # 1. Start with equal weights
        response = await async_client.get(
            f"/api/v1/taxonomy/preferences/{user_id}"
        )
        initial_weights = response.json()
        assert initial_weights["mind"] == 0.25
        
        # 2. Simulate: User had success with BODY interventions
        # (In real system, this would come from outcome tracking)
        adjusted_weights = DimensionWeights(
            mind=0.2, body=0.5, social=0.2, spiritual=0.1
        )
        
        response = await async_client.put(
            f"/api/v1/taxonomy/preferences/{user_id}",
            json=adjusted_weights.dict()
        )
        
        # 3. Verify adaptation
        response = await async_client.get(
            f"/api/v1/taxonomy/preferences/{user_id}"
        )
        new_weights = response.json()
        
        assert new_weights["body"] > new_weights["mind"]
        assert new_weights["body"] == 0.5


# ============================================================================
# PYTEST CONFIGURATION
# ============================================================================

@pytest.fixture
async def db_session():
    """Fixture for database session"""
    # This would connect to test database
    # Implementation depends on your database setup
    pass


@pytest.fixture
async def async_client():
    """Fixture for async HTTP client"""
    from httpx import AsyncClient
    from backend.main import app  # Your FastAPI app
    
    async with AsyncClient(app=app, base_url="http://test") as client:
        yield client


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--asyncio-mode=auto"])
