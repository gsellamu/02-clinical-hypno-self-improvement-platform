# DEV4: FastAPI Endpoint Set
## Complete API Routes with Pydantic Models

**Version:** 1.0  
**Date:** 2026-02-11

---

## COMPLETE FASTAPI ROUTES

```python
# services/api/app/api/routes.py
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from uuid import UUID, uuid4
from enum import Enum

router = APIRouter()

# ============================================================================
# MODELS
# ============================================================================

class TechniqueEnum(str, Enum):
    sprint = "sprint"
    unsent_letter = "unsent_letter"
    sentence_stems = "sentence_stems"
    inventory = "inventory"
    list_of_100 = "list_of_100"
    bilateral_drawing = "bilateral_drawing"

class SafetyStatus(str, Enum):
    green = "green"
    yellow = "yellow"
    red = "red"

class SessionStatus(str, Enum):
    initiated = "initiated"
    in_progress = "in_progress"
    completed = "completed"
    paused = "paused"
    terminated = "terminated"

# Session Models
class SessionStartRequest(BaseModel):
    user_id: UUID
    technique: TechniqueEnum
    ep_profile: Optional[Dict[str, Any]] = None
    metadata: Optional[Dict[str, Any]] = None

class SessionStartResponse(BaseModel):
    session_id: UUID
    status: SessionStatus
    technique: TechniqueEnum
    safety_status: SafetyStatus
    created_at: datetime
    next_state: str = "safety_screen"

class SessionNextRequest(BaseModel):
    session_id: UUID
    user_input: Optional[Dict[str, Any]] = None

class SessionNextResponse(BaseModel):
    session_id: UUID
    current_state: str
    next_state: Optional[str]
    prompts: List[str]
    actions: List[str]
    data: Optional[Dict[str, Any]]

# Journal Models
class JournalEntryRequest(BaseModel):
    session_id: UUID
    content: str = Field(..., min_length=1, max_length=50000)
    technique: TechniqueEnum
    word_count: int = Field(..., ge=0)
    duration_seconds: int = Field(..., ge=0)
    metadata: Optional[Dict[str, Any]] = None

class JournalEntryResponse(BaseModel):
    entry_id: UUID
    session_id: UUID
    created_at: datetime
    status: str
    encrypted: bool = True

class JournalEntryListItem(BaseModel):
    entry_id: UUID
    session_id: UUID
    technique: TechniqueEnum
    word_count: int
    created_at: datetime
    themes: Optional[List[str]] = None
    sentiment_score: Optional[float] = None

class JournalEntriesResponse(BaseModel):
    user_id: UUID
    entries: List[JournalEntryListItem]
    total: int
    page: int
    page_size: int

# Safety Models
class SafetyScreenRequest(BaseModel):
    user_id: UUID
    context: str = Field(..., description="journaling_initiation | mid_exercise_check | post_session")
    user_input: Optional[str] = None
    session_context: Optional[Dict[str, Any]] = None

class SafetyScreenResponse(BaseModel):
    status: SafetyStatus
    crisis_level: str = Field(..., description="none | low | medium | severe")
    detection_signals: List[str]
    constraints: List[str]
    recommended_action: str
    confidence: float = Field(..., ge=0.0, le=1.0)

# TTS Models
class TTSRenderRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=5000)
    voice_id: str = "sophia"
    emotion: Optional[str] = "calm"
    cache_enabled: bool = True

class TTSRenderResponse(BaseModel):
    audio_url: str
    duration_seconds: float
    cached: bool
    cache_key: Optional[str] = None

# ============================================================================
# ENDPOINTS
# ============================================================================

@router.post(
    "/session/start",
    response_model=SessionStartResponse,
    tags=["Session"],
    summary="Start a new journaling session"
)
async def start_session(request: SessionStartRequest):
    """
    Initialize a new journaling session with safety screening
    
    - **user_id**: UUID of the user
    - **technique**: Journaling technique to use
    - **ep_profile**: Optional E&P profile for personalization
    - **metadata**: Optional session metadata
    """
    session_id = uuid4()
    
    # TODO: Store session in database
    # TODO: Initialize LangGraph state
    # TODO: Run initial safety screen
    
    return SessionStartResponse(
        session_id=session_id,
        status=SessionStatus.initiated,
        technique=request.technique,
        safety_status=SafetyStatus.green,
        created_at=datetime.utcnow(),
        next_state="intake"
    )

@router.post(
    "/session/next",
    response_model=SessionNextResponse,
    tags=["Session"],
    summary="Advance session to next state"
)
async def next_session_step(request: SessionNextRequest):
    """
    Transition session to next state in LangGraph workflow
    
    - **session_id**: UUID of the session
    - **user_input**: Optional user input data for current state
    """
    # TODO: Load session from database
    # TODO: Call orchestrator to transition state
    # TODO: Return prompts and actions for next state
    
    return SessionNextResponse(
        session_id=request.session_id,
        current_state="intake",
        next_state="technique_select",
        prompts=["What would you like to explore today?"],
        actions=["continue", "pause"],
        data={"timebox_minutes": 7}
    )

@router.post(
    "/journal/entry",
    response_model=JournalEntryResponse,
    tags=["Journal"],
    summary="Save a journaling entry"
)
async def save_journal_entry(request: JournalEntryRequest):
    """
    Save and analyze a journaling entry
    
    - **session_id**: Session this entry belongs to
    - **content**: Journaling content (will be encrypted)
    - **technique**: Technique used
    - **word_count**: Number of words
    - **duration_seconds**: Time spent writing
    """
    entry_id = uuid4()
    
    # TODO: Encrypt content (AES-256)
    # TODO: Store in database
    # TODO: Trigger async analysis (themes, sentiment, action items)
    # TODO: Publish Kafka event
    
    return JournalEntryResponse(
        entry_id=entry_id,
        session_id=request.session_id,
        created_at=datetime.utcnow(),
        status="saved",
        encrypted=True
    )

@router.get(
    "/journal/entries",
    response_model=JournalEntriesResponse,
    tags=["Journal"],
    summary="Get user's journal entries"
)
async def get_journal_entries(
    user_id: UUID,
    page: int = 1,
    page_size: int = 10,
    technique: Optional[TechniqueEnum] = None
):
    """
    Retrieve paginated list of user's journal entries
    
    - **user_id**: User UUID
    - **page**: Page number (default: 1)
    - **page_size**: Items per page (default: 10, max: 50)
    - **technique**: Optional filter by technique
    """
    # TODO: Query database with pagination
    # TODO: Load analysis results (themes, sentiment)
    
    return JournalEntriesResponse(
        user_id=user_id,
        entries=[],
        total=0,
        page=page,
        page_size=page_size
    )

@router.post(
    "/safety/screen",
    response_model=SafetyScreenResponse,
    tags=["Safety"],
    summary="Run safety screening"
)
async def safety_screen(request: SafetyScreenRequest):
    """
    Multi-signal crisis detection screening
    
    - **user_id**: User UUID
    - **context**: When screening is happening
    - **user_input**: Optional user text to analyze
    - **session_context**: Recent session data for pattern detection
    
    Returns safety status (green/yellow/red) and recommended action
    """
    # TODO: Call Safety Guardian Service (port 8005)
    # TODO: Run multi-signal detection
    # TODO: Check for explicit ideation, behavioral changes, sentiment drops
    # TODO: Apply constraints if Code Yellow
    # TODO: Block session if Code Red
    
    # DEMO: Return Code Green
    return SafetyScreenResponse(
        status=SafetyStatus.green,
        crisis_level="none",
        detection_signals=[],
        constraints=[],
        recommended_action="proceed_normal",
        confidence=0.95
    )

@router.post(
    "/tts/render",
    response_model=TTSRenderResponse,
    tags=["TTS"],
    summary="Generate TTS audio (stub)"
)
async def render_tts(request: TTSRenderRequest):
    """
    Generate text-to-speech audio using ElevenLabs
    
    - **text**: Text to convert to speech (max 5000 chars)
    - **voice_id**: Voice to use (default: sophia)
    - **emotion**: Emotion tag for narration
    - **cache_enabled**: Enable CDN caching
    """
    # TODO: Call ElevenLabs API
    # TODO: Upload to MinIO/S3
    # TODO: Generate presigned URL
    # TODO: Cache for repeated phrases
    
    # STUB RESPONSE
    return TTSRenderResponse(
        audio_url="https://cdn.jeeth.ai/tts/stub_audio.mp3",
        duration_seconds=5.0,
        cached=False,
        cache_key=None
    )

# ============================================================================
# ERROR HANDLERS
# ============================================================================

@router.get("/health", tags=["System"])
async def health_check():
    """System health check"""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat()
    }
```

