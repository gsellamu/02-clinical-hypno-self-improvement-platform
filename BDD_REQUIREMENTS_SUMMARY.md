# BDD Requirements Summary
## Therapeutic Journaling Platform - Hypno Resilient Mind 12

**Generated:** 2026-02-11
**Project:** Clinical VR Journaling Platform
**Format:** Gherkin BDD Test Scenarios

---

## Overview

This repository contains **8 comprehensive feature files** with **120+ BDD scenarios** covering all aspects of the Therapeutic Journaling Platform, following strict Test-Driven Development (TDD) and Behavior-Driven Development (BDD) principles.

---

## Feature Files Summary

### 01. Safety Guardian (18 scenarios)
**Purpose:** First-line safety screening for crisis detection and intervention

**Critical Scenarios:**
- Immediate self-harm triggers Code Red (< 500ms response)
- Trauma disclosure activates Safety Guardian constraints
- Multi-signal crisis detection with escalation chain
- Region-specific crisis resources (988, Crisis Text Line, etc.)
- Privacy-preserving crisis logs (hashed inputs)

**Tags:** `@critical`, `@safety`, `@yellow`, `@red`, `@green`, `@monitoring`, `@performance`

---

### 02. Session Management (13 scenarios)
**Purpose:** Journaling session lifecycle, state management, multi-modal support

**Critical Scenarios:**
- Intake classification (goal/intensity/readiness/contraindications)
- State transitions: created → intake → safety → active → reflecting → completed
- Session timeout with auto-save and resumption
- Web-to-VR modality switching with context transfer
- Session export to PDF with MinIO storage
- HITL flagging for clinical review

**Tags:** `@session`, `@intake`, `@resume`, `@state`, `@timeout`, `@multi-modal`, `@analytics`

---

### 03. Journaling Exercises (18 scenarios)
**Purpose:** Core therapeutic modalities from workbooks

**Modalities Covered:**
- Sprint journaling (10-min timebox)
- Unsent letter (encrypted storage)
- Sentence stems (8-10 prompts)
- List-of-100 (exhaustive exploration)
- Non-dominant hand (canvas capture)
- Written dialogue (inner parts)
- Inventory (4 life categories)
- Springboard prompts (multiple angles)

**Critical Features:**
- Post-exercise reflection with theme extraction
- Adaptive difficulty based on user energy
- Grounding closure (3 breaths, 5-4-3-2-1, body scan)
- Voice-to-text accessibility
- High-sensitivity encryption

**Tags:** `@exercise`, `@sprint`, `@unsent-letter`, `@sentence-stems`, `@reflection`, `@privacy`

---

### 04. XR/VR Integration (15 scenarios)
**Purpose:** Immersive WebXR journaling with Quest 3 support

**Critical Scenarios:**
- Environment selection (cozy cabin, forest clearing, beach sunset)
- Spatial audio with HRTF rendering
- Bilateral drawing with mirrored canvases
- Gaze-based UI interaction (1.5s dwell time)
- Cinematic camera rails for Six-Phase Meditation
- Hand tracking for volumetric writing
- Desktop fallback with R3F (mouse-controlled orbit)
- 72fps minimum performance requirement
- Seated mode accessibility
- Safe VR exit with grounding

**Tags:** `@xr`, `@environment`, `@spatial-audio`, `@bilateral-drawing`, `@cinematic-mode`, `@performance`

---

### 05. Agent Orchestration (18 scenarios)
**Purpose:** LangGraph multi-agent workflow coordination

**8-Agent Workflow:**
1. Safety Guardian (first-run gatekeeper)
2. Intake & Triage (classification)
3. Journaling Coach (technique selection)
4. XR Scene Director (environment spec)
5. Content Producer (narration + TTS + prompts)
6. Somatic Regulator (grounding options)
7. Reflection Summarizer (themes + next steps)
8. RAG Librarian (workbook guidance)

**Critical Features:**
- Sequential execution with conditional branching
- Parallel execution (Content Producer + Somatic Regulator)
- Intelligent retry with exponential backoff
- MCP tool layer integration (rag_retrieve, create_session_plan, etc.)
- Workflow state persistence and checkpoint resume
- Cost tracking (tokens, LLM calls, USD)
- Graceful degradation with fallback
- Agent versioning (canary deployment)
- Observability traces (OpenTelemetry)
- Eval scoring with rubrics

