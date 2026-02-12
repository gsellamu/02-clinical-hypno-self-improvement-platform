┌─────────────────────────────────────────────────────────────────────┐
│              v4.0 DIAGRAM COLLECTION - SUMMARY                       │
│            HMI Hypnotherapy Platform Architecture                    │
└─────────────────────────────────────────────────────────────────────┘

NEWLY CREATED v4.0 DIAGRAMS
═══════════════════════════════════════════════════════════════════════

This document catalogs all newly created sequence and state machine 
diagrams for v4.0 features, complementing the existing diagrams you 
provided for reference.


EXISTING DIAGRAMS (For Reference):
───────────────────────────────────────────────────────────────────────

✓ First_Session_-_Complete_E2E_Flow.mmd
✓ Multi-Agent_Collaboration.mmd
✓ Real-Time_Biometric_Adaptation.mmd
✓ safety_escalation.mmd
✓ sug_questionnaire.mmd
✓ 4_4_User_Journey_State_Machine__Macro-Level_.mmd
✓ 4_5_Safety_Monitoring_State_Machine.mmd
✓ Assessment_Flow.mmd
✓ session-orchestration-state-machine.mmd


NEW v4.0 DIAGRAMS CREATED:
═══════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────┐
│ 1. WebXR Session Lifecycle State Machine                            │
│    File: 4_6_WebXR_Session_Lifecycle_State_Machine.mmd              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│ PURPOSE:                                                             │
│ Comprehensive state machine for the entire WebXR session lifecycle  │
│ from device detection to session termination.                       │
│                                                                      │
│ KEY STATES:                                                          │
│ • DEVICE_DETECTION                                                   │
│ • XR_AVAILABLE / FALLBACK_MODE                                       │
│ • XR_SESSION_REQUESTED                                               │
│ • SESSION_INITIALIZING                                               │
│ • ENVIRONMENT_LOADING                                                │
│ • XR_SESSION_ACTIVE (with concurrent states)                         │
│   - INPUT_TRACKING                                                   │
│   - AUDIO_PLAYBACK                                                   │
│   - PERFORMANCE_MONITORING                                           │
│ • ENVIRONMENT_SWITCH                                                 │
│ • XR_SESSION_ENDING                                                  │
│ • SESSION_TERMINATED                                                 │
│                                                                      │
│ FEATURES COVERED:                                                    │
│ • Quest 3 / Vision Pro / PC VR detection                             │
│ • WebGL context initialization                                      │
│ • Controller and hand tracking setup                                │
│ • Environment loading with LOD                                      │
│ • Real-time performance guardian (parallel process)                 │
│ • Error states and recovery                                         │
│ • Smooth environment transitions                                    │
│                                                                      │
│ TARGET DEVICES:                                                      │
│ • Meta Quest 3 (Primary)                                             │
│ • Apple Vision Pro                                                   │
│ • PC VR headsets                                                     │
│ • Desktop browser (fallback)                                         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ 2. Performance & LOD Management State Machine                       │
│    File: 4_7_Performance_LOD_State_Machine.mmd                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│ PURPOSE:                                                             │
│ Dynamic performance optimization and Level-of-Detail management     │
│ to maintain 85-90 FPS on Quest 3.                                   │
│                                                                      │
│ KEY STATES:                                                          │
│ • PERF_INITIALIZATION                                                │
│ • BASELINE_CALIBRATION                                               │
│ • OPTIMAL_PERFORMANCE (85-90 FPS)                                    │
│ • PERFORMANCE_DROP (80-84 FPS)                                       │
│ • CRITICAL_MODE (<75 FPS)                                            │
│ • LOD_LEVEL_1_REDUCTION                                              │
│ • LOD_LEVEL_2_REDUCTION                                              │
│ • EMERGENCY_LOD                                                      │
│ • RECOVERY_MONITORING                                                │
│ • PERFORMANCE_STABLE                                                 │
│ • GRADUAL_QUALITY_UP                                                 │
│ • FALLBACK_MODE (End XR if unrecoverable)                            │
│                                                                      │
│ PARALLEL MONITORS:                                                   │
│ • FPS_MONITOR (every frame)                                          │
│ • MEMORY_MONITOR (every 2s)                                          │
│ • THERMAL_MONITOR (every 5s)                                         │
│                                                                      │
│ LOD LEVELS:                                                          │
│ • Level 0 (OPTIMAL): Full quality, 1024x1024 textures               │
│ • Level 1 (REDUCED): 512x512 textures, -30% polygons                │
│ • Level 2 (MINIMAL): 256x256 textures, -60% polygons                │
│ • Level 3 (EMERGENCY): 128x128 textures, billboards                 │
│                                                                      │
│ PERFORMANCE TARGETS:                                                 │
│ • Target FPS: 90                                                     │
│ • Minimum FPS: 85                                                    │
│ • Critical threshold: 75                                             │
│ • Adaptation response time: < 1 second                               │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ 3. XR Audio System Orchestration Sequence                           │
│    File: 4_8_XR_Audio_System_Sequence.mmd                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│ PURPOSE:                                                             │
│ Complete sequence diagram for spatial audio integration with        │
│ biometric-driven real-time adaptations.                             │
│                                                                      │
│ PARTICIPANTS:                                                        │
│ • User (in VR)                                                       │
│ • XRApp                                                              │
│ • AudioSystem                                                        │
│ • SpatialAudio (Web Audio API)                                       │
│ • SessionAgent (AI-generated content)                                │
│ • BiometricMonitor                                                   │
│                                                                      │
│ KEY SEQUENCES:                                                       │
│ 1. Audio System Initialization                                      │
│    • Setup Web Audio API                                             │
│    • Create spatial audio sources                                    │
│    • Position sounds in 3D space                                     │
│                                                                      │
│ 2. Ambient Environment Loading                                      │
│    • Load: ambient.mp3, rain.mp3, birds.mp3                         │
│    • Position spatially (rain above, birds distant, ambient 360°)   │
│    • Start playback                                                  │
│                                                                      │
│ 3. Hypnosis Voice Integration                                       │
│    • AI-generated script → TTS → audio file                          │
│    • Position voice source (center, 2m from user)                    │
│    • Fade ambient to 50% when voice starts                           │
│                                                                      │
│ 4. Real-Time Biometric Adaptation Loop                              │
│    • Monitor HR every 2 seconds                                      │
│    • Adjust audio parameters based on HR:                            │
│      - HR 68 bpm (Relaxing) → Continue                               │
│      - HR 85 bpm (Elevated) → Slow voice, increase rain             │
│      - HR 72 bpm (Optimal) → Maintain                                │
│                                                                      │
│ 5. Session Progression                                               │
│    • Induction → Deepening (crossfade)                               │
│    • Deepening → Suggestions (layer binaural beats at 4Hz)          │
│    • Suggestions → Emergence (fade out, restore ambient)            │
│                                                                      │
│ AUDIO SPECIFICATIONS:                                                │
│ • Spatial Audio: HRTF, Inverse distance model                        │
│ • Layers: 4 (Ambient, Environmental, Voice, Binaural)               │
│ • Adaptive Parameters: Voice rate (0.8x-1.2x), Volume (0-100%)      │
│ • Formats: MP3 (primary), WAV, OGG                                   │
│ • Performance: <50ms latency, 8 simultaneous sounds                  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ 4. Therapist Dashboard Analytics Sequence                           │
│    File: 4_9_Therapist_Dashboard_Analytics_Sequence.mmd             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│ PURPOSE:                                                             │
│ Complete workflow for therapist dashboard showing real-time         │
│ analytics and historical data visualization.                        │
│                                                                      │
│ PARTICIPANTS:                                                        │
│ • Dashboard View (React UI)                                          │
│ • Analytics API (FastAPI)                                            │
│ • TimescaleDB (Time-series biometric data)                           │
│ • Neo4j (Graph relationships)                                        │
│ • Recharts Component (Visualizations)                                │
│ • Real-time WebSocket (Live updates)                                 │
│                                                                      │
│ KEY SEQUENCES:                                                       │
│ 1. Dashboard Initial Load                                            │
│    • Query active sessions (PostgreSQL)                              │
│    • Query user progress graphs (Neo4j)                              │
│    • Query biometric time-series (TimescaleDB)                       │
│    • Render dashboard with Recharts                                  │
│                                                                      │
│ 2. Real-Time Updates                                                 │
│    • Subscribe to WebSocket for active sessions                      │
│    • Receive updates every 5 seconds                                 │
│    • Update UI indicators (heart rate, progress, etc.)               │
│                                                                      │
│ 3. User Detail View                                                  │
│    • Complex time-series queries (7-day HR trend)                    │
│    • Graph traversals (session relationships)                        │
│    • Recharts data transformation                                    │
│    • Render interactive charts                                       │
│                                                                      │
│ 4. Live Session Monitoring                                           │
│    • Real-time biometric updates                                     │
│    • Dynamic chart updates                                           │
│    • Alert notifications                                             │
│                                                                      │
│ 5. Session Completion                                                │
│    • Store analytics (TimescaleDB + Neo4j)                           │
│    • Update dashboard                                                │
│    • Show success notification                                       │
│                                                                      │
│ VISUALIZATIONS:                                                      │
│ • LineChart: Heart rate trends                                       │
│ • BarChart: Session counts by environment                            │
│ • PieChart: Goal distribution                                        │
│ • AreaChart: Cumulative progress                                     │
│ • Real-time indicators: Current HR, progress bars                    │
│                                                                      │
│ PERFORMANCE TARGETS:                                                 │
│ • Dashboard load: < 2 seconds                                        │
│ • Real-time update latency: < 100ms                                  │
│ • Chart render: < 500ms                                              │
│ • Concurrent therapists: 50+                                         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ 5. Real-Time Session Delivery with Biometric Integration            │
│    File: 4_10_Real_Time_Session_Delivery_Biometric_Sequence.mmd     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│ PURPOSE:                                                             │
│ End-to-end sequence showing how biometric data drives real-time     │
│ audio adaptation during therapeutic sessions.                       │
│                                                                      │
│ PARTICIPANTS:                                                        │
│ • User (in VR)                                                       │
│ • SessionUI                                                          │
│ • BiometricAPI (Quest 3 HR sensor)                                   │
│ • AdaptationEngine (Decision logic)                                  │
│ • AudioSystem (Spatial audio)                                        │
│ • SafetyMonitor (Always-on guardian)                                 │
│                                                                      │
│ KEY SEQUENCES:                                                       │
│ 1. Session Initialization                                            │
│    • Request biometric permissions                                   │
│    • Connect to Quest 3 built-in HR sensor                           │
│    • Baseline calibration (30 seconds)                               │
│    • Set adaptation thresholds                                       │
│                                                                      │
│ 2. Session Start                                                     │
│    • Load session audio (induction, deepening, suggestions)          │
│    • Register with SafetyMonitor                                     │
│    • Begin biometric streaming (every 2s)                            │
│                                                                      │
│ 3. Real-Time Biometric Feedback Loop                                 │
│    CYCLE (every 2 seconds):                                          │
│    a) Stream biometrics (HR, HRV, Resp, GSR)                         │
│    b) AdaptationEngine analyzes:                                     │
│       • Compare to baseline                                          │
│       • Detect trends                                                │
│       • Calculate stress index                                       │
│    c) Make adaptation decision:                                      │
│       • HR 78 bpm (elevated) → Slow voice 5%, +rain 10%              │
│       • HR 72 bpm (improved) → Maintain                              │
│       • HR 68 bpm (optimal) → Progress to next phase                 │
│    d) SafetyMonitor forwards data, checks for alerts                 │
│                                                                      │
│ 4. Safety Alert Handling                                             │
│    • HR 90 bpm (sudden spike) → ALERT                                │
│    • Pause session immediately                                       │
│    • Fade audio                                                      │
│    • Comfort check: "Are you OK?"                                    │
│    • User confirms → Resume with gentler parameters                  │
│    • Log incident                                                    │
│                                                                      │
│ 5. Session Completion                                                │
│    • Emergence protocol                                              │
│    • Final biometric reading                                         │
│    • Calculate effectiveness score                                   │
│    • Display session summary                                         │
│                                                                      │
│ BIOMETRIC ZONES:                                                     │
│ • Optimal (60-70 bpm) → No adjustment                                │
│ • Slightly Elevated (71-80 bpm) → Minor adjustments                  │
│ • Elevated (81-90 bpm) → Significant adjustments + UI alert          │
│ • Critical High (>90 bpm) → Pause session                            │
│ • Critical Low (<55 bpm) → Monitor (may be deep trance)              │
│                                                                      │
│ ADAPTATION ACTIONS:                                                  │
│ • Voice rate adjustment: 0.8x - 1.2x                                 │
│ • Ambient volume: 0-100%                                             │
│ • Content intensity: Light/Medium/Deep                               │
│ • Suggestion directness: Permissive/Authoritarian                    │
│                                                                      │
│ SAFETY PROTOCOLS:                                                    │
│ • Auto-pause if HR change >20 bpm in 30s                             │
│ • Alert therapist on repeated distress                               │
│ • Emergency stop button                                              │
│ • Max session: 45 minutes                                            │
│ • Mandatory 5-minute emergence                                       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ 6. Environment Switching & Scene Management                          │
│    File: 4_11_Environment_Switching_Scene_Management.mmd             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│ PURPOSE:                                                             │
│ Detailed state machine for managing three VR environments and       │
│ transitions between them.                                           │
│                                                                      │
│ ENVIRONMENTS:                                                        │
│ 1. 🏠 Soft Lit Room (Default)                                       │
│    • Warm lighting, comfortable chair, gentle ambient               │
│    • Best for: First sessions, anxious users, focus work            │
│    • Performance: 88-90 FPS, 45 draw calls, 55% GPU                 │
│    • Assets: 8,000 polygons, 6 textures                             │
│    • Memory: ~45 MB                                                  │
│                                                                      │
│ 2. 🌲 Nature Scene                                                   │
│    • Forest, stream, birds, wind rustling                            │
│    • Best for: Nature lovers, stress relief, grounding              │
│    • Performance: 86-89 FPS, 78 draw calls, 68% GPU                 │
│    • Assets: 25,000 polygons (with LOD), 12 textures                │
│    • Memory: ~85 MB                                                  │
│                                                                      │
│ 3. ☁️ Floating Platform                                             │
│    • Clouds, open sky, ethereal music, floating feeling             │
│    • Best for: Deep trance, spiritual work, advanced users          │
│    • Performance: 87-90 FPS, 52 draw calls, 60% GPU                 │
│    • Assets: 12,000 polygons, 8 textures                            │
│    • Memory: ~65 MB                                                  │
│                                                                      │
│ TRANSITION PHASES:                                                   │
│ 1. FADE_OUT (2 seconds)                                              │
│    • Screen dims to black                                            │
│    • Audio fades to 20%                                              │
│                                                                      │
│ 2. UNLOAD_CURRENT (0.5 seconds)                                      │
│    • Dispose geometries                                              │
│    • Clear textures                                                  │
│    • Release audio                                                   │
│    • Run garbage collection                                          │
│                                                                      │
│ 3. PRELOAD_NEXT (2 seconds)                                          │
│    • Load new environment assets                                     │
│    • Apply appropriate LOD                                           │
│    • Initialize audio sources                                        │
│                                                                      │
│ 4. RENDER (0.5 seconds)                                              │
│    • Instantiate scene                                               │
│    • Position user                                                   │
│    • Setup lighting                                                  │
│                                                                      │
│ 5. FADE_IN (2 seconds)                                               │
│    • Screen brightens                                                │
│    • Audio fades to 100%                                             │
│                                                                      │
│ TOTAL TRANSITION TIME: ~7 seconds                                    │
│                                                                      │
│ OPTIMIZATION STRATEGIES:                                             │
│ • Progressive loading (critical assets first)                        │
│ • Asset caching (last 2 environments in memory)                      │
│ • LOD management (distance-based)                                    │
│ • Texture optimization (basis universal, mipmaps)                    │
│ • Audio preloading                                                   │
│ • Manual GC during transitions                                       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ 7. v4.0 System Integration Architecture                             │
│    File: 4_12_v4_System_Integration_Architecture.mmd                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│ PURPOSE:                                                             │
│ Comprehensive overview of the entire v4.0 platform architecture     │
│ showing how all components integrate.                               │
│                                                                      │
│ LAYERS:                                                              │
│                                                                      │
│ 1. FRONTEND LAYER                                                    │
│    • Desktop Web App (React + Tailwind)                              │
│      - Dashboard UI, Assessment forms, Session controls              │
│      - Analytics charts (Recharts)                                   │
│    • WebXR VR App (React Three Fiber)                                │
│      - 3D Environments (Soft Room, Nature, Floating)                 │
│      - XR Controllers, Hand Tracking                                 │
│      - Spatial Audio, Performance Monitor                            │
│    • State Management (Zustand)                                      │
│      - xr.store, session.store, user.store, biometric.store         │
│                                                                      │
│ 2. API GATEWAY LAYER                                                 │
│    • FastAPI Backend Services                                        │
│      - Auth, User, Session, Analytics, XR Asset, Biometric           │
│    • Real-Time WebSocket Manager                                     │
│      - Active session monitoring                                     │
│      - Biometric streaming                                           │
│      - Safety alerts                                                 │
│      - Dashboard updates                                             │
│                                                                      │
│ 3. DATA LAYER                                                        │
│    • PostgreSQL (Primary Data)                                       │
│      - Users, Sessions, Profiles, Goals, Assessments                 │
│    • TimescaleDB (Time-Series)                                       │
│      - Biometric data (HR, HRV, Respiration, GSR)                    │
│      - Performance metrics, Session events                           │
│    • Neo4j (Graph Data)                                              │
│      - User graph, Session relationships                             │
│      - Environment preferences, Progress paths                       │
│    • Redis (Cache)                                                   │
│      - Session state, User tokens, Rate limits                       │
│    • Qdrant (Vector Store)                                           │
│      - Script vectors, PDF embeddings (4000+ chunks)                 │
│    • MinIO/S3 (File Storage)                                         │
│      - Audio files, 3D models, Textures                              │
│                                                                      │
│ 4. AI AGENT ORCHESTRATION LAYER                                      │
│    • CrewAI + AutoGen Multi-Agent System                             │
│      - SessionPlanner, SafetyOverseer, RAGRetriever                  │
│      - InductionComposer, DeepeningArchitect, SuggestionCrafter     │
│      - EmergenceProtocol                                             │
│    • Jungian Integration Agents (Future)                             │
│      - Shadow Recognition, Anima/Animus, Complex Analysis            │
│      - Dialectical Synthesis, Individuation, Somatic, Mythological   │
│    • MCP Servers                                                     │
│      - HMI Protocol Retrieval, Clinical Guidelines                   │
│      - Safety Validation, Personalization (E&P, Suggestibility)      │
│                                                                      │
│ 5. LLM INFRASTRUCTURE                                                │
│    • Claude Sonnet 4.5 (Primary)                                     │
│    • GPT-4 (Backup/Fallback)                                         │
│    • Custom Fine-Tuned Models (Future)                               │
│                                                                      │
│ DATA FLOW (Session Lifecycle):                                       │
│ User → Device Detection → XR Init → Biometric Calibration →         │
│ AI Agents → Session Plan → Multi-Agent Generation → Safety          │
│ Validation → Real-Time Delivery (WebXR + Audio + Biometrics) →      │
│ Adaptation Loop → Completion → Data Storage → Dashboard Update      │
│                                                                      │
│ KEY INTEGRATION POINTS:                                              │
│ 1. WebXR ↔ Biometric (Quest 3 HR → real-time streaming)             │
│ 2. AI Agents ↔ Vector Store (RAG with 4000+ chunks)                 │
│ 3. Performance ↔ LOD (FPS → dynamic quality)                         │
│ 4. Safety ↔ All Layers (multi-level guardrails)                     │
│ 5. Dashboard ↔ Time-Series DB (Recharts + WebSocket)                │
│ 6. Audio ↔ XR (Spatial audio + biometric adaptations)               │
│                                                                      │
│ PERFORMANCE TARGETS:                                                 │
│ • Frontend (WebXR): 85-90 FPS, <11ms frame time                      │
│ • Backend (API): <200ms response (p95), <100ms WebSocket            │
│ • AI Generation: <15s per segment                                    │
│ • Database: <50ms queries                                            │
│ • System: 1000+ concurrent users, 50 simultaneous sessions           │
│                                                                      │
│ SECURITY & COMPLIANCE:                                               │
│ • HIPAA-compliant data storage                                       │
│ • End-to-end encryption (TLS 1.3)                                    │
│ • User consent management                                            │
│ • Clinical safety protocols                                          │
│ • Audit logging                                                      │
│ • PHI protection                                                     │
│ • RBAC (Role-Based Access Control)                                   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘


