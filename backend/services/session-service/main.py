"""
MEDIUM PRIORITY #1: Session Creation API
File: backend/services/session-service/main.py
Complete session management with VR integration
"""

from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Dict, Optional, Any
from datetime import datetime, timedelta
from uuid import uuid4
import json
import asyncio

app = FastAPI(
    title="Session Service",
    version="1.0.0",
    description="Session creation, management, and real-time communication"
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

class SessionConfig(BaseModel):
    """Session configuration"""
    duration_minutes: int = Field(60, ge=15, le=180)
    environment: str = Field("therapist_office", description="VR environment")
    protocol_id: str
    ep_type: str  # Physical, Emotional, Somnambulist
    audio_enabled: bool = True
    biometric_monitoring: bool = True
    safety_checks_enabled: bool = True


class CreateSessionRequest(BaseModel):
    """Request to create new session"""
    user_id: str
    therapeutic_plan_id: str
    session_config: SessionConfig
    scheduled_for: Optional[datetime] = None


class Session(BaseModel):
    """Complete session model"""
    session_id: str
    user_id: str
    therapeutic_plan_id: str
    
    # Configuration
    config: SessionConfig
    
    # Status
    status: str  # pending, active, paused, completed, cancelled
    phase: str  # setup, pre_induction, induction, depth, emergence, integration
    
    # Timing
    created_at: datetime
    scheduled_for: Optional[datetime]
    started_at: Optional[datetime]
    ended_at: Optional[datetime]
    duration_actual: Optional[int]  # Actual duration in seconds
    
    # Session Data
    script_id: Optional[str] = None
    environment_loaded: bool = False
    audio_tracks: List[str] = []
    
    # Biometric Data
    biometric_data: List[Dict] = []
    safety_checks: List[Dict] = []
    
    # Events
    events: List[Dict] = []
    
    # Completion
    completion_percentage: float = 0.0
    notes: Optional[str] = None


class BiometricData(BaseModel):
    """Biometric data point"""
    timestamp: datetime
    heart_rate: Optional[int] = None
    hrv: Optional[float] = None
    stress_level: Optional[float] = None
    arousal_level: Optional[float] = None


class SessionEvent(BaseModel):
    """Session event"""
    event_type: str  # phase_change, safety_check, user_action, system_action
    timestamp: datetime
    data: Dict[str, Any]


# =============================================================================
# SESSION MANAGER
# =============================================================================

class SessionManager:
    """Manage active sessions"""
    
    def __init__(self):
        self.sessions: Dict[str, Session] = {}
        self.websocket_connections: Dict[str, WebSocket] = {}
    
    async def create_session(
        self,
        request: CreateSessionRequest
    ) -> Session:
        """Create new therapy session"""
        
        session_id = str(uuid4())
        
        session = Session(
            session_id=session_id,
            user_id=request.user_id,
            therapeutic_plan_id=request.therapeutic_plan_id,
            config=request.session_config,
            status="pending",
            phase="setup",
            created_at=datetime.utcnow(),
            scheduled_for=request.scheduled_for,
            started_at=None,
            ended_at=None,
            duration_actual=None
        )
        
        self.sessions[session_id] = session
        
        print(f"✅ Created session: {session_id}")
        
        return session
    
    async def start_session(self, session_id: str) -> Session:
        """Start therapy session"""
        
        if session_id not in self.sessions:
            raise HTTPException(404, f"Session {session_id} not found")
        
        session = self.sessions[session_id]
        
        if session.status != "pending":
            raise HTTPException(400, f"Session {session_id} already started")
        
        session.status = "active"
        session.phase = "pre_induction"
        session.started_at = datetime.utcnow()
        
        # Load environment
        session.environment_loaded = True
        
        # Add start event
        session.events.append({
            "event_type": "session_started",
            "timestamp": datetime.utcnow().isoformat(),
            "data": {
                "phase": session.phase,
                "environment": session.config.environment
            }
        })
        
        print(f"▶️  Started session: {session_id}")
        
        # Broadcast to connected clients
        await self._broadcast(session_id, {
            "type": "session_started",
            "session_id": session_id,
            "phase": session.phase
        })
        
        return session
    
    async def pause_session(self, session_id: str) -> Session:
        """Pause active session"""
        
        if session_id not in self.sessions:
            raise HTTPException(404, f"Session {session_id} not found")
        
        session = self.sessions[session_id]
        
        if session.status != "active":
            raise HTTPException(400, f"Session {session_id} not active")
        
        session.status = "paused"
        
        session.events.append({
            "event_type": "session_paused",
            "timestamp": datetime.utcnow().isoformat(),
            "data": {"phase": session.phase}
        })
        
        print(f"⏸️  Paused session: {session_id}")
        
        await self._broadcast(session_id, {
            "type": "session_paused",
            "session_id": session_id
        })
        
        return session
    
    async def resume_session(self, session_id: str) -> Session:
        """Resume paused session"""
        
        if session_id not in self.sessions:
            raise HTTPException(404, f"Session {session_id} not found")
        
        session = self.sessions[session_id]
        
        if session.status != "paused":
            raise HTTPException(400, f"Session {session_id} not paused")
        
        session.status = "active"
        
        session.events.append({
            "event_type": "session_resumed",
            "timestamp": datetime.utcnow().isoformat(),
            "data": {"phase": session.phase}
        })
        
        print(f"▶️  Resumed session: {session_id}")
        
        await self._broadcast(session_id, {
            "type": "session_resumed",
            "session_id": session_id
        })
        
        return session
    
    async def end_session(
        self,
        session_id: str,
        completion_percentage: float = 100.0,
        notes: Optional[str] = None
    ) -> Session:
        """End therapy session"""
        
        if session_id not in self.sessions:
            raise HTTPException(404, f"Session {session_id} not found")
        
        session = self.sessions[session_id]
        
        session.status = "completed"
        session.phase = "integration"
        session.ended_at = datetime.utcnow()
        session.completion_percentage = completion_percentage
        session.notes = notes
        
        if session.started_at:
            duration = (session.ended_at - session.started_at).total_seconds()
            session.duration_actual = int(duration)
        
        session.events.append({
            "event_type": "session_ended",
            "timestamp": datetime.utcnow().isoformat(),
            "data": {
                "completion": completion_percentage,
                "duration": session.duration_actual
            }
        })
        
        print(f"⏹️  Ended session: {session_id} ({completion_percentage}% complete)")
        
        await self._broadcast(session_id, {
            "type": "session_ended",
            "session_id": session_id,
            "completion": completion_percentage
        })
        
        return session
    
    async def change_phase(
        self,
        session_id: str,
        new_phase: str
    ) -> Session:
        """Change session phase"""
        
        if session_id not in self.sessions:
            raise HTTPException(404, f"Session {session_id} not found")
        
        session = self.sessions[session_id]
        old_phase = session.phase
        session.phase = new_phase
        
        session.events.append({
            "event_type": "phase_changed",
            "timestamp": datetime.utcnow().isoformat(),
            "data": {
                "from": old_phase,
                "to": new_phase
            }
        })
        
        print(f"🔄 Phase change in {session_id}: {old_phase} → {new_phase}")
        
        await self._broadcast(session_id, {
            "type": "phase_changed",
            "session_id": session_id,
            "phase": new_phase
        })
        
        return session
    
    async def add_biometric_data(
        self,
        session_id: str,
        data: BiometricData
    ) -> None:
        """Add biometric data point"""
        
        if session_id not in self.sessions:
            raise HTTPException(404, f"Session {session_id} not found")
        
        session = self.sessions[session_id]
        session.biometric_data.append(data.dict())
        
        # Check for safety concerns
        if data.heart_rate and data.heart_rate > 140:
            await self._trigger_safety_check(session_id, "High heart rate detected")
    
    async def _trigger_safety_check(
        self,
        session_id: str,
        reason: str
    ) -> None:
        """Trigger safety check"""
        
        if session_id not in self.sessions:
            return
        
        session = self.sessions[session_id]
        
        safety_check = {
            "timestamp": datetime.utcnow().isoformat(),
            "reason": reason,
            "action": "Paused for safety check"
        }
        
        session.safety_checks.append(safety_check)
        
        print(f"⚠️  Safety check triggered in {session_id}: {reason}")
        
        # Auto-pause session
        await self.pause_session(session_id)
        
        # Broadcast alert
        await self._broadcast(session_id, {
            "type": "safety_alert",
            "session_id": session_id,
            "reason": reason
        })
    
    async def _broadcast(self, session_id: str, message: Dict) -> None:
        """Broadcast message to connected clients"""
        
        if session_id in self.websocket_connections:
            try:
                await self.websocket_connections[session_id].send_json(message)
            except Exception as e:
                print(f"❌ Broadcast error for {session_id}: {e}")
    
    def get_session(self, session_id: str) -> Session:
        """Get session by ID"""
        
        if session_id not in self.sessions:
            raise HTTPException(404, f"Session {session_id} not found")
        
        return self.sessions[session_id]
    
    def get_user_sessions(
        self,
        user_id: str,
        status: Optional[str] = None
    ) -> List[Session]:
        """Get user's sessions"""
        
        sessions = [
            s for s in self.sessions.values()
            if s.user_id == user_id
        ]
        
        if status:
            sessions = [s for s in sessions if s.status == status]
        
        return sorted(sessions, key=lambda s: s.created_at, reverse=True)


# =============================================================================
# SESSION MANAGER INSTANCE
# =============================================================================

session_manager = SessionManager()


# =============================================================================
# API ENDPOINTS
# =============================================================================

@app.post("/api/v1/sessions/create", response_model=Session)
async def create_session(request: CreateSessionRequest):
    """Create new therapy session"""
    try:
        session = await session_manager.create_session(request)
        return session
    except Exception as e:
        raise HTTPException(500, f"Failed to create session: {str(e)}")


@app.post("/api/v1/sessions/{session_id}/start", response_model=Session)
async def start_session(session_id: str):
    """Start therapy session"""
    return await session_manager.start_session(session_id)


@app.post("/api/v1/sessions/{session_id}/pause", response_model=Session)
async def pause_session(session_id: str):
    """Pause active session"""
    return await session_manager.pause_session(session_id)


@app.post("/api/v1/sessions/{session_id}/resume", response_model=Session)
async def resume_session(session_id: str):
    """Resume paused session"""
    return await session_manager.resume_session(session_id)


@app.post("/api/v1/sessions/{session_id}/end", response_model=Session)
async def end_session(
    session_id: str,
    completion: float = 100.0,
    notes: Optional[str] = None
):
    """End therapy session"""
    return await session_manager.end_session(session_id, completion, notes)


@app.get("/api/v1/sessions/{session_id}", response_model=Session)
async def get_session(session_id: str):
    """Get session details"""
    return session_manager.get_session(session_id)


@app.get("/api/v1/sessions/user/{user_id}", response_model=List[Session])
async def get_user_sessions(
    user_id: str,
    status: Optional[str] = None
):
    """Get user's sessions"""
    return session_manager.get_user_sessions(user_id, status)


@app.post("/api/v1/sessions/{session_id}/phase")
async def change_phase(session_id: str, phase: str):
    """Change session phase"""
    return await session_manager.change_phase(session_id, phase)


@app.post("/api/v1/sessions/{session_id}/biometric")
async def add_biometric_data(session_id: str, data: BiometricData):
    """Add biometric data"""
    await session_manager.add_biometric_data(session_id, data)
    return {"success": True}


# =============================================================================
# WEBSOCKET ENDPOINT
# =============================================================================

@app.websocket("/ws/{session_id}")
async def websocket_endpoint(websocket: WebSocket, session_id: str):
    """WebSocket connection for real-time session updates"""
    
    await websocket.accept()
    session_manager.websocket_connections[session_id] = websocket
    
    print(f"🔌 WebSocket connected: {session_id}")
    
    try:
        while True:
            # Receive messages from client
            data = await websocket.receive_text()
            message = json.loads(data)
            
            # Handle different message types
            if message["type"] == "ping":
                await websocket.send_json({"type": "pong"})
            
            elif message["type"] == "biometric":
                biometric_data = BiometricData(**message["data"])
                await session_manager.add_biometric_data(session_id, biometric_data)
            
            elif message["type"] == "event":
                # Log custom event
                session = session_manager.get_session(session_id)
                session.events.append({
                    "event_type": "custom",
                    "timestamp": datetime.utcnow().isoformat(),
                    "data": message["data"]
                })
            
    except WebSocketDisconnect:
        print(f"🔌 WebSocket disconnected: {session_id}")
        if session_id in session_manager.websocket_connections:
            del session_manager.websocket_connections[session_id]


@app.get("/health")
async def health_check():
    """Health check"""
    return {
        "status": "healthy",
        "service": "Session Service",
        "active_sessions": len([s for s in session_manager.sessions.values() if s.status == "active"])
    }


if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8012)