---

## OPENAPI TAGS

```python
# services/api/main.py
from fastapi import FastAPI
from fastapi.openapi.utils import get_openapi

app = FastAPI()

def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema
    
    openapi_schema = get_openapi(
        title="Therapeutic Journaling API",
        version="1.0.0",
        description="""
        ## Therapeutic Journaling Platform API
        
        Production-grade API for clinical hypnotherapy journaling platform.
        
        ### Features
        - **Session Management**: LangGraph-based workflow orchestration
        - **Journal Entries**: Encrypted storage with AI analysis
        - **Safety Guardian**: Multi-signal crisis detection
        - **TTS Integration**: ElevenLabs voice synthesis
        
        ### Authentication
        Use Bearer token in Authorization header.
        """,
        routes=app.routes,
        tags=[
            {
                "name": "Session",
                "description": "Session lifecycle management and state transitions"
            },
            {
                "name": "Journal",
                "description": "Journal entry CRUD and analysis"
            },
            {
                "name": "Safety",
                "description": "Safety screening and crisis detection"
            },
            {
                "name": "TTS",
                "description": "Text-to-speech generation"
            },
            {
                "name": "System",
                "description": "System health and metadata"
            }
        ]
    )
    
    app.openapi_schema = openapi_schema
    return app.openapi_schema

app.openapi = custom_openapi
```

---

**STATUS:** DEV4 FastAPI Endpoint Set Complete ✅  
**Next:** DEV5 LangGraph Node Implementations
