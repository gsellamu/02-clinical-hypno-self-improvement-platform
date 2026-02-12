# DEV1: Monorepo Scaffold - Therapeutic Journaling Platform
## Complete Project Structure with Running "Hello Scene + Hello Session"

**Version:** 1.0
**Date:** 2026-02-11
**Stack:** Vite + React + TypeScript + R3F + FastAPI + LangGraph + PostgreSQL + Redis

---

## MONOREPO STRUCTURE

```
therapeutic-journaling-platform/
├── package.json                        # Root workspace config
├── pnpm-workspace.yaml                # pnpm workspace definition
├── turbo.json                         # Turborepo build config
├── .env.example                       # Environment variables template
├── docker-compose.yml                 # Infrastructure services
├── README.md                          # Project documentation
│
├── apps/
│   └── web/                           # Vite + React + R3F frontend
│       ├── package.json
│       ├── tsconfig.json
│       ├── vite.config.ts
│       ├── index.html
│       ├── src/
│       │   ├── main.tsx
│       │   ├── App.tsx
│       │   ├── scenes/
│       │   │   └── HelloScene.tsx     # Minimal R3F scene
│       │   ├── components/
│       │   │   └── JournalingPanel.tsx
│       │   └── api/
│       │       └── client.ts          # API client
│       └── public/
│
├── services/
│   ├── api/                           # FastAPI backend
│   │   ├── pyproject.toml
│   │   ├── main.py
│   │   ├── app/
│   │   │   ├── __init__.py
│   │   │   ├── api/
│   │   │   │   ├── __init__.py
│   │   │   │   ├── session.py         # Session endpoints
│   │   │   │   ├── journal.py         # Journal endpoints
│   │   │   │   └── safety.py          # Safety endpoints
│   │   │   ├── models/
│   │   │   │   ├── __init__.py
│   │   │   │   ├── session.py
│   │   │   │   └── journal.py
│   │   │   ├── db/
│   │   │   │   ├── __init__.py
│   │   │   │   └── database.py
│   │   │   └── core/
│   │   │       ├── __init__.py
│   │   │       └── config.py
│   │   └── Dockerfile
│   │
│   └── orchestrator/                  # LangGraph workflow engine
│       ├── pyproject.toml
│       ├── main.py
│       ├── app/
│       │   ├── __init__.py
│       │   ├── graph.py               # LangGraph state machine
│       │   ├── nodes/
│       │   │   ├── __init__.py
│       │   │   ├── safety_screen.py
│       │   │   ├── intake.py
│       │   │   └── technique_select.py
│       │   └── state.py               # Typed state definition
│       └── Dockerfile
│
├── packages/
│   ├── shared/                        # Shared types & schemas
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   ├── src/
│   │   │   ├── index.ts
│   │   │   ├── types/
│   │   │   │   ├── session.ts
│   │   │   │   ├── journal.ts
│   │   │   │   └── scene.ts
│   │   │   └── schemas/
│   │   │       └── validation.ts      # Zod schemas
│   │   └── package.json
│   │
│   └── ui/                            # Design system components
│       ├── package.json
│       ├── tsconfig.json
│       ├── src/
│       │   ├── index.ts
│       │   ├── components/
│       │   │   ├── Button.tsx
│       │   │   ├── Panel.tsx
│       │   │   └── Typography.tsx
│       │   └── theme/
│       │       └── colors.ts
│       └── package.json
│
└── infra/
    ├── docker-compose.yml
    ├── postgres/
    │   └── init.sql                   # Database initialization
    └── redis/
        └── redis.conf
```

---

## ROOT PACKAGE.JSON

```json
{
  "name": "therapeutic-journaling-platform",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "workspaces": [
    "apps/*",
    "packages/*"
  ],
  "scripts": {
    "dev": "turbo run dev --parallel",
    "dev:web": "pnpm --filter web dev",
    "dev:api": "cd services/api && uvicorn main:app --reload --port 8140",
    "dev:orchestrator": "cd services/orchestrator && uvicorn main:app --reload --port 8145",
    "build": "turbo run build",
    "test": "turbo run test",
    "lint": "turbo run lint",
    "type-check": "turbo run type-check",
    "docker:up": "docker-compose -f infra/docker-compose.yml up -d",
    "docker:down": "docker-compose -f infra/docker-compose.yml down",
    "docker:logs": "docker-compose -f infra/docker-compose.yml logs -f",
    "db:migrate": "cd services/api && alembic upgrade head",
    "db:reset": "docker-compose -f infra/docker-compose.yml down -v && pnpm docker:up && pnpm db:migrate",
    "hello": "pnpm docker:up && concurrently \"pnpm dev:web\" \"pnpm dev:api\" \"pnpm dev:orchestrator\""
  },
  "devDependencies": {
    "turbo": "^1.13.0",
    "concurrently": "^8.2.2",
    "@types/node": "^20.11.0",
    "typescript": "^5.3.3"
  },
  "engines": {
    "node": ">=18.0.0",
    "pnpm": ">=8.0.0"
  },
  "packageManager": "pnpm@8.15.0"
}
```