**Tags:** `@orchestration`, `@workflow`, `@safety-first`, `@conditional`, `@parallel`, `@mcp-tools`

---

### 06. Crisis Handling (15 scenarios)
**Purpose:** Emergency protocols and crisis response

**Critical Scenarios:**
- Multi-signal crisis detection (ideation + behavioral + sentiment)
- Vetted crisis response templates (localized)
- Region-specific hotline lookup (988, Samaritans, etc.)
- Escalation chain (log → HITL → Slack → email → ticket)
- Post-crisis monitoring and follow-up
- Blackout period (24hr advanced feature lockout)
- Privacy-preserving logs (hashed inputs, no plaintext)
- Sentiment trend tracking (5-session decline)
- Multi-language crisis resources
- Emergency contact with user consent (911 integration)
- Clinician handoff for live support

**Tags:** `@crisis`, `@detection`, `@response-templates`, `@escalation-chain`, `@data-privacy`

---

### 07. HITL Review (15 scenarios)
**Purpose:** Expert clinician oversight and quality assurance

**Critical Scenarios:**
- Safety Yellow triggers HITL review (24hr SLA)
- Prioritized review queue (crisis > deadline > risk)
- Clinician actions: approve/edit/reject/escalate/contact
- Feedback loop for AI model improvement
- Code Red urgent bypass (5min acknowledgment)
- User data anonymization for reviewers
- Batch review for longitudinal trends
- Junior clinician training mode with senior countersign
- SLA tracking (urgent: 2hr, medium: 24hr)
- Complete audit trail for compliance
- Capacity management alerts

**Tags:** `@hitl`, `@escalation`, `@review-queue`, `@feedback-loop`, `@anonymization`, `@sla-tracking`

---

### 08. Performance & Monitoring (15 scenarios)
**Purpose:** 99.9% uptime, observability, and compliance

**Critical Metrics:**
- **Latency:** E2E < 3.5s (Safety: 300ms, Coach: 800ms, Producer: 1.2s)
- **Throughput:** 1000 concurrent users with < 2s avg response time
- **Database:** Queries < 50ms with proper indexing
- **Caching:** Redis hit rate > 85%
- **Uptime:** 99.9% target with health checks every 30s
- **Error Rate:** < 0.1% baseline
- **Cost Tracking:** Per-service AWS breakdown + optimization opportunities

**Monitoring Stack:**
- Prometheus + Grafana + Datadog
- OpenTelemetry distributed tracing
- ELK log aggregation (90-day retention)
- PagerDuty alerting with runbook links

**Compliance:**
- HIPAA/GDPR dashboard
- Encryption at rest/in transit
- Access audit logs
- 90-day data retention
- GDPR right-to-deletion API

**Tags:** `@performance`, `@latency`, `@throughput`, `@monitoring`, `@security`, `@compliance`

---

## Scenario Statistics

| Feature File              | Scenarios | Critical (@critical) | Tags Count |
|---------------------------|-----------|----------------------|------------|
| 01-safety-guardian        | 18        | 3                    | 12         |
| 02-session-management     | 13        | 0                    | 10         |
| 03-journaling-exercises   | 18        | 0                    | 14         |
| 04-xr-vr-integration      | 15        | 0                    | 12         |
| 05-agent-orchestration    | 18        | 0                    | 11         |
| 06-crisis-handling        | 15        | 0                    | 10         |
| 07-hitl-review            | 15        | 0                    | 8          |
| 08-performance-monitoring | 15        | 0                    | 10         |
| **TOTAL**                 | **127**   | **3**                | **87**     |

---

## Test Execution Priority

### Phase 1: Foundation (Week 1-2)
1. **Safety Guardian** (18 scenarios) - CRITICAL PATH
2. **Session Management** (13 scenarios)
3. **Agent Orchestration** (18 scenarios)

**Goal:** Core safety + session flow + agent coordination

---

