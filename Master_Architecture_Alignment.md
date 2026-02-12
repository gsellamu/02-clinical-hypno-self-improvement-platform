# Jeeth.ai Master Enterprise Architecture
## E&P Assessment System - Coherent Plug-in Integration

**Date:** November 21, 2025  
**Status:** Production Architecture v5.0  
**Project:** Clinical Hypnotherapy & Self-Improvement Platform

---

## 🎯 EXECUTIVE SUMMARY

Your E&P Assessment system needs to integrate into a **sophisticated, enterprise-grade GenAI platform** that includes:

- ✅ Multi-agent orchestration (AutoGen, CrewAI, LangGraph)
- ✅ Knowledge Graph RAG (Neo4j + Vector Stores)
- ✅ MCP Protocol servers (6 specialized servers)
- ✅ Custom LLM fine-tuning pipeline
- ✅ FHIR healthcare integration
- ✅ Real-time biometric IoT streaming
- ✅ Advanced XR (Unity/Unreal/Omniverse)
- ✅ Production monitoring & logging

**E&P Assessment** is the **foundational personalization layer** that determines HOW all AI agents communicate with users.

---

## 🏗️ MASTER ARCHITECTURE OVERVIEW

### System Layers

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                               │
├─────────────────────────────────────────────────────────────────────┤
│ • React WebXR (Quest 3)                                             │
│ • Unity/Unreal VR                                                   │
│ • Web Dashboard (React + TypeScript)                                │
│ • Mobile Apps (React Native)                                        │
└────────────────────────┬────────────────────────────────────────────┘
                         │
                         │ REST API + WebSocket
                         ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    API GATEWAY LAYER                                │
├─────────────────────────────────────────────────────────────────────┤
│ FastAPI Backend (Python 3.11+)                                      │
│ • Authentication & Authorization (JWT)                              │
│ • Rate Limiting                                                     │
│ • Request Validation (Pydantic)                                     │
│ • Error Handling & Logging                                          │
└────────────────────────┬────────────────────────────────────────────┘
                         │
          ┌──────────────┼──────────────┐
          │              │              │
          ▼              ▼              ▼
┌──────────────┐  ┌──────────┐  ┌──────────────┐
│ Assessment   │  │ Session  │  │ Analytics    │
│ Service      │  │ Service  │  │ Service      │
└──────────────┘  └──────────┘  └──────────────┘
          │              │              │
          ▼              ▼              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    AI ORCHESTRATION LAYER                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │  MULTI-AGENT SYSTEM (AutoGen + CrewAI + LangGraph)         │  │
│  ├─────────────────────────────────────────────────────────────┤  │
│  │                                                             │  │
│  │  Agent 1: Shadow Recognition Agent                         │  │
│  │  Agent 2: Clinical Safety Agent                            │  │
│  │  Agent 3: Script Generation Agent                          │  │
│  │  Agent 4: Suggestibility Adapter Agent ⭐ USES E&P         │  │
│  │  Agent 5: Parts Integration Agent                          │  │
│  │  Agent 6: RAG Query Agent                                  │  │
│  │  Agent 7: Session Orchestrator                             │  │
│  │                                                             │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │  MCP PROTOCOL SERVERS (6 Specialized Servers)              │  │
│  ├─────────────────────────────────────────────────────────────┤  │
│  │  1. RAG Knowledge Server     4. IoT Biometric Server       │  │
│  │  2. FHIR Healthcare Server   5. TTS Voice Server           │  │
│  │  3. Neo4j Graph Server       6. Custom LLM Server          │  │
│  └─────────────────────────────────────────────────────────────┘  │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    DATA LAYER                                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  PostgreSQL (Core Data)      Neo4j (Knowledge Graph)               │
│  • Users & Profiles          • HMI Protocols                       │
│  • Assessments ⭐            • Therapeutic Pathways                 │
│  • Sessions                  • Contraindications                   │
│  • Audit Logs                • Clinical Decision Support           │
│                                                                     │
│  Redis (Cache & Sessions)    Vector Store (Embeddings)             │
│  • Active Sessions           • 7 Specialized Collections           │
│  • Task Queue                • HMI Knowledge Base                  │
│  • Real-time State           • Clinical Protocols                  │
│                                                                     │
│  TimescaleDB (Time Series)   InfluxDB (IoT Metrics)               │
│  • Biometric History         • Real-time Sensors                   │
│  • Session Analytics         • Heart Rate, HRV, GSR               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📊 E&P ASSESSMENT INTEGRATION POINTS