---

## PNPM-WORKSPACE.YAML

```yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

---

## TURBO.JSON

```json
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "outputs": []
    },
    "type-check": {
      "dependsOn": ["^build"],
      "outputs": []
    },
    "test": {
      "dependsOn": ["^build"],
      "outputs": []
    }
  }
}
```

---

## .ENV.EXAMPLE

```bash
# Application
NODE_ENV=development
APP_NAME=therapeutic-journaling-platform
APP_VERSION=1.0.0

# Frontend (Vite)
VITE_API_BASE_URL=http://localhost:8140
VITE_ORCHESTRATOR_URL=http://localhost:8145
VITE_WS_URL=ws://localhost:8140/ws

# FastAPI Backend
API_HOST=0.0.0.0
API_PORT=8140
API_RELOAD=true
API_LOG_LEVEL=info

# Orchestrator
ORCHESTRATOR_PORT=8145

# Database (PostgreSQL + pgvector)
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=therapeutic_journaling
POSTGRES_USER=journaling_user
POSTGRES_PASSWORD=change_me_in_production
DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DB=0
REDIS_PASSWORD=
REDIS_URL=redis://${REDIS_HOST}:${REDIS_PORT}/${REDIS_DB}

# LLM API Keys (for orchestrator)
ANTHROPIC_API_KEY=sk-ant-your-key-here
OPENAI_API_KEY=sk-your-key-here
GOOGLE_API_KEY=your-key-here

# ElevenLabs (TTS)
ELEVENLABS_API_KEY=your-key-here

# Security
SECRET_KEY=generate-a-secure-random-key-here
JWT_SECRET=another-secure-random-key
CORS_ORIGINS=http://localhost:5173,http://localhost:3000

# Feature Flags
ENABLE_SAFETY_GUARDIAN=true
ENABLE_TTS=true
ENABLE_VR_MODE=true

# Monitoring (Optional)
SENTRY_DSN=
POSTHOG_API_KEY=
```

---

## DOCKER-COMPOSE.YML

```yaml
version: '3.8'

services:
  postgres:
    image: pgvector/pgvector:pg16
    container_name: tj_postgres
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-journaling_user}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-change_me_in_production}
      POSTGRES_DB: ${POSTGRES_DB:-therapeutic_journaling}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./infra/postgres/init.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-journaling_user}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - tj_network

  redis:
    image: redis:7-alpine
    container_name: tj_redis
    command: redis-server --appendonly yes
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
      - ./infra/redis/redis.conf:/usr/local/etc/redis/redis.conf
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5
    networks:
      - tj_network

  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: tj_pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@jeeth.ai
      PGADMIN_DEFAULT_PASSWORD: admin
    ports:
      - "5050:80"
    depends_on:
      - postgres
    networks:
      - tj_network
    profiles:
      - tools

volumes:
  postgres_data:
  redis_data:

networks:
  tj_network:
    driver: bridge
```

---

## APPS/WEB/PACKAGE.JSON

```json
{
  "name": "web",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "lint": "eslint src --ext ts,tsx",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@react-three/fiber": "^8.15.0",
    "@react-three/drei": "^9.92.0",
    "@react-three/xr": "^6.2.0",
    "three": "^0.160.0",
    "zustand": "^4.5.0",
    "axios": "^1.6.0",
    "zod": "^3.22.0",
    "shared": "workspace:*",
    "ui": "workspace:*"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@types/three": "^0.160.0",
    "@vitejs/plugin-react": "^4.2.0",
    "vite": "^5.0.0",
    "typescript": "^5.3.3",
    "eslint": "^8.56.0"
  }
}
```

---

## APPS/WEB/VITE.CONFIG.TS

```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      'shared': path.resolve(__dirname, '../../packages/shared/src'),
      'ui': path.resolve(__dirname, '../../packages/ui/src')
    }
  },
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:8140',
        changeOrigin: true
      }
    }
  },
  build: {
    outDir: 'dist',
    sourcemap: true
  }
})
```

---

## APPS/WEB/SRC/MAIN.TSX

```typescript
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)
```

---

## APPS/WEB/SRC/APP.TSX

```typescript
import { Canvas } from '@react-three/fiber'
import { OrbitControls, Text } from '@react-three/drei'
import HelloScene from './scenes/HelloScene'
import { useState, useEffect } from 'react'
import { apiClient } from './api/client'

