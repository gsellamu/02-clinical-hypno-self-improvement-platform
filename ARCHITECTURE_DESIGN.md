# System Architecture Design
## Therapeutic Journaling Platform - Hypno Resilient Mind 12

**Version:** 1.0
**Date:** 2026-02-11
**Status:** Phase 2 - Architecture Design

---

## 1. ARCHITECTURE OVERVIEW

### 1.1 System Type
**Multi-Tier Microservices Architecture** with Event-Driven Components

### 1.2 Deployment Model
- **Frontend:** Progressive Web App (PWA) + WebXR + Desktop App
- **Backend:** Containerized microservices on Kubernetes
- **Database:** PostgreSQL (primary) + Redis (cache) + Pinecone (vector)
- **Storage:** MinIO (S3-compatible) for artifacts
- **Cloud:** AWS with multi-region support

### 1.3 Architecture Principles
1. **Safety First:** Safety Guardian runs before all operations
2. **Modularity:** Each agent = separate microservice
3. **Observability:** Traces, logs, metrics for every transaction
4. **Resilience:** Circuit breakers, retries, graceful degradation
5. **Privacy:** Encryption at rest/transit, anonymization, GDPR compliance
6. **Performance:** < 3.5s E2E latency, 99.9% uptime
7. **Scalability:** Horizontal scaling to 100k+ concurrent users

---

## 2. HIGH-LEVEL ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│  Web App (Vite+React+R3F) │ VR App (WebXR Quest 3) │ Desktop   │
└───────────────┬─────────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API GATEWAY LAYER                          │
├─────────────────────────────────────────────────────────────────┤
│  Kong Gateway (Rate Limiting, Auth, Routing)                    │
│  TLS 1.3 Termination │ JWT Validation │ Request Logging         │
└───────────────┬─────────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────────┐
│                   ORCHESTRATION LAYER                           │
├─────────────────────────────────────────────────────────────────┤
│              LangGraph Workflow Orchestrator                    │
│  • State Machine (session lifecycle)                            │
│  • Agent Routing & Sequencing                                   │
│  • Conditional Branching                                        │
│  • Checkpoint & Resume                                          │
└───────────────┬─────────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      AGENT SERVICES LAYER                       │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   Safety     │  │   Intake &   │  │  Journaling  │         │
│  │   Guardian   │  │    Triage    │  │    Coach     │         │
│  │   (8350)     │  │   (8351)     │  │   (8352)     │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │     XR       │  │   Content    │  │   Somatic    │         │
│  │    Scene     │  │   Producer   │  │  Regulator   │         │
│  │  Director    │  │   (8354)     │  │   (8355)     │         │
│  │   (8353)     │  └──────────────┘  └──────────────┘         │
│  └──────────────┘  ┌──────────────┐  ┌──────────────┐         │
│  │  Reflection  │  │     RAG      │                            │
│  │  Summarizer  │  │  Librarian   │                            │
│  │   (8356)     │  │   (8357)     │                            │
│  └──────────────┘  └──────────────┘                            │
└───────────────┬─────────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────────┐
│                        MCP TOOL LAYER                           │
├─────────────────────────────────────────────────────────────────┤
│  rag_retrieve │ create_session_plan │ generate_prompt_pack     │
│  create_xr_scene_spec │ tts_render │ safety_screen             │
│  save_artifact │ send_notification │ log_event                 │
└───────────────┬─────────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────────┐
│                       DATA LAYER                                │
├─────────────────────────────────────────────────────────────────┤
│  PostgreSQL (Primary)  │  Redis (Cache)  │  Pinecone (Vector)  │
│  MinIO (Artifacts)     │  Kafka (Events) │                     │
└─────────────────────────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────────┐
│                   EXTERNAL SERVICES LAYER                       │
├─────────────────────────────────────────────────────────────────┤
│  OpenAI GPT-4o │ Anthropic Claude 4.5 │ Google Gemini 2.0      │
│  ElevenLabs TTS│ Whisper STT │ Hume AI Sentiment              │
│  Cloudinary CDN│ Twilio SMS │ SendGrid Email                   │
└─────────────────────────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────────┐
│                  OBSERVABILITY LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│  Prometheus │ Grafana │ Datadog │ OpenTelemetry │ ELK Stack    │
│  PagerDuty  │ Sentry  │                                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. COMPONENT SPECIFICATIONS