### 1. **Database Schema Alignment**

Your E&P Assessment integrates into the existing user profile:

```sql
-- EXISTING USER TABLE (Already in Production)
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    
    -- E&P Assessment Results ⭐ YOUR INTEGRATION POINT
    has_completed_ep BOOLEAN DEFAULT FALSE,
    ep_results JSONB,  -- Stores complete assessment
    
    -- Other fields...
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- NEW: QUESTIONNAIRE VERSIONS TABLE ⭐ YOUR ADDITION
CREATE TABLE questionnaire_versions (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    version VARCHAR(50) NOT NULL,
    methodology VARCHAR(255) NOT NULL,
    scoring_algorithm JSONB NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- NEW: QUESTIONNAIRE QUESTIONS TABLE ⭐ YOUR ADDITION
CREATE TABLE questionnaire_questions (
    id UUID PRIMARY KEY,
    questionnaire_version_id UUID REFERENCES questionnaire_versions(id),
    question_number INTEGER NOT NULL,
    question_text TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,  -- 'physical' or 'emotional'
    subcategory VARCHAR(100),
    weight INTEGER NOT NULL,  -- 5 or 10
    
    -- For AI/ML/LLM Integration
    embedding VECTOR(1536),  -- OpenAI embeddings
    semantic_tags TEXT[],
    psychological_construct VARCHAR(255),
    clinical_significance TEXT,
    
    created_at TIMESTAMP DEFAULT NOW()
);

-- NEW: USER ASSESSMENTS TABLE ⭐ YOUR ADDITION
CREATE TABLE user_assessments (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    session_id UUID,  -- Optional VR session reference
    questionnaire_version_id UUID REFERENCES questionnaire_versions(id),
    
    -- Results
    profile VARCHAR(100) NOT NULL,  -- 'Physical Suggestible', etc.
    q1_score INTEGER NOT NULL,
    q2_score INTEGER NOT NULL,
    combined_score INTEGER NOT NULL,
    physical_percentage INTEGER NOT NULL,
    emotional_percentage INTEGER NOT NULL,
    suggestibility_type VARCHAR(100) NOT NULL,
    
    -- Raw Data
    answers JSONB NOT NULL,  -- All 36 answers
    
    -- Quality Metrics ⭐ YOUR ENHANCED FEATURES
    confidence_score FLOAT,  -- 0-100 quality score
    answer_pattern_signature VARCHAR(50),  -- 'balanced', 'all_yes', etc.
    completion_percentage FLOAT,
    time_to_complete_seconds INTEGER,
    
    -- Clinical Review
    clinical_notes TEXT,
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMP,
    
    -- Audit Trail
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);
```

### 2. **Service Layer Integration**

```python
# backend/services/assessment/ep_assessment_service_enhanced.py

class EPAssessmentServiceEnhanced:
    """
    Enhanced E&P Assessment Service
    
    Integrates with:
    - User profiles (updates user.ep_results)
    - Multi-agent system (provides suggestibility data)
    - Session orchestrator (determines communication style)
    - Clinical safety (validates assessment quality)
    """
    
    def __init__(self, db: Session):
        self.db = db
    
    def save_assessment(
        self,
        user_id: str,
        answers: Dict[str, bool],
        session_id: Optional[str] = None,
        time_to_complete: Optional[int] = None
    ) -> AssessmentResult:
        """
        Save assessment with quality metrics
        
        Integration Points:
        1. Updates user.ep_results
        2. Notifies multi-agent system
        3. Triggers communication style update
        4. Creates embedding for RAG
        """
        # Calculate scores
        scores = self.calculate_scores(answers)
        
        # Calculate quality metrics
        quality = self.calculate_quality_metrics(answers, time_to_complete)
        
        # Save to database
        assessment = UserAssessment(...)
        self.db.add(assessment)
        
        # Update user profile
        user = self.db.query(User).filter(User.id == user_id).first()
        user.has_completed_ep = True
        user.ep_results = {
            "profile": scores.suggestibility_type,
            "physical_pct": scores.physical_percentage,
            "emotional_pct": scores.emotional_percentage,
            "completed_at": datetime.now().isoformat()
        }
        
        self.db.commit()
        
        # ⭐ NOTIFY MULTI-AGENT SYSTEM
        await self._notify_agents(user_id, scores.suggestibility_type)
        
        return AssessmentResult(...)
    
    async def _notify_agents(self, user_id: str, profile: str):
        """Notify all AI agents about user's communication preferences"""
        from agents.suggestibility_adapter import update_user_profile
        await update_user_profile(user_id, profile)
```