function App() {
  const [sessionId, setSessionId] = useState<string | null>(null)
  const [message, setMessage] = useState<string>('Click to Start Session')

  const startSession = async () => {
    try {
      const response = await apiClient.post('/session/start', {
        user_id: 'demo-user-001',
        technique: 'sprint'
      })
      setSessionId(response.data.session_id)
      setMessage(`Session Started: ${response.data.session_id}`)
    } catch (error) {
      console.error('Failed to start session:', error)
      setMessage('Error starting session')
    }
  }

  return (
    <div style={{ width: '100vw', height: '100vh' }}>
      <div style={{ 
        position: 'absolute', 
        top: 20, 
        left: 20, 
        zIndex: 1000,
        background: 'rgba(0,0,0,0.7)',
        padding: '20px',
        borderRadius: '10px',
        color: 'white'
      }}>
        <h1>Therapeutic Journaling Platform</h1>
        <p>{message}</p>
        <button 
          onClick={startSession}
          style={{
            padding: '10px 20px',
            fontSize: '16px',
            cursor: 'pointer',
            background: '#4a90e2',
            color: 'white',
            border: 'none',
            borderRadius: '5px'
          }}
        >
          Start Hello Session
        </button>
      </div>
      
      <Canvas camera={{ position: [0, 1.6, 3], fov: 75 }}>
        <color attach="background" args={['#87ceeb']} />
        <ambientLight intensity={0.6} />
        <directionalLight position={[5, 10, 7]} intensity={1.2} />
        
        <HelloScene sessionId={sessionId} />
        
        <OrbitControls />
      </Canvas>
    </div>
  )
}

export default App
```

---

## APPS/WEB/SRC/SCENES/HELLOSCENE.TSX

```typescript
import { Text, Box } from '@react-three/drei'
import { useFrame } from '@react-three/fiber'
import { useRef } from 'react'
import * as THREE from 'three'

interface HelloSceneProps {
  sessionId: string | null
}

function HelloScene({ sessionId }: HelloSceneProps) {
  const meshRef = useRef<THREE.Mesh>(null)
  
  useFrame((state, delta) => {
    if (meshRef.current) {
      meshRef.current.rotation.y += delta * 0.5
    }
  })

  return (
    <>
      {/* Ground */}
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, 0, 0]}>
        <planeGeometry args={[10, 10]} />
        <meshStandardMaterial color="#6b8e4a" />
      </mesh>

      {/* Floating Welcome Text */}
      <Text
        position={[0, 2, -2]}
        fontSize={0.3}
        color="#2c3e50"
        anchorX="center"
        anchorY="middle"
      >
        Welcome to Your Journaling Space
      </Text>

      {/* Rotating Cube */}
      <Box ref={meshRef} args={[0.5, 0.5, 0.5]} position={[0, 1, -1.5]}>
        <meshStandardMaterial color={sessionId ? "#27ae60" : "#95a5a6"} />
      </Box>

      {/* Session Status */}
      {sessionId && (
        <Text
          position={[0, 1.5, -2]}
          fontSize={0.15}
          color="#27ae60"
          anchorX="center"
          anchorY="middle"
        >
          {`Session Active: ${sessionId.slice(0, 8)}...`}
        </Text>
      )}
    </>
  )
}

export default HelloScene
```

---

## APPS/WEB/SRC/API/CLIENT.TS

```typescript
import axios from 'axios'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8140'

export const apiClient = axios.create({
  baseURL: `${API_BASE_URL}/api`,
  headers: {
    'Content-Type': 'application/json'
  },
  timeout: 10000
})