### 3.1 Frontend Components

#### Web App (Vite + React + TypeScript)
**Port:** 3000
**Tech Stack:**
- Vite 5.x (build tool)
- React 18 (UI library)
- React Three Fiber (3D scenes)
- Zustand (state management)
- TanStack Query (server state)
- WebAudio API (soundscapes)

**Key Features:**
- Progressive Web App (offline support)
- Responsive design (mobile-first)
- Dark/light theme
- Accessibility (WCAG 2.1 AA)

**State Management:**
- `AuthContext`: user authentication
- `SessionContext`: active journaling session
- `ExerciseContext`: current exercise state
- `XRContext`: VR/3D environment state

#### VR App (WebXR)
**Platform:** Quest 3
**Renderer:** Three.js + WebXR API

**Environments:**
- Cozy Cabin (fireplace, forest sounds)
- Beach Sunset (waves, seagulls)
- Forest Clearing (birds, stream)
- Mountain Vista (wind, distant eagles)
- Inner Sanctuary (ambient meditation)

**Interactions:**
- Gaze-based UI (1.5s dwell)
- Hand tracking (Quest 3 native)
- Controller input (Quest Touch Pro)
- Spatial audio (HRTF)
- Bilateral drawing (dual canvases)

---

### 3.2 Backend Services

#### API Gateway (Kong)
**Port:** 8080 (HTTP), 8443 (HTTPS)

**Responsibilities:**
- TLS termination
- JWT validation
- Rate limiting (100 req/min per user)
- Request routing
- CORS handling
- API versioning (/api/v1)