DIAGRAM USAGE GUIDE:
═══════════════════════════════════════════════════════════════════════

DEVELOPMENT REFERENCE:
─────────────────────────────────────────────────────────────
Use these diagrams to:
• Understand system architecture and data flow
• Implement state machines in code
• Design API contracts between components
• Set up monitoring and performance targets
• Implement safety protocols and error handling

DOCUMENTATION:
─────────────────────────────────────────────────────────────
• Include in technical documentation
• Use for onboarding new developers
• Reference during code reviews
• Present to stakeholders

PROJECT PLANNING:
─────────────────────────────────────────────────────────────
• Sprint planning and task breakdown
• Identify dependencies between components
• Estimate complexity and effort
• Define testing scenarios

COMPLIANCE & AUDIT:
─────────────────────────────────────────────────────────────
• Demonstrate safety protocols for clinical review
• Show data flow for HIPAA compliance
• Document error handling and recovery
• Prove biometric data protection


NEXT STEPS:
═══════════════════════════════════════════════════════════════════════

1. Review all diagrams for accuracy and completeness
2. Identify any missing workflows or edge cases
3. Implement state machines in code (React, Python)
4. Create automated tests based on state transitions
5. Set up monitoring dashboards based on performance targets
6. Document API endpoints based on sequence diagrams
7. Implement safety protocols exactly as specified


