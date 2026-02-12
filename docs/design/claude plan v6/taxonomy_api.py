"""
Epic 8, Feature 1, Story 1, Task 4: Setup Taxonomy Navigation API

FastAPI Endpoints for:
- Browsing dimensions and categories
- Scoring conditions
- Managing user preferences
- Calculating relevance scores
"""

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, func
from typing import List, Optional, Dict
from datetime import datetime

from taxonomy_models import (
    DimensionResponse, DimensionCategoryResponse,
    MultiDimensionalScore, DimensionWeights,
    UserDimensionPreferenceCreate, UserDimensionPreferenceResponse,
    DimensionalScoringEngine, DimensionalWeightingEngine,
    DimensionType, ScoringMethod
)

# Assuming you have these from your existing backend
# from backend.database import get_db
# from backend.models import Dimension, DimensionCategory, etc.


# ============================================================================
# ROUTER SETUP
# ============================================================================

router = APIRouter(
    prefix="/api/v1/taxonomy",
    tags=["dimensional-taxonomy"],
    responses={404: {"description": "Not found"}}
)


# ============================================================================
# DIMENSIONS ENDPOINTS
# ============================================================================

@router.get("/dimensions", response_model=List[DimensionResponse])
async def get_dimensions(
    db: AsyncSession = Depends(get_db)
):
    """
    Get all 4 dimensions with metadata
    
    Returns:
        List of all dimensions (Mind, Body, Social, Spiritual)
    """
    result = await db.execute(
        select(Dimension).order_by(Dimension.name)
    )
    dimensions = result.scalars().all()
    
    return dimensions


@router.get("/dimensions/{dimension_name}", response_model=DimensionResponse)
async def get_dimension(
    dimension_name: DimensionType,
    db: AsyncSession = Depends(get_db)
):
    """
    Get single dimension by name
    
    Args:
        dimension_name: One of: mind, body, social, spiritual
    """
    result = await db.execute(
        select(Dimension).where(Dimension.name == dimension_name)
    )
    dimension = result.scalar_one_or_none()
    
    if not dimension:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Dimension '{dimension_name}' not found"
        )
    
    return dimension


# ============================================================================
# CATEGORIES ENDPOINTS
# ============================================================================

@router.get("/categories", response_model=List[DimensionCategoryResponse])
async def get_categories(
    dimension: Optional[DimensionType] = None,
    level: Optional[int] = Query(None, ge=0, le=5),
    parent_id: Optional[int] = None,
    db: AsyncSession = Depends(get_db)
):
    """
    Get categories with optional filtering
    
    Args:
        dimension: Filter by dimension (mind, body, social, spiritual)
        level: Filter by hierarchical level (0 = top-level)
        parent_id: Filter by parent category ID
    
    Returns:
        List of matching categories
    """
    query = select(DimensionCategory)
    
    # Apply filters
    filters = []
    
    if dimension:
        # Get dimension ID first
        dim_result = await db.execute(
            select(Dimension.id).where(Dimension.name == dimension)
        )
        dimension_id = dim_result.scalar_one_or_none()
        if dimension_id:
            filters.append(DimensionCategory.dimension_id == dimension_id)
    
    if level is not None:
        filters.append(DimensionCategory.level == level)
    
    if parent_id is not None:
        filters.append(DimensionCategory.parent_category_id == parent_id)
    
    if filters:
        query = query.where(and_(*filters))
    
    query = query.order_by(
        DimensionCategory.dimension_id,
        DimensionCategory.sort_order
    )
    
    result = await db.execute(query)
    categories = result.scalars().all()
    
    return categories


