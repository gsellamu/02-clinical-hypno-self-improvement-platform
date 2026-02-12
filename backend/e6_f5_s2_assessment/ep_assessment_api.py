"""
E&P Assessment REST API
FastAPI endpoints for E&P assessment system
"""
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Dict, List
from fastapi.middleware.cors import CORSMiddleware

from ep_assessment_questions import EPAssessmentQuestions
from ep_scoring_engine import EPScoringEngine
from ep_profile_generator import EPProfileGenerator
import uvicorn

 #Define the list of allowed origins right here:
ALLOWED_ORIGINS = [
    "http://localhost:3030",  # <--- Add your frontend URL here
    "http://localhost:3000",
    "http://127.0.0.1:3030"
]
app = FastAPI(title="E&P Assessment API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,  # Use the local variable
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize components
questions_db = EPAssessmentQuestions()
scoring_engine = EPScoringEngine()
profile_generator = EPProfileGenerator()

class AssessmentResponse(BaseModel):
    responses: Dict[int, str]

@app.get("/")
def root():
    return {"message": "E&P Assessment API", "version": "1.0.0"}

@app.get("/questions")
def get_all_questions():
    """Get all 45 assessment questions"""
    questions = questions_db.get_all_questions()
    return {
        "total": len(questions),
        "questions": [
            {
                "id": q.id,
                "text": q.question_text,
                "trait": q.trait_assessed,
                "physical_response": q.physical_response,
                "emotional_response": q.emotional_response
            }
            for q in questions
        ]
    }

@app.get("/questions/trait/{trait_name}")
def get_questions_by_trait(trait_name: str):
    """Get questions for specific trait"""
    questions = questions_db.get_questions_by_trait(trait_name)
    if not questions:
        raise HTTPException(status_code=404, detail=f"Trait '{trait_name}' not found")
    return {"trait": trait_name, "count": len(questions), "questions": questions}

@app.post("/assess")
def assess_responses(assessment: AssessmentResponse):
    """Score assessment responses and return EP profile"""
    profile = scoring_engine.score_responses(assessment.responses)
    detailed_profile = profile_generator.get_profile(profile.ep_type)
    recommendations = profile_generator.generate_therapeutic_recommendations(profile.ep_type)
    
    return {
        "ep_type": profile.ep_type,
        "primary_type": profile.primary_type,
        "secondary_type": profile.secondary_type,
        "scores": {
            "physical_percentage": profile.overall_physical_percentage,
            "emotional_percentage": profile.overall_emotional_percentage,
            "confidence": profile.confidence_score
        },
        "trait_breakdown": {
            trait: {
                "dominant": score.dominant_type,
                "physical_pct": score.physical_percentage,
                "emotional_pct": score.emotional_percentage
            }
            for trait, score in profile.trait_scores.items()
        },
        "profile": {
            "title": detailed_profile.title,
            "description": detailed_profile.description,
            "strengths": detailed_profile.strengths,
            "challenges": detailed_profile.challenges,
            "communication_style": detailed_profile.communication_style
        },
        "therapeutic_recommendations": recommendations
    }

@app.get("/profile/{ep_type}")
def get_profile(ep_type: str):
    """Get detailed profile for EP type"""
    profile = profile_generator.get_profile(ep_type)
    return {
        "ep_type": profile.ep_type,
        "title": profile.title,
        "description": profile.description,
        "strengths": profile.strengths,
        "challenges": profile.challenges,
        "growth_opportunities": profile.growth_opportunities
    }

if __name__ == '__main__':
    uvicorn.run(app, host="0.0.0.0", port=8021)