### Phase 2: Core Features (Week 3-4)
4. **Journaling Exercises** (18 scenarios)
5. **Crisis Handling** (15 scenarios)

**Goal:** Therapeutic modalities + emergency protocols

---

### Phase 3: Advanced Features (Week 5-6)
6. **XR/VR Integration** (15 scenarios)
7. **HITL Review** (15 scenarios)

**Goal:** Immersive experiences + clinical oversight

---

### Phase 4: Production Readiness (Week 7-8)
8. **Performance & Monitoring** (15 scenarios)

**Goal:** 99.9% uptime + observability + compliance

---

## Test Automation Framework

**Recommended Stack:**
- **BDD Framework:** Behave (Python) or Cucumber (Node.js)
- **API Testing:** pytest + requests / Jest + supertest
- **E2E Testing:** Playwright (web) + WebXR emulator
- **Performance:** k6 or Locust
- **CI/CD:** GitHub Actions with test reports

**Test Coverage Targets:**
- Unit Tests: 80%+
- Integration Tests: 70%+
- E2E Tests: 60%+
- BDD Scenarios: 100% (all 127 scenarios)

---

## Next Steps (SDLC)

### ✅ Phase 1: Requirements (COMPLETE)
- BDD scenarios in Gherkin ✓
- Test cases covering all user stories ✓
- Acceptance criteria defined ✓

### 🔄 Phase 2: Architecture (IN PROGRESS)
- [ ] System architecture diagram (C4 model)
- [ ] Database schema design
- [ ] API specifications (OpenAPI 3.0)
- [ ] Tech stack finalization
- [ ] Security architecture

### 📋 Phase 3: Design (UPCOMING)
- [ ] UI/UX mockups (Figma)
- [ ] Component library design
- [ ] XR environment prototypes
- [ ] Agent prompt registry
- [ ] MCP tool specifications

### 🧪 Phase 4: Testing (UPCOMING)
- [ ] Test automation setup
- [ ] Unit test implementation
- [ ] Integration test implementation
- [ ] E2E test implementation
- [ ] Performance test baseline

### 🚀 Phase 5: Deploy (UPCOMING)
- [ ] Infrastructure as Code (Terraform)
- [ ] CI/CD pipeline setup
- [ ] Staging environment
- [ ] Production deployment
- [ ] Blue-green deployment strategy

### 🔁 Phase 6: Feedback (UPCOMING)
- [ ] User acceptance testing
- [ ] Beta program
- [ ] Analytics integration
- [ ] A/B testing framework

### 🔧 Phase 7: Refine (UPCOMING)
- [ ] Bug fixes based on feedback
- [ ] Performance optimizations
- [ ] Feature enhancements
- [ ] UX improvements

### 📊 Phase 8: Monitor (UPCOMING)
- [ ] Production monitoring dashboards
- [ ] Alerting rules configuration
- [ ] SLA tracking
- [ ] Cost optimization

---

## BDD Execution Commands

```bash
# Run all scenarios
behave features/

# Run critical safety scenarios only
behave features/01-safety-guardian.feature --tags=@critical

# Run specific feature
behave features/03-journaling-exercises.feature

# Run with parallel execution
behave features/ --processes 4

# Generate HTML report
behave features/ --format=html --outfile=reports/bdd_report.html

# Run smoke tests (fast scenarios)
behave features/ --tags=@smoke

# Skip slow scenarios
behave features/ --tags=-@slow
```

---

## References

**Workbooks:**
- Therapeutic Journaling 1-4 Workbooks (Jithendran Sellamuthu)
- HMI Practicum Scripts Workbook
- PSR Scripts

**Standards:**
- BDD: https://cucumber.io/docs/bdd/
- Gherkin: https://cucumber.io/docs/gherkin/reference/
- HIPAA Compliance: https://www.hhs.gov/hipaa
- GDPR: https://gdpr.eu/

**Tools:**
- Behave: https://behave.readthedocs.io/
- Playwright: https://playwright.dev/
- OpenTelemetry: https://opentelemetry.io/

---

**Document Version:** 1.0
**Last Updated:** 2026-02-11
**Author:** Claude Sonnet 4.5 (AI Architect)