**Rate Limits:**
| Endpoint Pattern | Limit | Window |
|------------------|-------|--------|
| /api/v1/sessions/* | 100 | 1 min |
| /api/v1/exercises/* | 50 | 1 min |
| /api/v1/crisis/* | 1000 | 1 min (unlimited) |

#### LangGraph Orchestrator
**Port:** 8300
**Tech:** Python + FastAPI + LangGraph

**State Machine:**
```python
states = [
    "created",
    "intake_pending",
    "safety_screening",
    "active",
    "exercise_in_progress",
    "reflecting",
    "hitl_review",
    "completed",
    "timed_out",
    "error"
]

transitions = {
    "created": ["intake_pending"],
    "intake_pending": ["safety_screening", "error"],
    "safety_screening": ["active", "hitl_review", "crisis_escalated"],
    "active": ["exercise_in_progress"],
    "exercise_in_progress": ["reflecting", "timed_out"],
    "reflecting": ["completed", "hitl_review"],
    "hitl_review": ["active", "completed"],
    "completed": [],
    "timed_out": ["active"],  # resumable
    "error": []
}
```

**Workflow Execution:**
1. Receive session request
2. Load/create session state
3. Execute agent sequence (with conditionals)
4. Checkpoint state after each agent
5. Handle retries/failures
6. Return aggregated response

---

### 3.3 Agent Services (FastAPI Microservices)

#### Safety Guardian (Port 8350)
**Purpose:** First-line safety screening

**Input:**
```json
{
  "user_id": "uuid",
  "session_id": "uuid",
  "user_input": "text",
  "session_history": [...],
  "user_profile": {...}
}
```

**Output:**
```json
{
  "safety_status": "green|yellow|red",
  "crisis_level": "none|low|medium|severe",
  "constraints": ["no_memory_recovery", "gentle_pacing"],
  "response_mode": "standard|cautious|crisis",
  "recommended_action": "continue|review|escalate",
  "confidence_score": 0.95
}
```

**LLM:** Claude Sonnet 4.5 (safety-tuned)
**Latency Target:** < 300ms

---

#### Intake & Triage (Port 8351)
**Purpose:** Classify session intent

**Output:**
```json
{
  "goal_category": "relationships|career|personal|health",
  "intensity_level": 1-5,
  "readiness_score": 1-10,
  "contraindications": [],
  "recommended_techniques": ["unsent_letter", "dialogue"],
  "estimated_duration_minutes": 30
}
```

**LLM:** GPT-4o (classification-tuned)
**Latency Target:** < 500ms

---

#### Journaling Coach (Port 8352)
**Purpose:** Select and guide journaling technique

**Output:**
```json
{
  "selected_technique": "unsent_letter",
  "technique_config": {
    "timebox_minutes": 15,
    "recipient": "father",
    "tone": "honest_but_respectful"
  },
  "opening_prompt": "Write a letter to your father...",
  "guideposts": [...],
  "grounding_close": "Take 3 deep breaths..."
}
```

**LLM:** Claude Sonnet 4.5 + RAG (workbook-aligned)
**Latency Target:** < 800ms

---

#### Content Producer (Port 8354)
**Purpose:** Generate narration, TTS, prompts

**Output:**
```json
{
  "narration_script": "Welcome to your journaling session...",
  "tts_audio_urls": ["https://minio/tts_chunk_1.mp3", ...],
  "on_screen_prompts": ["Keep writing...", "Don't edit..."],
  "background_audio": "forest_ambience.mp3",
  "ssml_markup": "<speak>...</speak>"
}
```

**TTS:** ElevenLabs (emotional range)
**Latency Target:** < 1200ms (streaming)

---

#### Reflection Summarizer (Port 8356)
**Purpose:** Extract themes, suggest next steps

**Output:**
```json
{
  "recurring_themes": ["self-doubt", "desire_for_connection"],
  "emotional_tone": "contemplative_with_hope",
  "action_items": ["schedule_coffee_with_friend"],
  "unresolved_questions": ["Am I ready to leave this job?"],
  "sentiment_score": 0.35,
  "word_count": 847,
  "next_session_recommendation": "Continue exploring career transition"
}
```

**LLM:** GPT-4o (summarization)
**Latency Target:** < 600ms

---

#### RAG Librarian (Port 8357)
**Purpose:** Retrieve workbook-aligned guidance

**Workflow:**
1. Embed query (OpenAI text-embedding-3-large)
2. Search Pinecone (workbook_vectors collection)
3. Retrieve top-3 chunks
4. Paraphrase in platform voice
5. Return with internal citations

**Latency Target:** < 500ms

---

### 3.4 Data Layer

#### PostgreSQL Schema (Primary Database)
**Port:** 5431
**Version:** 15.x

**Core Tables:**
- `users` (authentication, profile)
- `sessions` (journaling sessions)
- `session_events` (state transitions)
- `agent_outputs` (LLM responses)
- `exercises` (completed exercises)
- `artifacts` (journaling entries)
- `hitl_escalations` (review queue)
- `crisis_logs` (privacy-preserving)
- `audit_logs` (compliance)

**Indexes:**
- `idx_sessions_user_id` (B-tree)
- `idx_agent_outputs_session_id` (B-tree)
- `idx_hitl_escalations_priority_deadline` (composite)

**Partitioning:**
- `audit_logs` partitioned by month
- `session_events` partitioned by week

---

#### Redis Cache
**Port:** 6379
**Use Cases:**
- Session state (TTL: 1 hour)
- User profile (TTL: 15 min)
- Rate limiting counters
- Real-time queue (HITL notifications)

**Key Patterns:**
- `session:{session_id}:state`
- `user:{user_id}:profile`
- `ratelimit:{user_id}:{endpoint}`

---

#### Pinecone Vector Store
**Index:** `workbook_vectors`
**Dimensions:** 3072 (OpenAI text-embedding-3-large)
**Metric:** cosine

**Metadata:**
```json
{
  "source": "Therapeutic Journaling Workbook 1",
  "page": 12,
  "technique": "unsent_letter",
  "chunk_id": "TJ1-P12-C3"
}
```

---

#### MinIO Object Storage
**Port:** 9000 (API), 9001 (Console)
**Buckets:**
- `tts-cache` (TTS audio files)
- `user-artifacts` (journaling exports, PDFs)
- `xr-environments` (3D assets, textures)
- `session-recordings` (VR session replays)

**Lifecycle Policies:**
- `tts-cache`: 30-day expiration
- `user-artifacts`: retain until user deletion
- `session-recordings`: 90-day expiration

---

## 4. SECURITY ARCHITECTURE

### 4.1 Authentication & Authorization
**Method:** OAuth 2.0 + JWT

**Flow:**
1. User logs in (email/password or SSO)
2. Auth service issues JWT (access token + refresh token)
3. Access token valid for 1 hour
4. Refresh token valid for 30 days
5. JWT includes: `user_id`, `roles`, `permissions`, `exp`

**Roles:**
- `user` (journaling access)
- `clinician` (HITL review access)
- `admin` (platform management)

---

### 4.2 Encryption
**At Rest:**
- PostgreSQL: AES-256 encryption
- MinIO: Server-side encryption (SSE)
- Redis: Encryption enabled

**In Transit:**
- TLS 1.3 (all API calls)
- WSS (WebSocket Secure for real-time)

**Application-Level:**
- Sensitive user inputs: AES-256-GCM
- Crisis logs: SHA-256 hashed (no plaintext)

---

### 4.3 Compliance
**HIPAA:**
- BAA (Business Associate Agreement) with AWS
- Audit logs for all PHI access
- Encryption at rest/transit
- Minimum necessary access

**GDPR:**
- Right to access (export API)
- Right to deletion (anonymization)
- Data portability (JSON export)
- Consent tracking (`consent_records` table)

---

## 5. SCALABILITY & PERFORMANCE

### 5.1 Horizontal Scaling
**Auto-scaling Triggers:**
- CPU > 70%: +2 pods
- Memory > 80%: +2 pods
- Request queue > 100: +1 pod

**Load Balancing:**
- Round-robin (default)
- Least connections (agent services)
- Sticky sessions (WebSocket)

---

### 5.2 Performance Optimizations
1. **Caching:** Redis for hot data (85%+ hit rate)
2. **CDN:** Cloudinary for static assets
3. **Database:** Connection pooling (pgbouncer)
4. **LLM:** Prompt caching (OpenAI/Anthropic)
5. **TTS:** Pre-generate common phrases

---

## 6. OBSERVABILITY

### 6.1 Metrics (Prometheus)
- Request latency (p50, p95, p99)
- Error rate (4xx, 5xx)
- Agent execution time
- Database query time
- Cache hit rate

### 6.2 Traces (OpenTelemetry)
- Distributed tracing across services
- Span per agent execution
- Trace ID propagation in headers

### 6.3 Logs (ELK Stack)
- Structured JSON logs
- Retention: 90 days
- Searchable in < 3 seconds

---

## 7. DISASTER RECOVERY

### 7.1 Backup Strategy
- **PostgreSQL:** Daily full backup + WAL archiving
- **Redis:** RDB snapshots every 6 hours
- **MinIO:** S3 cross-region replication

### 7.2 RTO/RPO
- **RTO (Recovery Time Objective):** 4 hours
- **RPO (Recovery Point Objective):** 15 minutes

---

**Next Steps:**
- Database schema design (ERD)
- API specifications (OpenAPI 3.0)
- Deployment diagram (Kubernetes)
- Test plan implementation