### 3. **API Routes Integration**

```python
# backend/routes/assessment.py

router = APIRouter(prefix="/api/v1/assessment", tags=["Assessment"])

@router.post("/ep/submit")
async def submit_ep_assessment(
    request: SubmitAssessmentRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Submit E&P Suggestibility Assessment
    
    Used by:
    - Onboarding flow
    - Reassessment after 6 months
    - Clinical review process
    """
    service = EPAssessmentServiceEnhanced(db)
    
    result = service.save_assessment(
        user_id=current_user.id,
        answers=request.answers,
        time_to_complete=request.time_to_complete
    )
    
    return result

@router.get("/ep/results/latest")
async def get_latest_assessment(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's most recent E&P assessment"""
    service = EPAssessmentServiceEnhanced(db)
    return service.get_latest_assessment(current_user.id)

@router.get("/ep/communication-preferences")
async def get_communication_preferences(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get AI communication preferences based on E&P profile
    
    ⭐ THIS IS USED BY ALL AI AGENTS
    
    Returns:
    {
        "style": "physical_suggestible",
        "tone": "direct and clear",
        "use_metaphors": false,
        "use_literal": true,
        "confidence": 85.0
    }
    """
    service = EPAssessmentServiceEnhanced(db)
    return service.get_communication_preferences(current_user.id)
```

### 4. **Multi-Agent Integration**

The E&P Assessment directly influences **ALL AI agents**:

```python
# agents/suggestibility_adapter_agent.py

class SuggestibilityAdapterAgent:
    """
    Agent #4: Adapts all AI communication based on E&P profile
    
    Input: Generic therapeutic script
    Output: Personalized script matching user's suggestibility
    
    ⭐ USES E&P ASSESSMENT RESULTS
    """
    
    def __init__(self, llm_config: Dict):
        self.llm_config = llm_config
    
    async def adapt_script(
        self,
        script: str,
        user_id: str
    ) -> str:
        """
        Adapt script based on E&P profile
        
        Physical Suggestible → Direct, literal language
        Emotional Suggestible → Metaphorical, inferential language
        Balanced → Mix of both styles
        """
        # Get E&P profile from assessment service
        prefs = await self._get_user_preferences(user_id)
        
        if prefs["style"] == "physical_suggestible":
            return await self._adapt_for_physical(script)
        elif prefs["style"] == "emotional_suggestible":
            return await self._adapt_for_emotional(script)
        else:
            return await self._adapt_for_balanced(script)
    
    async def _get_user_preferences(self, user_id: str) -> Dict:
        """Fetch E&P communication preferences"""
        # ⭐ CALLS YOUR API
        response = await httpx.get(
            f"/api/v1/assessment/ep/communication-preferences",
            headers={"Authorization": f"Bearer {token}"}
        )
        return response.json()
    
    async def _adapt_for_physical(self, script: str) -> str:
        """
        Adapt for Physical Suggestible
        
        Changes:
        - "You might feel..." → "You feel..."
        - Remove metaphors
        - Add direct commands
        - Use present tense
        """
        prompt = f"""
        Adapt this hypnotherapy script for a PHYSICAL SUGGESTIBLE person.
        
        Guidelines:
        - Use direct, literal language
        - Present tense commands ("You feel calm")
        - No metaphors or analogies
        - Step-by-step instructions
        - Physical sensations emphasized
        
        Original script:
        {script}
        
        Adapted script:
        """
        
        response = await self.llm.generate(prompt)
        return response.text
    
    async def _adapt_for_emotional(self, script: str) -> str:
        """
        Adapt for Emotional Suggestible
        
        Changes:
        - "You feel..." → "You might notice..."
        - Add metaphors
        - Use inferential language
        - More exploratory tone
        """
        prompt = f"""
        Adapt this hypnotherapy script for an EMOTIONAL SUGGESTIBLE person.
        
        Guidelines:
        - Use inferential, metaphorical language
        - "You might notice..." "Perhaps..." "Imagine..."
        - Rich metaphors and analogies
        - Exploratory, discovery-oriented
        - Emotional resonance emphasized
        
        Original script:
        {script}
        
        Adapted script:
        """
        
        response = await self.llm.generate(prompt)
        return response.text
```

### 5. **CrewAI Orchestration Integration**

