"""
MEDIUM-1: SESSION CREATION API
Complete backend service for creating and managing hypnotherapy sessions

Port: 8012
Location: 02-clinical.../backend/services/session-service/session_api.py
"""

from fastapi import FastAPI, HTTPException, BackgroundTasks, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Dict, Optional, Any
from datetime import datetime, timedelta
from uuid import uuid4
import json

app = FastAPI(
    title="Session Management API",
    version="1.0.0",
    description="Create and manage hypnotherapy sessions"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =============================================================================
# PYDANTIC MODELS
# =============================================================================

class SessionCreateRequest(BaseModel):
    """Request to create a new session"""
    user_id: str
    plan_id: str
    protocol_id: str
    scheduled_for: Optional[datetime] = None
    duration_minutes: int = 60
    session_type: str = "regular"  # regular, emergency, follow-up
    notes: Optional[str] = None


class SessionConfig(BaseModel):
    """Session configuration"""
    environment: str = "therapist_office"  # therapist_office, temple, beach, forest
    avatar: str = "sophia"  # sophia, male_therapist, etc.
    voice: str = "calm_female"
    music_volume: float = 0.3
    ambient_sounds: bool = True
    biometric_monitoring: bool = True
    safety_monitoring: bool = True


class SessionPhase(BaseModel):
    """Individual phase of a session"""
    phase_id: str
    name: str
    duration_minutes: int
    script: str
    techniques: List[str]
    expected_outcomes: List[str]


class TherapySession(BaseModel):
    """Complete therapy session"""
    session_id: str
    user_id: str
    plan_id: str
    protocol_id: str
    
    created_at: datetime
    scheduled_for: Optional[datetime]
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    
    status: str = "scheduled"  # scheduled, in_progress, completed, cancelled
    
    config: SessionConfig
    phases: List[SessionPhase]
    
    duration_minutes: int
    actual_duration: Optional[int] = None
    
    ep_adaptations: Dict[str, Any]
    
    biometric_data: Optional[Dict] = None
    safety_checks: List[Dict] = []
    
    notes: Optional[str] = None
    therapist_notes: Optional[str] = None


# =============================================================================
# SESSION CREATION LOGIC
# =============================================================================

class SessionCreator:
    """Creates therapy sessions from plans and protocols"""
    
    async def create_session(
        self,
        request: SessionCreateRequest,
        background_tasks: BackgroundTasks
    ) -> TherapySession:
        """Create a complete therapy session"""
        
        print(f"🎯 Creating session for user {request.user_id}")
        
        # Step 1: Get user's 5D plan
        plan = await self._get_plan(request.plan_id)
        
        # Step 2: Get protocol details
        protocol = await self._get_protocol(request.protocol_id)
        
        # Step 3: Get E&P type for adaptations
        ep_type = await self._get_ep_type(request.user_id)
        
        # Step 4: Generate session phases
        phases = await self._generate_phases(protocol, ep_type, plan)
        
        # Step 5: Create session configuration
        config = await self._create_config(request.user_id, protocol, ep_type)
        
        # Step 6: Build complete session
        session_id = str(uuid4())
        session = TherapySession(
            session_id=session_id,
            user_id=request.user_id,
            plan_id=request.plan_id,
            protocol_id=request.protocol_id,
            created_at=datetime.utcnow(),
            scheduled_for=request.scheduled_for or datetime.utcnow(),
            status="scheduled",
            config=config,
            phases=phases,
            duration_minutes=request.duration_minutes,
            ep_adaptations=self._get_ep_adaptations(ep_type),
            notes=request.notes
        )
        
        # Step 7: Save session
        background_tasks.add_task(self._save_session, session)
        
        # Step 8: Schedule notifications
        background_tasks.add_task(self._schedule_notifications, session)
        
        print(f"✅ Session created: {session_id}")
        
        return session
    
    async def _get_plan(self, plan_id: str) -> Dict:
        """Get user's therapeutic plan"""
        # Mock - replace with real API call to 5D Plan Service
        return {
            "plan_id": plan_id,
            "mind_dimension": {"baseline_score": 70},
            "body_dimension": {"baseline_score": 75},
            "primary_protocols": ["anxiety_reduction", "confidence_building"]
        }
    
    async def _get_protocol(self, protocol_id: str) -> Dict:
        """Get protocol details"""
        # Mock - replace with real API call to Epic 6
        return {
            "protocol_id": protocol_id,
            "name": "Anxiety Reduction Protocol",
            "session_count": 6,
            "duration": 60,
            "phases": ["induction", "deepening", "therapy", "emergence"],
            "techniques": ["progressive_relaxation", "visualization", "positive_suggestion"]
        }
    
    async def _get_ep_type(self, user_id: str) -> str:
        """Get user's E&P type"""
        # Mock - replace with real API call to E&P Service
        return "Physical"
    
    async def _generate_phases(self, protocol: Dict, ep_type: str, plan: Dict) -> List[SessionPhase]:
        """Generate session phases"""
        phases = []
        
        # Phase 1: Check-in & Preparation
        phases.append(SessionPhase(
            phase_id="phase-1",
            name="Check-in & Preparation",
            duration_minutes=10,
            script="Welcome back. How are you feeling today?",
            techniques=["rapport_building", "safety_check"],
            expected_outcomes=["Comfortable", "Ready for hypnosis"]
        ))
        
        # Phase 2: Induction
        induction_script = self._get_induction_script(ep_type)
        phases.append(SessionPhase(
            phase_id="phase-2",
            name="Induction",
            duration_minutes=10,
            script=induction_script,
            techniques=["progressive_relaxation", "eye_fixation"],
            expected_outcomes=["Relaxed", "In light trance"]
        ))
        
        # Phase 3: Deepening
        phases.append(SessionPhase(
            phase_id="phase-3",
            name="Deepening",
            duration_minutes=5,
            script="Going deeper... and deeper...",
            techniques=["counting_down", "staircase"],
            expected_outcomes=["Deep trance", "Highly suggestible"]
        ))
        
        # Phase 4: Therapeutic Work
        therapy_script = self._get_therapy_script(protocol, ep_type)
        phases.append(SessionPhase(
            phase_id="phase-4",
            name="Therapeutic Work",
            duration_minutes=25,
            script=therapy_script,
            techniques=protocol["techniques"],
            expected_outcomes=["Therapeutic change", "New perspectives"]
        ))
        
        # Phase 5: Emergence
        phases.append(SessionPhase(
            phase_id="phase-5",
            name="Emergence",
            duration_minutes=5,
            script="In a moment, I'll count from 1 to 5...",
            techniques=["counting_up", "reorientation"],
            expected_outcomes=["Alert", "Refreshed"]
        ))
        
        # Phase 6: Integration & Homework
        phases.append(SessionPhase(
            phase_id="phase-6",
            name="Integration & Homework",
            duration_minutes=5,
            script="Let's discuss what you experienced...",
            techniques=["discussion", "homework_assignment"],
            expected_outcomes=["Understanding", "Action plan"]
        ))
        
        return phases
    
    def _get_induction_script(self, ep_type: str) -> str:
        """Get appropriate induction script for E&P type"""
        if ep_type == "Physical":
            return """
            I want you to focus on your breathing.
            With each breath in, feel your body relaxing.
            With each breath out, let go of tension.
            Your eyelids are getting heavy. 
            You can close them now.
            """
        else:  # Emotional
            return """
            Imagine a peaceful place where you feel completely safe.
            Perhaps a beach, or a forest, or somewhere special to you.
            As you think about this place, notice how your body begins to relax.
            Your eyes may want to close. That's perfectly fine.
            Just let yourself drift...
            """
    
    def _get_therapy_script(self, protocol: Dict, ep_type: str) -> str:
        """Generate therapy script"""
        # Mock - replace with real script generation from Epic 7
        return f"""
        You are now in a deep, peaceful state of hypnosis.
        In this state, your subconscious mind is open to positive change.
        [Protocol: {protocol['name']}]
        [Adapted for: {ep_type} type]
        """
    
    async def _create_config(self, user_id: str, protocol: Dict, ep_type: str) -> SessionConfig:
        """Create session configuration"""
        # Get user preferences
        # For now, use defaults
        return SessionConfig(
            environment="therapist_office",
            avatar="sophia",
            voice="calm_female",
            music_volume=0.3,
            ambient_sounds=True,
            biometric_monitoring=True,
            safety_monitoring=True
        )
    
    def _get_ep_adaptations(self, ep_type: str) -> Dict[str, Any]:
        """Get E&P adaptations"""
        if ep_type == "Physical":
            return {
                "language_style": "direct_literal",
                "use_metaphors": False,
                "suggestion_type": "authoritative",
                "induction_method": "progressive_relaxation"
            }
        else:  # Emotional
            return {
                "language_style": "permissive_metaphorical",
                "use_metaphors": True,
                "suggestion_type": "inferential",
                "induction_method": "visualization"
            }
    
    async def _save_session(self, session: TherapySession):
        """Save session to database"""
        print(f"💾 Saving session {session.session_id}")
        # Mock - replace with real database save
    
    async def _schedule_notifications(self, session: TherapySession):
        """Schedule session reminders"""
        print(f"📅 Scheduling notifications for {session.session_id}")
        # Mock - replace with real notification service


# =============================================================================
# SESSION MANAGEMENT
# =============================================================================

class SessionManager:
    """Manage active sessions"""
    
    async def start_session(self, session_id: str) -> Dict:
        """Start a session"""
        # Update status to in_progress
        # Send to VR
        return {
            "session_id": session_id,
            "status": "in_progress",
            "vr_launch_url": f"http://localhost:5173/session/{session_id}"
        }
    
    async def update_session_progress(
        self,
        session_id: str,
        current_phase: str,
        biometric_data: Optional[Dict] = None
    ):
        """Update session progress"""
        print(f"📊 Session {session_id} progress: {current_phase}")
        # Save progress
        # Update biometric data
    
    async def complete_session(self, session_id: str, therapist_notes: Optional[str] = None):
        """Mark session as complete"""
        print(f"✅ Session {session_id} completed")
        # Update status
        # Generate session report
    
    async def cancel_session(self, session_id: str, reason: str):
        """Cancel a session"""
        print(f"❌ Session {session_id} cancelled: {reason}")
        # Update status
        # Notify user


# =============================================================================
# API ENDPOINTS
# =============================================================================

creator = SessionCreator()
manager = SessionManager()

@app.post("/api/v1/sessions/create", response_model=TherapySession)
async def create_session(
    request: SessionCreateRequest,
    background_tasks: BackgroundTasks
):
    """Create a new therapy session"""
    try:
        session = await creator.create_session(request, background_tasks)
        return session
    except Exception as e:
        raise HTTPException(500, f"Failed to create session: {str(e)}")


@app.post("/api/v1/sessions/{session_id}/start")
async def start_session(session_id: str):
    """Start a session"""
    try:
        result = await manager.start_session(session_id)
        return result
    except Exception as e:
        raise HTTPException(500, f"Failed to start session: {str(e)}")


@app.put("/api/v1/sessions/{session_id}/progress")
async def update_progress(
    session_id: str,
    current_phase: str,
    biometric_data: Optional[Dict] = None
):
    """Update session progress"""
    try:
        await manager.update_session_progress(session_id, current_phase, biometric_data)
        return {"status": "updated"}
    except Exception as e:
        raise HTTPException(500, f"Failed to update progress: {str(e)}")


@app.post("/api/v1/sessions/{session_id}/complete")
async def complete_session(session_id: str, therapist_notes: Optional[str] = None):
    """Complete a session"""
    try:
        await manager.complete_session(session_id, therapist_notes)
        return {"status": "completed"}
    except Exception as e:
        raise HTTPException(500, f"Failed to complete session: {str(e)}")


@app.get("/api/v1/sessions/{session_id}")
async def get_session(session_id: str):
    """Get session details"""
    # Mock - replace with real database query
    raise HTTPException(501, "Not implemented")


@app.get("/api/v1/sessions/user/{user_id}")
async def get_user_sessions(user_id: str, status: Optional[str] = None):
    """Get all sessions for a user"""
    # Mock - replace with real database query
    raise HTTPException(501, "Not implemented")


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "Session Management API"}


if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8012)