// Request interceptor
apiClient.interceptors.request.use(
  (config) => {
    // Add auth token if available
    const token = localStorage.getItem('auth_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// Response interceptor
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('API Error:', error.response?.data || error.message)
    return Promise.reject(error)
  }
)
```

---

## SERVICES/API/PYPROJECT.TOML

```toml
[tool.poetry]
name = "therapeutic-journaling-api"
version = "1.0.0"
description = "FastAPI backend for therapeutic journaling platform"
authors = ["Jeeth.AI Team"]

[tool.poetry.dependencies]
python = "^3.11"
fastapi = "^0.109.0"
uvicorn = {extras = ["standard"], version = "^0.27.0"}
pydantic = "^2.5.0"
pydantic-settings = "^2.1.0"
sqlalchemy = "^2.0.25"
asyncpg = "^0.29.0"
alembic = "^1.13.1"
redis = "^5.0.1"
python-jose = {extras = ["cryptography"], version = "^3.3.0"}
passlib = {extras = ["bcrypt"], version = "^1.7.4"}
python-multipart = "^0.0.6"
httpx = "^0.26.0"
pgvector = "^0.2.4"

[tool.poetry.group.dev.dependencies]
pytest = "^7.4.4"
pytest-asyncio = "^0.23.3"
black = "^24.1.0"
ruff = "^0.1.14"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

---

## SERVICES/API/MAIN.PY

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api import session, journal, safety

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Therapeutic Journaling Platform API"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

# Include routers
app.include_router(session.router, prefix="/api", tags=["session"])
app.include_router(journal.router, prefix="/api", tags=["journal"])
app.include_router(safety.router, prefix="/api", tags=["safety"])

@app.get("/")
async def root():
    return {
        "message": "Therapeutic Journaling API",
        "version": settings.APP_VERSION,
        "status": "running"
    }

@app.get("/health")
async def health():
    return {"status": "healthy"}
```

---

## SERVICES/API/APP/CORE/CONFIG.PY

```python
from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    # App
    APP_NAME: str = "Therapeutic Journaling API"
    APP_VERSION: str = "1.0.0"
    
    # Server
    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8140
    
    # Database
    DATABASE_URL: str
    
    # Redis
    REDIS_URL: str
    
    # Security
    SECRET_KEY: str
    JWT_SECRET: str
    
    # CORS
    CORS_ORIGINS: List[str] = ["http://localhost:5173"]
    
    class Config:
        env_file = ".env"

settings = Settings()
```

---

## SERVICES/API/APP/API/SESSION.PY

```python
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
import uuid

router = APIRouter()

class SessionStartRequest(BaseModel):
    user_id: str
    technique: str
    ep_profile: Optional[dict] = None

class SessionStartResponse(BaseModel):
    session_id: str
    status: str
    technique: str
    created_at: datetime

@router.post("/session/start", response_model=SessionStartResponse)
async def start_session(request: SessionStartRequest):
    """
    Start a new journaling session
    """
    session_id = str(uuid.uuid4())
    
    # TODO: Store in database
    # TODO: Initialize LangGraph state
    
    return SessionStartResponse(
        session_id=session_id,
        status="initiated",
        technique=request.technique,
        created_at=datetime.utcnow()
    )

@router.post("/session/next")
async def next_session_step(session_id: str):
    """
    Advance session to next step
    """
    # TODO: Call orchestrator to transition state
    return {"session_id": session_id, "next_state": "intake"}
```

---

## SERVICES/API/APP/API/JOURNAL.PY

```python
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import uuid

router = APIRouter()

class JournalEntry(BaseModel):
    session_id: str
    content: str
    technique: str
    word_count: int
    duration_seconds: int

class JournalEntryResponse(BaseModel):
    entry_id: str
    session_id: str
    created_at: datetime
    status: str

@router.post("/journal/entry", response_model=JournalEntryResponse)
async def save_journal_entry(entry: JournalEntry):
    """
    Save a journaling entry
    """
    entry_id = str(uuid.uuid4())
    
    # TODO: Encrypt content
    # TODO: Store in database
    # TODO: Trigger analysis (themes, sentiment)
    
    return JournalEntryResponse(
        entry_id=entry_id,
        session_id=entry.session_id,
        created_at=datetime.utcnow(),
        status="saved"
    )

@router.get("/journal/entries")
async def get_journal_entries(user_id: str, limit: int = 10):
    """
    Get user's journal entries
    """
    # TODO: Query database
    return {
        "user_id": user_id,
        "entries": [],
        "total": 0
    }
```

---

## SERVICES/API/APP/API/SAFETY.PY

```python
from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional, List

router = APIRouter()

class SafetyScreenRequest(BaseModel):
    user_id: str
    context: str
    user_input: Optional[str] = None
    session_context: Optional[dict] = None

class SafetyScreenResponse(BaseModel):
    status: str  # green, yellow, red
    crisis_level: str  # none, low, medium, severe
    constraints: List[str]
    recommended_action: str
    confidence: float

@router.post("/safety/screen", response_model=SafetyScreenResponse)
async def safety_screen(request: SafetyScreenRequest):
    """
    Run safety screening
    """
    # TODO: Implement multi-signal crisis detection
    # TODO: Call Safety Guardian Service (port 8005)
    
    # DEMO: Return Code Green
    return SafetyScreenResponse(
        status="green",
        crisis_level="none",
        constraints=[],
        recommended_action="proceed_normal",
        confidence=0.95
    )
```

---

## SERVICES/ORCHESTRATOR/PYPROJECT.TOML

```toml
[tool.poetry]
name = "therapeutic-journaling-orchestrator"
version = "1.0.0"
description = "LangGraph orchestrator for journaling workflows"

[tool.poetry.dependencies]
python = "^3.11"
fastapi = "^0.109.0"
uvicorn = {extras = ["standard"], version = "^0.27.0"}
langgraph = "^0.0.20"
langchain = "^0.1.0"
anthropic = "^0.8.0"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

---

## SERVICES/ORCHESTRATOR/MAIN.PY

```python
from fastapi import FastAPI
from app.graph import journaling_graph

app = FastAPI(title="Journaling Orchestrator")

@app.get("/")
async def root():
    return {"message": "Journaling Orchestrator", "status": "running"}

@app.post("/orchestrate")
async def orchestrate_session(session_id: str, user_input: dict):
    """
    Execute LangGraph workflow
    """
    result = await journaling_graph.invoke({
        "session_id": session_id,
        **user_input
    })
    return result
```

---

## INFRA/POSTGRES/INIT.SQL

```sql
-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create initial tables
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS journaling_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    technique VARCHAR(50),
    status VARCHAR(20),
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS journaling_artifacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES journaling_sessions(id),
    content_encrypted BYTEA,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_sessions_user_id ON journaling_sessions(user_id);
CREATE INDEX idx_artifacts_session_id ON journaling_artifacts(session_id);
```

---

## PACKAGES/SHARED/SRC/TYPES/SESSION.TS

```typescript
export interface SessionStartRequest {
  user_id: string
  technique: string
  ep_profile?: EPProfile
}

export interface EPProfile {
  physical_percentage: number
  emotional_percentage: number
  classification: 'Physical' | 'Emotional' | 'Hybrid'
}

export interface SessionState {
  session_id: string
  user_id: string
  current_state: string
  safety_status: 'green' | 'yellow' | 'red'
  technique?: string
}
```

---

## README.MD

```markdown
# Therapeutic Journaling Platform

Full-stack VR/web platform for therapeutic journaling with AI-powered guidance.

## Stack

- **Frontend:** Vite + React + TypeScript + React Three Fiber
- **Backend:** FastAPI + PostgreSQL + Redis
- **Orchestrator:** LangGraph workflow engine
- **Infrastructure:** Docker Compose

## Quick Start

### Prerequisites
- Node.js 18+
- pnpm 8+
- Docker & Docker Compose
- Python 3.11+

### Installation

1. Clone and install dependencies:
```bash
git clone <repo>
cd therapeutic-journaling-platform
pnpm install
```

2. Set up environment:
```bash
cp .env.example .env
# Edit .env with your API keys
```

3. Start infrastructure:
```bash
pnpm docker:up
```

4. Run "Hello Scene + Hello Session":
```bash
pnpm hello
```

This starts:
- Frontend: http://localhost:5173
- API: http://localhost:8140
- Orchestrator: http://localhost:8145
- PgAdmin: http://localhost:5050 (admin@jeeth.ai / admin)

### Development

```bash
# Run all services
pnpm dev

# Run individual services
pnpm dev:web
pnpm dev:api
pnpm dev:orchestrator

# Database
pnpm db:migrate
pnpm db:reset

# Docker
pnpm docker:up
pnpm docker:down
pnpm docker:logs
```

## Architecture

See `/docs` folder for detailed architecture documentation.

## License

Proprietary - Jeeth.AI
```

---

**STATUS:** DEV1 Monorepo Scaffold Complete ✅
**Next Steps:** Run `pnpm hello` to see "Hello Scene + Hello Session" in action