DIAGRAM CONVENTIONS:
═══════════════════════════════════════════════════════════════════════

NOTATION:
─────────────────────────────────────────────────────────────
╔═══╗  Main states (double-line boxes)
║   ║  
╚═══╝

┌───┐  Sub-states, phases, or details (single-line boxes)
│   │
└───┘

  →   State transition
  │   Flow or connection
 [condition]  Transition condition
 / action  Action on transition
 ••  Concurrent/parallel states

ABBREVIATIONS:
─────────────────────────────────────────────────────────────
HR   - Heart Rate
HRV  - Heart Rate Variability
GSR  - Galvanic Skin Response
FPS  - Frames Per Second
LOD  - Level of Detail
TTS  - Text-to-Speech
RAG  - Retrieval-Augmented Generation
MCP  - Model Context Protocol
XR   - Extended Reality (VR/AR)
E&P  - Emotional & Physical (sexuality assessment)
HRTF - Head-Related Transfer Function (spatial audio)


VERSION HISTORY:
═══════════════════════════════════════════════════════════════════════

v4.0 - November 2025
─────────────────────────────────────────────────────────────
ADDED:
• WebXR Session Lifecycle State Machine
• Performance & LOD Management State Machine  
• XR Audio System Orchestration Sequence
• Therapist Dashboard Analytics Sequence
• Real-Time Session Delivery with Biometric Integration
• Environment Switching & Scene Management
• v4.0 System Integration Architecture

EXISTING (From previous versions):
• Multi-Agent Collaboration State Machine
• Real-Time Biometric Adaptation
• Safety Monitoring State Machine
• User Journey State Machine (Macro-Level)
• Assessment Flow
• First Session Complete E2E Flow
• Suggestibility Questionnaire
• Safety Escalation
• Session Orchestration State Machine


CONTACT & SUPPORT:
═══════════════════════════════════════════════════════════════════════

Project: HMI Hypnotherapy Platform (Jeeth.ai)
Developer: Jithendran Sellamuthu
Tech Stack: React 18.2.0, Three.js, FastAPI, PostgreSQL, Neo4j, 
            TimescaleDB, Qdrant, CrewAI, AutoGen, Claude Sonnet 4.5
Target Device: Meta Quest 3
Focus: Clinical hypnotherapy with depth psychology integration

For questions about these diagrams or the v4.0 architecture,
refer to the comprehensive project documentation or raise issues
in the project repository.


═══════════════════════════════════════════════════════════════════════
                     END OF DIAGRAM SUMMARY
═══════════════════════════════════════════════════════════════════════