@router.get("/categories/{category_id}", response_model=DimensionCategoryResponse)
async def get_category(
    category_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Get single category by ID"""
    result = await db.execute(
        select(DimensionCategory).where(DimensionCategory.id == category_id)
    )
    category = result.scalar_one_or_none()
    
    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Category {category_id} not found"
        )
    
    return category


@router.get("/dimensions/{dimension_name}/tree")
async def get_dimension_tree(
    dimension_name: DimensionType,
    db: AsyncSession = Depends(get_db)
):
    """
    Get hierarchical category tree for a dimension
    
    Returns nested structure:
    {
        "dimension": {...},
        "categories": [
            {
                "id": 1,
                "name": "Anxiety Disorders",
                "children": [...]
            }
        ]
    }
    """
    # Get dimension
    dim_result = await db.execute(
        select(Dimension).where(Dimension.name == dimension_name)
    )
    dimension = dim_result.scalar_one_or_none()
    
    if not dimension:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Dimension '{dimension_name}' not found"
        )
    
    # Get all categories for this dimension
    cat_result = await db.execute(
        select(DimensionCategory)
        .where(DimensionCategory.dimension_id == dimension.id)
        .order_by(DimensionCategory.level, DimensionCategory.sort_order)
    )
    categories = cat_result.scalars().all()
    
    # Build tree structure
    def build_tree(parent_id=None):
        children = []
        for cat in categories:
            if cat.parent_category_id == parent_id:
                node = {
                    "id": cat.id,
                    "name": cat.name,
                    "slug": cat.slug,
                    "description": cat.description,
                    "level": cat.level,
                    "children": build_tree(cat.id)
                }
                children.append(node)
        return children
    
    return {
        "dimension": {
            "name": dimension.name,
            "display_name": dimension.display_name,
            "description": dimension.description,
            "icon": dimension.icon,
            "color": dimension.color
        },
        "categories": build_tree()
    }


# ============================================================================
# SCORING ENDPOINTS
# ============================================================================

@router.post("/score/text", response_model=MultiDimensionalScore)
async def score_text(
    text: str = Query(..., min_length=5, max_length=1000),
    method: str = Query("keyword", regex="^(keyword|semantic|hybrid)$")
):
    """
    Score text content across 4 dimensions
    
    Useful for:
    - Analyzing user queries
    - Scoring condition descriptions
    - Understanding dimensional distribution
    
    Args:
        text: Text to analyze
        method: Scoring method (keyword, semantic, hybrid)
    
    Returns:
        MultiDimensionalScore with normalized scores
    """
    engine = DimensionalScoringEngine()
    scores = engine.score_from_text(text, method=method)
    
    return scores


@router.post("/score/condition/{condition_id}")
async def score_condition(
    condition_id: int,
    text: Optional[str] = None,
    category_ids: Optional[List[int]] = None,
    method: str = "hybrid",
    db: AsyncSession = Depends(get_db)
):
    """
    Calculate and store dimensional scores for a condition
    
    Uses multiple scoring methods:
    1. Text analysis (if provided)
    2. Category membership (if provided)
    3. Hybrid (combination)
    
    Args:
        condition_id: ID of the condition to score
        text: Optional text description for scoring
        category_ids: Optional list of category IDs
        method: Scoring method
    
    Returns:
        MultiDimensionalScore and saves to database
    """
    engine = DimensionalScoringEngine()
    
    scores_to_combine = []
    weights = []
    
    # Text-based scoring
    if text:
        text_scores = engine.score_from_text(text, method="keyword")
        scores_to_combine.append(text_scores)
        weights.append(0.6)  # 60% weight for text
    
    # Category-based scoring
    if category_ids:
        # Build category -> dimension map
        cat_result = await db.execute(
            select(DimensionCategory.id, Dimension.name)
            .join(Dimension, DimensionCategory.dimension_id == Dimension.id)
            .where(DimensionCategory.id.in_(category_ids))
        )
        category_dimension_map = {row[0]: row[1] for row in cat_result}
        
        category_scores = engine.score_from_categories(
            category_ids,
            category_dimension_map
        )
        scores_to_combine.append(category_scores)
        weights.append(0.4)  # 40% weight for categories
    
    # Combine scores
    if not scores_to_combine:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Must provide either text or category_ids for scoring"
        )
    
    if len(scores_to_combine) == 1:
        final_scores = scores_to_combine[0]
    else:
        final_scores = engine.combine_scores(scores_to_combine, weights)
    
    # Save to database
    from backend.models import ConditionDimensionScore  # Your SQLAlchemy model
    
    # Delete existing scores for this condition
    await db.execute(
        delete(ConditionDimensionScore)
        .where(ConditionDimensionScore.condition_id == condition_id)
    )
    
    # Insert new scores
    for dimension in DimensionType:
        dim_result = await db.execute(
            select(Dimension.id).where(Dimension.name == dimension)
        )
        dimension_id = dim_result.scalar_one()
        
        score_obj = getattr(final_scores, dimension.value)
        
        db_score = ConditionDimensionScore(
            condition_id=condition_id,
            dimension_id=dimension_id,
            score=score_obj.score,
            confidence=score_obj.confidence,
            category_scores=score_obj.category_scores,
            scoring_method=final_scores.scoring_method.value,
            scored_by="api"
        )
        db.add(db_score)
    
    await db.commit()
    
    return final_scores


# ============================================================================
# USER PREFERENCES ENDPOINTS
# ============================================================================

@router.get("/preferences/{user_id}", response_model=DimensionWeights)
async def get_user_preferences(
    user_id: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Get user's dimensional preference weights
    
    Returns:
        DimensionWeights (normalized to sum to 1.0)
    """
    result = await db.execute(
        select(UserDimensionPreference)
        .where(UserDimensionPreference.user_id == user_id)
    )
    preferences = result.scalars().all()
    
    if not preferences:
        # Return equal weights if no preferences set
        return DimensionWeights.equal_weights()
    
    # Build weights dict
    weights_dict = {}
    for pref in preferences:
        # Get dimension name
        dim_result = await db.execute(
            select(Dimension.name).where(Dimension.id == pref.dimension_id)
        )
        dimension_name = dim_result.scalar_one()
        weights_dict[dimension_name.value] = pref.weight
    
    # Ensure all dimensions present
    for dim in DimensionType:
        if dim.value not in weights_dict:
            weights_dict[dim.value] = 0.25
    
    return DimensionWeights(**weights_dict, is_explicit=True)


@router.put("/preferences/{user_id}")
async def update_user_preferences(
    user_id: str,
    weights: DimensionWeights,
    db: AsyncSession = Depends(get_db)
):
    """
    Update user's dimensional preference weights
    
    Args:
        user_id: User identifier
        weights: New dimensional weights (must sum to 1.0)
    
    Returns:
        Updated preferences
    """
    # Delete existing preferences
    await db.execute(
        delete(UserDimensionPreference)
        .where(UserDimensionPreference.user_id == user_id)
    )
    
    # Insert new preferences
    for dimension in DimensionType:
        # Get dimension ID
        dim_result = await db.execute(
            select(Dimension.id).where(Dimension.name == dimension)
        )
        dimension_id = dim_result.scalar_one()
        
        weight_value = getattr(weights, dimension.value)
        
        pref = UserDimensionPreference(
            user_id=user_id,
            dimension_id=dimension_id,
            weight=weight_value,
            is_explicit=weights.is_explicit,
            preference_reason="User updated via API",
            last_adjusted=datetime.utcnow()
        )
        db.add(pref)
    
    await db.commit()
    
    return {"status": "success", "weights": weights}


@router.post("/preferences/{user_id}/infer")
async def infer_preferences_from_query(
    user_id: str,
    query: str = Query(..., min_length=5),
    save: bool = Query(False, description="Save inferred preferences"),
    db: AsyncSession = Depends(get_db)
):
    """
    Infer dimensional preferences from user's search query
    
    Useful for:
    - First-time users (no historical data)
    - Understanding query intent
    - Personalizing search results
    
    Args:
        user_id: User identifier
        query: User's search query
        save: Whether to save inferred preferences
    
    Returns:
        Inferred DimensionWeights
    """
    engine = DimensionalWeightingEngine()
    weights = engine.infer_weights_from_query(query)
    
    if save:
        # Save as implicit preferences
        await db.execute(
            delete(UserDimensionPreference)
            .where(
                and_(
                    UserDimensionPreference.user_id == user_id,
                    UserDimensionPreference.is_explicit == False
                )
            )
        )
        
        for dimension in DimensionType:
            dim_result = await db.execute(
                select(Dimension.id).where(Dimension.name == dimension)
            )
            dimension_id = dim_result.scalar_one()
            
            weight_value = getattr(weights, dimension.value)
            
            pref = UserDimensionPreference(
                user_id=user_id,
                dimension_id=dimension_id,
                weight=weight_value,
                is_explicit=False,
                preference_reason=f"Inferred from query: {query[:50]}",
                last_adjusted=datetime.utcnow()
            )
            db.add(pref)
        
        await db.commit()
    
    return weights


# ============================================================================
# RELEVANCE CALCULATION ENDPOINTS
# ============================================================================

@router.post("/relevance/calculate")
async def calculate_relevance(
    condition_id: int,
    user_id: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Calculate relevance score for a condition given user preferences
    
    Uses dot product: score = Σ (condition_score_i * user_weight_i)
    
    Args:
        condition_id: Condition to score
        user_id: User whose preferences to use
    
    Returns:
        Relevance score (0.0 to 1.0)
    """
    # Get condition scores
    score_result = await db.execute(
        select(ConditionDimensionScore, Dimension.name)
        .join(Dimension, ConditionDimensionScore.dimension_id == Dimension.id)
        .where(ConditionDimensionScore.condition_id == condition_id)
    )
    
    condition_scores_data = {}
    for score, dim_name in score_result:
        condition_scores_data[dim_name.value] = {
            "score": score.score,
            "confidence": score.confidence
        }
    
    if not condition_scores_data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No dimensional scores found for condition {condition_id}"
        )
    
    # Build MultiDimensionalScore
    from taxonomy_models import DimensionScore
    condition_scores = MultiDimensionalScore(
        mind=DimensionScore(dimension=DimensionType.MIND, **condition_scores_data["mind"]),
        body=DimensionScore(dimension=DimensionType.BODY, **condition_scores_data["body"]),
        social=DimensionScore(dimension=DimensionType.SOCIAL, **condition_scores_data["social"]),
        spiritual=DimensionScore(dimension=DimensionType.SPIRITUAL, **condition_scores_data["spiritual"])
    )
    
    # Get user weights
    user_weights = await get_user_preferences(user_id, db)
    
    # Calculate relevance
    engine = DimensionalWeightingEngine()
    relevance_score = engine.calculate_relevance_score(
        condition_scores,
        user_weights
    )
    
    return {
        "condition_id": condition_id,
        "user_id": user_id,
        "relevance_score": relevance_score,
        "condition_scores": condition_scores.to_dict(),
        "user_weights": user_weights.to_dict()
    }


@router.post("/relevance/batch")
async def calculate_batch_relevance(
    condition_ids: List[int],
    user_id: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Calculate relevance scores for multiple conditions
    
    Useful for:
    - Ranking search results
    - Sorting recommendations
    - Personalization
    
    Returns:
        List of conditions with relevance scores, sorted by score (highest first)
    """
    results = []
    
    for condition_id in condition_ids:
        try:
            relevance_data = await calculate_relevance(condition_id, user_id, db)
            results.append(relevance_data)
        except HTTPException:
            # Skip conditions without scores
            continue
    
    # Sort by relevance score (descending)
    results.sort(key=lambda x: x["relevance_score"], reverse=True)
    
    return {
        "user_id": user_id,
        "total_conditions": len(condition_ids),
        "scored_conditions": len(results),
        "results": results
    }


# ============================================================================
# STATISTICS & ANALYTICS ENDPOINTS
# ============================================================================

@router.get("/stats/dimensions")
async def get_dimension_stats(
    db: AsyncSession = Depends(get_db)
):
    """
    Get statistics about dimensional distribution
    
    Returns:
        - Number of conditions per dimension
        - Average scores per dimension
        - Most common categories
    """
    # Count conditions per dimension
    count_result = await db.execute(
        select(
            Dimension.name,
            func.count(ConditionDimensionScore.id).label('count'),
            func.avg(ConditionDimensionScore.score).label('avg_score')
        )
        .join(Dimension, ConditionDimensionScore.dimension_id == Dimension.id)
        .group_by(Dimension.name)
    )
    
    dimension_stats = [
        {
            "dimension": row[0],
            "condition_count": row[1],
            "average_score": round(row[2], 4) if row[2] else 0
        }
        for row in count_result
    ]
    
    # Category distribution
    category_result = await db.execute(
        select(
            DimensionCategory.name,
            Dimension.name.label('dimension'),
            func.count(DimensionCategory.id).label('count')
        )
        .join(Dimension, DimensionCategory.dimension_id == Dimension.id)
        .group_by(DimensionCategory.name, Dimension.name)
        .order_by(func.count(DimensionCategory.id).desc())
        .limit(20)
    )
    
    top_categories = [
        {
            "category": row[0],
            "dimension": row[1],
            "count": row[2]
        }
        for row in category_result
    ]
    
    return {
        "dimensions": dimension_stats,
        "top_categories": top_categories
    }


# ============================================================================
# HEALTH CHECK
# ============================================================================

@router.get("/health")
async def taxonomy_health_check():
    """Health check for taxonomy API"""
    return {
        "status": "healthy",
        "service": "dimensional-taxonomy",
        "version": "1.0.0"
    }