```python
# agents/crews/session_generation_crew.py

from crewai import Agent, Task, Crew

class SessionGenerationCrew:
    """
    Multi-agent crew for generating complete hypnotherapy sessions
    
    Workflow:
    1. RAG Agent → Retrieves relevant protocols
    2. Script Agent → Generates base script
    3. Safety Agent → Validates clinical safety
    4. Suggestibility Agent → Adapts language ⭐ USES E&P
    5. Review Agent → Final quality check
    """
    
    def __init__(self):
        self.rag_agent = Agent(...)
        self.script_agent = Agent(...)
        self.safety_agent = Agent(...)
        
        # ⭐ SUGGESTIBILITY ADAPTER USES E&P ASSESSMENT
        self.suggestibility_agent = Agent(
            role="Suggestibility Communication Specialist",
            goal="Adapt therapeutic language to match user's E&P profile",
            backstory="""You are an expert in HMI suggestibility theory.
            You understand Physical vs Emotional suggestibility and adapt
            all therapeutic communications accordingly.""",
            tools=[get_ep_preferences, adapt_language],
            llm=llm_config
        )
        
        self.review_agent = Agent(...)
    
    def generate_session(self, user_id: str, intent: str) -> Dict:
        """Generate complete personalized session"""
        
        # Task 4: Adapt for suggestibility ⭐ USES E&P
        adapt_task = Task(
            description=f"""
            Adapt the therapeutic script for user {user_id}.
            
            Steps:
            1. Retrieve E&P assessment results
            2. Determine Physical vs Emotional suggestibility
            3. Adapt language patterns accordingly
            4. Ensure consistency throughout script
            
            Physical Suggestible → Direct, literal
            Emotional Suggestible → Metaphorical, inferential
            """,
            agent=self.suggestibility_agent,
            expected_output="Personalized script matching E&P profile"
        )
        
        # Create crew
        crew = Crew(
            agents=[
                self.rag_agent,
                self.script_agent,
                self.safety_agent,
                self.suggestibility_agent,  # ⭐ USES E&P
                self.review_agent
            ],
            tasks=[...],
            process="sequential"
        )
        
        result = crew.kickoff()
        return result
```

---

## 🔗 INTEGRATION DEPENDENCIES

### Your E&P Assessment Service Depends On:

1. ✅ **Database** (PostgreSQL)
   - User table
   - Assessment tables
   - Questionnaire versioning

2. ✅ **Authentication** (JWT)
   - User identification
   - Role-based access

3. ✅ **Vector Store** (Optional)
   - Question embeddings
   - Semantic search

### Services That Depend On E&P Assessment:

1. ⭐ **All AI Agents** (AutoGen/CrewAI)
   - Communication style
   - Language patterns
   - Tone adaptation

2. ⭐ **Session Orchestrator**
   - Script generation
   - Real-time adaptation
   - Biometric response interpretation

3. ⭐ **Clinical Safety Agent**
   - Risk assessment
   - Contraindication checking
   - Titration recommendations

4. ⭐ **Analytics Service**
   - Outcome prediction
   - Treatment optimization
   - Quality monitoring

---

## 📁 RECOMMENDED FILE STRUCTURE

```
backend/
├── models/
│   └── questionnaire_models.py ✅ YOUR MODELS (Already created)
│
├── services/
│   ├── assessment/
│   │   ├── __init__.py
│   │   ├── ep_assessment_service.py          # Basic service
│   │   └── ep_assessment_service_enhanced.py ✅ WITH QUALITY METRICS
│   │
│   ├── agents/  ⭐ USES YOUR ASSESSMENT
│   │   ├── suggestibility_adapter_agent.py
│   │   ├── script_generation_agent.py
│   │   └── session_orchestrator.py
│   │
│   └── crews/  ⭐ USES YOUR ASSESSMENT
│       └── session_generation_crew.py
│
├── routes/
│   ├── assessment.py ✅ YOUR ROUTES (Need to create)
│   ├── session.py     # Uses E&P for personalization
│   └── analytics.py   # Tracks E&P correlation with outcomes
│
├── schemas/
│   └── assessment.py ✅ YOUR SCHEMAS (Need to create)
│
└── utils/
    └── scoring_calculator.py ✅ YOUR CALCULATOR (Already exists)
```

---

## 🎯 RECOMMENDED NEXT STEPS

### Phase 1: Complete E&P Assessment Core (2-3 hours)

1. ✅ **Create API Routes** (`routes/assessment.py`)
   ```python
   POST /api/v1/assessment/ep/submit
   GET  /api/v1/assessment/ep/results/latest
   GET  /api/v1/assessment/ep/communication-preferences ⭐ KEY!
   GET  /api/v1/assessment/ep/history
   ```

2. ✅ **Create Request/Response Schemas** (`schemas/assessment.py`)
   ```python
   class SubmitAssessmentRequest(BaseModel): ...
   class AssessmentResult(BaseModel): ...
   class QualityMetrics(BaseModel): ...
   ```

3. ✅ **Add Authentication Integration**
   ```python
   from auth import get_current_user, require_role
   ```

4. ✅ **Create Integration Tests**
   ```python
   test_submit_assessment()
   test_get_preferences()
   test_quality_scoring()
   ```

### Phase 2: Multi-Agent Integration (2-3 hours)

5. ⭐ **Create Suggestibility Adapter Agent**
   - Reads E&P preferences
   - Adapts language patterns
   - Integrates with CrewAI

6. ⭐ **Update Session Orchestrator**
   - Calls E&P preferences API
   - Passes to all agents
   - Tracks correlation with outcomes

7. ⭐ **Update Script Generation**
   - Uses E&P in prompt engineering
   - Validates adaptation quality
   - A/B testing Physical vs Emotional approaches

### Phase 3: Clinical Workflow (1-2 hours)

8. ✅ **Add Clinical Review Endpoints**
   ```python
   POST /api/v1/assessment/ep/{id}/flag
   POST /api/v1/assessment/ep/{id}/review
   GET  /api/v1/assessment/ep/pending-reviews
   ```

9. ✅ **Add Analytics Endpoints**
   ```python
   GET /api/v1/assessment/analytics/quality
   GET /api/v1/assessment/analytics/outcomes-by-profile
   ```

---

## 🎨 ARCHITECTURAL PRINCIPLES

### 1. **Separation of Concerns**
- ✅ Models = Data structure
- ✅ Services = Business logic
- ✅ Routes = API endpoints
- ✅ Schemas = Validation

### 2. **Single Source of Truth**
- ✅ E&P results stored ONCE in `user_assessments`
- ✅ All services read from same source
- ✅ No duplication

### 3. **Event-Driven Updates**
```python
# When E&P assessment completes:
async def on_assessment_complete(user_id: str, profile: str):
    # 1. Update user profile
    await update_user_profile(user_id, profile)
    
    # 2. Notify multi-agent system
    await notify_agents(user_id, profile)
    
    # 3. Trigger cache refresh
    await redis.delete(f"user:{user_id}:preferences")
    
    # 4. Log for analytics
    await analytics.track("assessment_completed", {
        "user_id": user_id,
        "profile": profile
    })
```

### 4. **Versioning Strategy**
- ✅ Questionnaires are versioned
- ✅ Users linked to specific version
- ✅ Historical comparisons possible
- ✅ A/B testing supported

### 5. **Quality Assurance**
- ✅ Confidence scoring (0-100)
- ✅ Pattern detection (fraud prevention)
- ✅ Clinical review workflow
- ✅ Audit trail

---

## 💡 KEY INSIGHTS

### 1. **E&P is the Foundation**
Your E&P Assessment isn't just another feature - it's the **foundation of personalization** for the entire platform. Every AI interaction depends on it.

### 2. **Quality Matters**
Adding quality metrics (confidence scores, pattern detection) is **critical** because:
- Prevents AI from adapting to invalid assessments
- Enables clinical oversight
- Supports continuous improvement

### 3. **Versioning is Essential**
Questions will evolve. Having versions means:
- You can improve without breaking old data
- A/B testing new questions
- Regulatory compliance (know what was asked when)

### 4. **Agent Integration is Key**
The E&P Assessment powers:
- Language adaptation (Physical vs Emotional)
- Script personalization
- Biometric interpretation
- Treatment optimization

---

## 🚀 READY TO PROCEED?

Would you like me to generate:

1. **Complete API Routes** (`routes/assessment.py`) with all CRUD operations?
2. **Pydantic Schemas** (`schemas/assessment.py`) for validation?
3. **Integration Tests** to verify everything works together?
4. **Suggestibility Adapter Agent** that actually uses E&P data?
5. **Master PowerShell Script** that sets up everything?

Just say which you want, and I'll create production-ready code that integrates perfectly with your master architecture! 🎯
