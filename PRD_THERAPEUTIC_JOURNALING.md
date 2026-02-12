# Product Requirements Document (PRD)
## Therapeutic Journaling Platform - Hypno Resilient Mind 12

**Version:** 1.0
**Date:** 2026-02-11
**Status:** Phase 3 - Product Definition
**Owner:** Jithendran Sellamuthu, Product Lead

---

## 1. OVERVIEW

### 1.1 Vision Statement
Transform 1 billion lives by 2035 through AI-powered therapeutic journaling that makes deep self-reflection accessible, safe, and clinically sound.

### 1.2 Mission
Provide compassionate, evidence-based journaling support guided by clinical hypnotherapy principles (HMI methodology), offering wellness coaching through immersive experiences while maintaining the highest safety and privacy standards.

### 1.3 Problem Statement
**Current State:**
- Traditional therapy is expensive ($150-300/session), inaccessible (waitlists), and stigmatized
- Self-help journaling lacks structure, guidance, and clinical validation
- Generic apps don't adapt to user psychology (E&P profiles)
- No immersive experiences leverage VR for deeper presence
- Crisis detection is absent in consumer wellness apps

**Impact:**
- 45% of US adults report anxiety/depression (APA, 2024)
- Only 20% access mental health services (insurance, cost, availability)
- 60% abandon journaling within 2 weeks (lack of structure)
- 0 consumer apps have clinical oversight (HITL review)

### 1.4 Solution
AI-powered therapeutic journaling platform with:
- **8 evidence-based journaling modalities** from therapeutic workbooks
- **HMI-aligned E&P adaptation** (Physical vs Emotional suggestibility)
- **Immersive VR experiences** (Quest 3) for deeper presence
- **Safety-first architecture** (Code Red/Yellow/Green crisis detection)
- **Clinical oversight** (HITL review by licensed therapists)
- **Privacy-preserving** (HIPAA/GDPR compliant, encrypted)

### 1.5 Success Metrics (North Star)
**Primary KPI:** Lives Transformed (Monthly Active Users × Completion Rate × Avg Sentiment Improvement)

**Target (Month 3):** 1,000 MAU × 90% completion × +0.35 sentiment = **315 lives/month**

---

## 2. TARGET PERSONAS

### Persona 1: Sarah - The Overwhelmed Professional
**Demographics:**
- Age: 32
- Occupation: Marketing Manager
- Location: Urban (San Francisco)
- Income: $85k/year
- Tech Savvy: High

**Psychographics:**
- Experiencing career burnout
- Relationship stress with partner
- Former therapy client (can't afford ongoing)
- Journals sporadically (inconsistent)
- Values privacy, evidence-based approaches

**Pain Points:**
- "I start journaling but don't know what to write"
- "Therapy waitlists are 3+ months"
- "I need something between self-help and therapy"
- "I want structure without feeling judged"

**Goals:**
- Process work stress without it affecting relationship
- Build consistent self-reflection habit
- Gain clarity on career decisions
- Reduce anxiety symptoms

**E&P Profile:** Emotional (70% E, 30% P)
**Preferred Modality:** Web + Mobile
**Techniques:** Unsent letter, dialogue, sentence stems

---

### Persona 2: Marcus - The Introspective Seeker
**Demographics:**
- Age: 45
- Occupation: Software Engineer
- Location: Remote (Colorado)
- Income: $120k/year
- Tech Savvy: Very High

**Psychographics:**
- Meditates daily (10 years)
- Reads philosophy (Stoicism, Buddhism)
- Interested in consciousness exploration
- Has VR headset (Quest 3)
- Values innovation, depth

**Pain Points:**
- "Generic meditation apps feel shallow"
- "I want deeper self-inquiry tools"
- "Traditional journaling feels 2D"
- "I need something that goes beyond mindfulness"

**Goals:**
- Explore shadow work (inner critic, inner child)
- Experience immersive introspection (VR)
- Integrate spiritual practice with psychology
- Achieve self-actualization

**E&P Profile:** Physical (65% P, 35% E)
**Preferred Modality:** VR + Desktop
**Techniques:** Six-phase meditation, bilateral drawing, list-of-100

---

### Persona 3: Dr. Lisa - The Clinician
**Demographics:**
- Age: 52
- Occupation: Licensed Clinical Social Worker (LCSW)
- Location: Private Practice (Boston)
- Income: $90k/year
- Tech Savvy: Medium

**Psychographics:**
- 20+ years clinical experience
- Assigns journaling homework to clients
- Frustrated by lack of compliance
- Interested in augmenting therapy (not replacing)
- Values evidence, ethics, safety

**Pain Points:**
- "Clients don't complete journaling homework"
- "I can't review their journaling between sessions"
- "Generic apps don't align with clinical frameworks"
- "Safety concerns with AI-only tools"

**Goals:**
- Augment therapy with structured journaling
- Monitor client progress between sessions
- Ensure clinical quality and safety
- Improve therapy outcomes

**Role:** HITL Reviewer (not primary user)
**Preferred Modality:** Web dashboard (review queue)

---

### Anti-Persona: Alex - The Crisis Patient
**Why Not a Fit:**
- Currently experiencing severe mental health crisis
- Needs immediate professional intervention (not wellness coaching)
- Requires diagnosis and treatment (our scope: coaching only)
- May be harmed by journaling without professional support

**Platform Response:**
- Safety Guardian detects crisis (Code Red)
- Immediate resources (988, Crisis Text Line)
- Session locked, urgent HITL escalation
- Encourage professional care (not replacement)

---

## 3. JOBS-TO-BE-DONE (JTBD)

### 3.1 Core JTBD

**When** I'm feeling overwhelmed and stuck in my head,
**I want to** express my thoughts and feelings in a structured way,
**So that** I can gain clarity, process emotions, and move forward.

**Sub-Jobs:**
1. **Process difficult emotions** without judgment
2. **Gain insight into patterns** I wasn't aware of
3. **Explore inner conflicts** (critic vs wisdom)
4. **Set meaningful goals** aligned with values
5. **Track progress** over time
6. **Feel heard and validated** (even by AI)
7. **Access support** when I'm struggling (but not in crisis)

### 3.2 Related Jobs

**When** I'm trying to make an important decision,
**I want to** explore multiple perspectives and clarify my values,
**So that** I can choose with confidence.

**When** I'm in conflict with someone,
**I want to** express what I wish I could say,
**So that** I can process feelings without escalating the situation.

**When** I'm feeling disconnected from myself,
**I want to** reconnect with my inner wisdom,
**So that** I can feel grounded and authentic.

---

## 4. USER FLOWS

### 4.1 Core Flow: First Journaling Session (Sarah)

```
1. Sign Up & Consent
   ├─ Email/password or SSO
   ├─ Accept Terms & Privacy Policy
   └─ Consent to data processing

2. Intake Assessment (Intake & Triage Agent)
   ├─ "What brings you here today?"
   ├─ Goal category: Relationships
   ├─ Intensity: 3/5
   └─ SessionIntent created

3. Safety Screening (Safety Guardian)
   ├─ Analyze input for crisis signals
   ├─ Status: Green ✓
   └─ Proceed to journaling

4. Technique Selection (Journaling Coach)
   ├─ Recommended: "Unsent Letter"
   ├─ Rationale: "Express what you wish you could say"
   └─ Sarah accepts

5. Guided Exercise (Content Producer)
   ├─ Opening prompt: "Write a letter to your partner..."
   ├─ Timebox: 15 minutes
   ├─ Background audio: Calm piano
   └─ Sarah writes (847 words)

6. Grounding Close (Somatic Regulator)
   ├─ "Take 3 deep breaths..."
   ├─ "Notice how you feel now"
   └─ Sarah completes

7. Reflection (Reflection Summarizer)
   ├─ Themes: "desire for connection", "fear of vulnerability"
   ├─ Sentiment: +0.35 (positive shift)
   ├─ Next steps: "Consider sharing feelings with partner"
   └─ Sarah reviews summary

8. Session Complete
   ├─ Session saved (encrypted)
   ├─ Progress updated
   └─ Notification: "Great work today!"

Exit Point: Sarah feels heard, gains clarity, books next session.
```

**Success Criteria:**
- Session completed: Yes
- Time to complete: 32 minutes
- User satisfaction: 4.6/5
- Next session scheduled: Within 7 days

---

### 4.2 Advanced Flow: VR Immersive Session (Marcus)

```
1. Launch VR Mode (Quest 3)
   ├─ Select environment: "Forest Clearing"
   ├─ XR Scene Director generates spec
   └─ Environment loads (3D + spatial audio)

2. Six-Phase Meditation (Cinematic Mode)
   ├─ Phase 1: Compassion (camera orbits slowly)
   ├─ Phase 2: Gratitude (environment reveals beauty)
   ├─ Phase 3: Forgiveness (close intimate focus)
   ├─ Phase 4: Vision (expansive horizon pull)
   ├─ Phase 5: Perfect Day (smooth journey)
   ├─ Phase 6: Blessings (return to center)
   └─ 18 minutes total

3. Bilateral Drawing Exercise
   ├─ Dual canvases appear (L/R)
   ├─ Hand tracking enabled
   ├─ Marcus draws with both hands simultaneously
   ├─ Symmetry creates mandala-like pattern
   └─ 12 minutes

4. VR Session Recording (Optional)
   ├─ Marcus enables recording
   ├─ 360° video captured
   └─ Stored in MinIO for later review

5. Exit VR Gracefully
   ├─ Somatic Regulator: Transition grounding
   ├─ Environment gradually brightens
   ├─ "Remove headset slowly"
   └─ Session summary available in 2D

Exit Point: Marcus feels deeply present, achieved flow state.
```

**Success Criteria:**
- VR session completed: Yes
- Frame rate: 72+ fps sustained
- Motion sickness: 0 (no reports)
- User satisfaction: 5/5
- Next VR session: Within 3 days

---

### 4.3 Safety Flow: Crisis Detection (Anti-Persona)

```
1. User Input Contains Crisis Signal
   ├─ "I want to end it all"
   └─ Safety Guardian analyzes

2. Crisis Detection (Code Red)
   ├─ Multi-signal validation
   ├─ Crisis level: Severe
   └─ Status: RED

3. Immediate Response (< 500ms)
   ├─ Crisis template: CRISIS_SUICIDAL_IDEATION_v3
   ├─ Resources: 988, Crisis Text Line, 911
   ├─ Message: "Your safety is the priority..."
   └─ NO journaling exercises offered

4. Escalation Chain
   ├─ Log to crisis_logs (hashed input)
   ├─ Create urgent HITL escalation
   ├─ Notify on-call clinician (Slack)
   ├─ Email safety team
   └─ Create incident ticket

5. Session Locked
   ├─ User cannot proceed with journaling
   ├─ Advanced features disabled (24hr blackout)
   └─ Supportive holding message displayed

6. HITL Follow-Up
   ├─ Clinician reviews within 2 hours
   ├─ Determines next steps
   └─ User contacted if appropriate

Exit Point: User receives immediate help, platform prevents harm.
```

**Success Criteria:**
- Crisis detected: Yes (< 500ms)
- Resources provided: Yes
- HITL notified: Yes (< 2 min)
- User outcome: Safe (followed up)

---

## 5. FEATURE SPECIFICATIONS

### 5.1 MVP Features (Month 1-2)

#### F1: User Authentication & Onboarding
**Description:** Secure sign-up, consent management, intake assessment

**User Stories:**
- As a new user, I want to create an account securely so that my data is protected
- As a returning user, I want to log in quickly so that I can resume journaling
- As a user, I want to complete intake assessment so that recommendations are personalized

**Acceptance Criteria:**
- OAuth 2.0 + JWT implementation
- Email/password + SSO (Google, Apple)
- HIPAA-compliant consent forms
- Intake completes in < 5 minutes
- SessionIntent created with goal/intensity/readiness

**Priority:** P0 (Critical Path)
**Effort:** 13 story points

---

#### F2: Safety Guardian (Crisis Detection)
**Description:** First-line safety screening on every user input

**User Stories:**
- As the platform, I want to detect crisis signals so that users get immediate help
- As a user in crisis, I want immediate resources so that I can get professional support
- As a clinician, I want urgent escalations so that I can intervene quickly

**Acceptance Criteria:**
- Code Red/Yellow/Green classification
- Multi-signal detection (ideation + behavioral + sentiment)
- Response time < 300ms
- Crisis resources localized to user's region
- Privacy-preserving logs (SHA-256 hashed)
- Escalation chain executes automatically

**Priority:** P0 (Safety Critical)
**Effort:** 21 story points

---

#### F3: Core Journaling Exercises (4 Modalities)
**Description:** Sprint, unsent letter, sentence stems, inventory

**User Stories:**
- As a user, I want structured journaling prompts so that I know what to write
- As a user, I want timebox guidance so that I don't get overwhelmed
- As a user, I want grounding closures so that I feel complete

**Acceptance Criteria:**
- 4 modalities implemented (sprint, unsent letter, sentence stems, inventory)
- Timebox enforcement with countdown timer
- Opening prompts + guideposts + grounding close
- Word count tracking
- Auto-save every 30 seconds
- Encrypted storage for sensitive exercises

**Priority:** P0 (Core Value)
**Effort:** 34 story points

---

#### F4: Reflection & Theme Extraction
**Description:** AI-powered post-exercise analysis

**User Stories:**
- As a user, I want to see themes in my journaling so that I gain insight
- As a user, I want sentiment tracking so that I can see progress
- As a user, I want next-step suggestions so that I know what to do next

**Acceptance Criteria:**
- Recurring themes identified (2-5 themes per session)
- Emotional tone classification
- Sentiment score (-1.0 to +1.0)
- Action items extracted
- Non-judgmental summary presentation
- User can confirm/reject themes

**Priority:** P0 (Core Value)
**Effort:** 21 story points

---

#### F5: Session Management & Progress Tracking
**Description:** Session lifecycle, state persistence, analytics

**User Stories:**
- As a user, I want to resume incomplete sessions so that I don't lose progress
- As a user, I want to see my progress over time so that I feel motivated
- As a user, I want to export sessions so that I can review offline

**Acceptance Criteria:**
- Session state machine (7 states)
- Resume from checkpoint after timeout
- Progress dashboard (sessions, minutes, themes, sentiment trend)
- Session export to PDF
- Streak tracking (consecutive days)

**Priority:** P0 (Retention)
**Effort:** 21 story points

---

#### F6: HITL Review Queue (Clinician Dashboard)
**Description:** Licensed clinician oversight for flagged sessions

**User Stories:**
- As a clinician, I want to review flagged sessions so that I ensure quality
- As a clinician, I want to approve/reject AI responses so that users are safe
- As a clinician, I want to add notes so that future reviewers have context

**Acceptance Criteria:**
- Prioritized queue (crisis > deadline > risk)
- Anonymized user data (User #47291)
- Clinician actions: approve/edit/reject/escalate
- Review SLA tracking (urgent: 2hr, medium: 24hr)
- Complete audit trail
- Feedback loop for AI improvement

**Priority:** P0 (Compliance)
**Effort:** 21 story points

---

### 5.2 V2 Features (Month 3-4)

#### F7: VR Immersive Experiences (Quest 3)
**Description:** WebXR journaling with spatial audio, bilateral drawing

**User Stories:**
- As a VR user, I want immersive environments so that I feel more present
- As a VR user, I want bilateral drawing so that I can regulate through creativity
- As a VR user, I want cinematic meditation so that I achieve deeper states

**Acceptance Criteria:**
- 5 environments (cozy cabin, forest clearing, beach sunset, mountain vista, inner sanctuary)
- Spatial audio with HRTF
- Bilateral drawing with hand tracking
- Cinematic camera rails for Six-Phase Meditation
- 72fps minimum performance
- Gaze-based UI interaction

**Priority:** P1 (Differentiation)
**Effort:** 55 story points

---

#### F8: Advanced Journaling Techniques
**Description:** List-of-100, non-dominant hand, written dialogue, springboard

**User Stories:**
- As a user, I want exhaustive exploration (list-of-100) so that I go deeper
- As a user, I want to access my inner child (non-dominant hand) so that I bypass filters
- As a user, I want inner parts dialogue so that I resolve inner conflicts

**Acceptance Criteria:**
- 4 additional modalities implemented
- Canvas support for non-dominant hand (freeform drawing)
- Numbered list UI for list-of-100 with milestone encouragement
- Alternating speaker format for written dialogue
- Multiple springboard prompts per topic

**Priority:** P1 (Depth)
**Effort:** 34 story points

---

#### F9: Goal Setting & RAS Priming
**Description:** SMART goals with sensory-emotional visualization

**User Stories:**
- As a user, I want to set meaningful goals so that I have direction
- As a user, I want to visualize achieving goals so that they feel real
- As a user, I want affirmations so that I prime my attention (RAS)

**Acceptance Criteria:**
- SMART goal framework (Specific, Measurable, Achievable, Relevant, Time-bound)
- Sensory-emotional visualization prompts (see, hear, feel)
- RAS priming exercises (3-5 affirmations per goal)
- Goal tracking dashboard
- Completion date reminders

**Priority:** P1 (Motivation)
**Effort:** 21 story points

---

#### F10: Voice-to-Text & Multilingual Support
**Description:** Speech recognition, localization

**User Stories:**
- As a user, I want to speak my journal entries so that I can journal hands-free
- As a non-English user, I want the platform in my language so that I feel comfortable

**Acceptance Criteria:**
- Web Speech API integration (real-time transcription)
- Whisper API fallback (high accuracy)
- Support for 10 languages (EN, ES, FR, DE, IT, PT, ZH, JA, KO, HI)
- Crisis resources localized per region
- RTL support (Arabic, Hebrew)

**Priority:** P2 (Accessibility)
**Effort:** 34 story points

---

## 6. NON-FUNCTIONAL REQUIREMENTS

### 6.1 Performance
| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| E2E Session Latency (p95) | < 3.5s | < 5s |
| Safety Guardian Response | < 300ms | < 500ms |
| Database Query Time | < 50ms | < 100ms |
| Cache Hit Rate | > 85% | > 70% |
| Uptime | 99.9% | 99.5% |
| Error Rate | < 0.1% | < 1% |
| VR Frame Rate | 72+ fps | 60+ fps |

### 6.2 Scalability
- **Concurrent Users:** 10,000 (Month 3) → 100,000 (Year 1)
- **Auto-scaling:** CPU > 70%, Memory > 80%
- **Database:** Read replicas, connection pooling (pgbouncer)
- **CDN:** Cloudinary for static assets
- **LLM Caching:** Prompt caching (OpenAI/Anthropic)

### 6.3 Security
- **Authentication:** OAuth 2.0 + JWT (1hr access, 30-day refresh)
- **Encryption at Rest:** AES-256 (PostgreSQL, MinIO, Redis)
- **Encryption in Transit:** TLS 1.3 (all API calls)
- **Application-Level:** AES-256-GCM (sensitive exercises)
- **Privacy:** SHA-256 hashed crisis logs (no plaintext)
- **Access Control:** Role-based (user, clinician, admin)

### 6.4 Compliance
- **HIPAA:** BAA with AWS, audit logs for PHI access, minimum necessary
- **GDPR:** Right to access/deletion/portability, consent tracking
- **COPPA:** No users under 13 (age verification)
- **Accessibility:** WCAG 2.1 AA compliance
- **OWASP Top 10:** Secure coding, penetration testing

### 6.5 Reliability
- **RTO (Recovery Time Objective):** 4 hours
- **RPO (Recovery Point Objective):** 15 minutes
- **Backup:** Daily full + WAL archiving (PostgreSQL)
- **Disaster Recovery:** Multi-region failover
- **Monitoring:** Prometheus, Grafana, PagerDuty

### 6.6 Usability
- **Onboarding:** < 5 minutes to first session
- **Session Completion:** > 90% rate
- **User Satisfaction:** > 4.5/5.0
- **Mobile Responsive:** iOS 14+, Android 10+
- **VR Support:** Quest 3 (Meta Quest OS)

---

## 7. RISKS, SAFETY & MITIGATION

### 7.1 Clinical Risks

**Risk:** AI hallucinates harmful advice
- **Probability:** Medium
- **Impact:** Critical
- **Mitigation:**
  - Multi-model validation (Claude + GPT-4o)
  - HITL review for all Code Yellow/Red sessions
  - Prompt guardrails ("never diagnose", "never recommend medication")
  - Eval rubrics for safety adherence

**Risk:** User in crisis not detected (false negative)
- **Probability:** Low
- **Impact:** Critical
- **Mitigation:**
  - Multi-signal detection (ideation + behavioral + sentiment)
  - Conservative thresholds (default to Code Yellow when ambiguous)
  - Clinician training on crisis patterns
  - Monthly safety audits

**Risk:** VR triggers motion sickness or dissociation
- **Probability:** Medium
- **Impact:** Medium
- **Mitigation:**
  - 72fps minimum performance
  - Grounding exercises before/after VR
  - Exit prompts ("Remove headset slowly")
  - User education on VR best practices

---

### 7.2 Technical Risks

**Risk:** LLM API outages (OpenAI, Anthropic)
- **Probability:** Medium
- **Impact:** High
- **Mitigation:**
  - Multi-provider strategy (fallback from Claude → GPT-4o → Gemini)
  - Prompt caching reduces API calls
  - Graceful degradation (generic prompts if LLM unavailable)

**Risk:** Database performance degradation at scale
- **Probability:** Medium
- **Impact:** High
- **Mitigation:**
  - Read replicas (2x)
  - Connection pooling (pgbouncer)
  - Partitioning (audit_logs, session_events)
  - Proper indexing (87 indexes)
  - Quarterly performance reviews

**Risk:** HITL review bottleneck
- **Probability:** High
- **Impact:** Medium
- **Mitigation:**
  - Auto-scaling clinician pool (contract reviewers)
  - Priority queue (urgent < 2hr, medium < 24hr)
  - Capacity management alerts
  - Batch review features

---

### 7.3 Business Risks

**Risk:** User churn due to lack of engagement
- **Probability:** High
- **Impact:** High
- **Mitigation:**
  - Streak tracking + gamification (badges)
  - Smart reminders (not annoying)
  - Progress visualization (sentiment over time)
  - A/B testing for retention

**Risk:** Regulatory compliance failure (HIPAA/GDPR)
- **Probability:** Low
- **Impact:** Critical
- **Mitigation:**
  - Legal review (pre-launch)
  - Quarterly compliance audits
  - Penetration testing (annual)
  - BAA + DPA signed with vendors

**Risk:** Cost overruns (LLM API costs)
- **Probability:** Medium
- **Impact:** Medium
- **Mitigation:**
  - Prompt caching (60% cost reduction)
  - Pre-generated TTS (common phrases)
  - Cost monitoring (alerts at 2x baseline)
  - Monthly cost optimization reviews

---

## 8. ANALYTICS & SUCCESS METRICS

### 8.1 Product Metrics (OKRs)

**Objective 1: Achieve Product-Market Fit**
- KR1: 1,000 MAU by Month 3
- KR2: 90%+ session completion rate
- KR3: 4.5+/5.0 user satisfaction score
- KR4: 70%+ Day 7 retention

**Objective 2: Ensure Clinical Quality**
- KR1: 100% crisis escalations resolved safely
- KR2: 95%+ HITL review SLA compliance
- KR3: < 5% AI response rejection rate (by clinicians)
- KR4: 0 clinical incidents

**Objective 3: Drive Engagement**
- KR1: 4.2 sessions per user per month
- KR2: 15-day median streak
- KR3: 60%+ monthly feature adoption (VR, new techniques)
- KR4: 30%+ referral rate

---

### 8.2 User Behavior Analytics

**Acquisition:**
- Traffic sources (organic, paid, referral)
- Sign-up conversion rate
- Cost per acquisition (CPA)

**Activation:**
- Time to first session (target: < 5 min)
- Onboarding completion rate
- Technique selection distribution

**Engagement:**
- Sessions per user per week
- Avg session duration (target: 25-35 min)
- Technique diversity (# different modalities tried)
- VR adoption rate (if Quest 3 available)

**Retention:**
- Day 1, 7, 30 retention
- Churn rate (target: < 8%)
- Reactivation rate (lapsed → active)

**Referral:**
- Invites sent per user
- Invite conversion rate
- NPS (Net Promoter Score)

---

### 8.3 Clinical Analytics

**Safety:**
- Crisis detection accuracy (precision, recall)
- False positive rate (Code Red/Yellow)
- Time to HITL review (by priority)
- Escalation outcomes (resolved, unresolved)

**Quality:**
- AI response approval rate (by clinicians)
- Theme extraction accuracy (user validation)
- Sentiment analysis accuracy
- User feedback on AI quality

**Outcomes:**
- Sentiment improvement over time
- Theme evolution (recurring → resolved)
- Goal achievement rate
- Self-reported wellbeing (pre/post)

---

### 8.4 Technical Analytics

**Performance:**
- E2E latency (p50, p95, p99)
- Safety Guardian response time
- Database query time
- Cache hit rate
- Error rate (4xx, 5xx)

**Reliability:**
- Uptime (target: 99.9%)
- MTTR (Mean Time To Recovery)
- Incident count (P0, P1, P2)

**Cost:**
- LLM API costs per user per month
- Infrastructure costs (AWS)
- Cost per session

---

## 9. MILESTONES & RELEASE PLAN

### 9.1 MVP (Month 1-2) - "Foundation"
**Goal:** Prove core value (structured journaling + safety)

**Features:**
- ✅ Requirements (BDD scenarios) - Complete
- ✅ Architecture design - Complete
- ✅ Database schema - Complete
- [ ] User auth + onboarding
- [ ] Safety Guardian (Code Red/Yellow/Green)
- [ ] 4 core journaling exercises (sprint, unsent letter, sentence stems, inventory)
- [ ] Reflection & theme extraction
- [ ] Session management
- [ ] HITL review queue

**Success Criteria:**
- 50 beta users onboarded
- 90%+ session completion
- 0 critical bugs
- 4.5+/5.0 satisfaction

**Release:** Internal beta (Testflight/APK)

---

### 9.2 V1 (Month 3-4) - "Engagement"
**Goal:** Drive retention through depth and immersion

**Features:**
- [ ] 4 advanced techniques (list-of-100, non-dominant hand, dialogue, springboard)
- [ ] VR immersive experiences (Quest 3)
- [ ] Six-Phase Meditation (cinematic mode)
- [ ] Bilateral drawing
- [ ] Goal setting + RAS priming
- [ ] Progress dashboard
- [ ] Session export (PDF)

**Success Criteria:**
- 1,000 MAU
- 70%+ Day 7 retention
- 30%+ VR adoption (if hardware available)
- 4.6+/5.0 satisfaction

**Release:** Public beta (App Store, Google Play, Meta Store)

---

### 9.3 V2 (Month 5-6) - "Scale"
**Goal:** Expand accessibility and international reach

**Features:**
- [ ] Voice-to-text journaling
- [ ] Multilingual support (10 languages)
- [ ] Mobile apps (iOS, Android)
- [ ] Desktop app (Electron)
- [ ] Social proof (testimonials, case studies)
- [ ] Referral program

**Success Criteria:**
- 5,000 MAU
- 60%+ monthly retention
- 10%+ international users
- 4.7+/5.0 satisfaction

**Release:** Production (v2.0)

---

### 9.4 V3 (Month 7-12) - "Outcomes"
**Goal:** Prove clinical efficacy and monetize

**Features:**
- [ ] Longitudinal outcome tracking
- [ ] Integration with therapy (clinician portal)
- [ ] Insurance billing (if applicable)
- [ ] Premium features (unlimited sessions, priority HITL)
- [ ] Research partnerships (RCTs)

**Success Criteria:**
- 10,000 MAU
- Positive clinical outcomes (RCT)
- Break-even on unit economics
- 4.8+/5.0 satisfaction

**Release:** Production (v3.0)

---

## 10. DEPENDENCIES & ASSUMPTIONS

### 10.1 Dependencies
**External:**
- OpenAI API (GPT-4o, text-embedding-3-large)
- Anthropic API (Claude Sonnet 4.5)
- ElevenLabs API (TTS)
- Pinecone (vector database)
- AWS (infrastructure)

**Internal:**
- Licensed clinicians available for HITL review
- Legal approval for HIPAA/GDPR compliance
- Clinical advisory board for methodology validation

### 10.2 Assumptions
**Market:**
- Users willing to pay $15-30/month for premium (test needed)
- VR adoption grows 30% YoY (Meta projections)
- Telehealth/digital mental health acceptance continues

**Technical:**
- LLM quality improves (hallucinations decrease)
- WebXR browser support expands (Safari, Firefox)
- Quest 3 remains dominant VR platform

**Clinical:**
- Journaling efficacy is well-established (literature)
- AI-augmented therapy is accepted by clinicians
- HITL review model scales economically

---

## 11. OUT OF SCOPE (V1)

**Explicitly NOT included in MVP/V1:**
- ❌ Diagnosis or treatment of mental illness
- ❌ Medication recommendations
- ❌ Live 1:1 therapy sessions
- ❌ Group journaling or social features
- ❌ Integration with EHR systems
- ❌ Insurance billing
- ❌ Wearable integration (biometrics)
- ❌ AI-generated imagery (Stable Diffusion, DALL-E)
- ❌ Custom avatars or digital twins

**Rationale:**
- Focus on core value (structured journaling + safety)
- Avoid regulatory complexity (diagnosis, prescriptions)
- Validate product-market fit before expanding

---

## 12. OPEN QUESTIONS

**Product:**
1. What's the optimal pricing model? (Subscription vs one-time vs freemium)
2. Should we offer family plans? (shared billing, separate accounts)
3. How do we balance AI vs human touch? (when to escalate to live therapist)

**Technical:**
4. Which LLM provider mix optimizes cost vs quality? (Claude vs GPT-4o ratio)
5. Should we support WebXR on desktop (non-VR 3D mode)? (accessibility vs complexity)
6. How do we handle offline mode? (PWA + local storage vs online-only)

**Clinical:**
7. What's the threshold for mandatory HITL review? (all Code Yellow or only Red?)
8. Should we offer therapist-supervised accounts? (clinician can view client's sessions)
9. How do we measure clinical outcomes longitudinally? (standardized assessments)

**Business:**
10. What's the acquisition strategy? (B2C direct vs B2B through clinicians)
11. Should we pursue research partnerships early? (RCTs for credibility)
12. How do we handle crisis escalations legally? (liability, duty to warn)

---

## 13. APPROVAL & SIGN-OFF

**Product Owner:** Jithendran Sellamuthu
**Engineering Lead:** Claude (AI Architect)
**Clinical Advisor:** [TBD - Licensed Therapist]
**Legal/Compliance:** [TBD - HIPAA/GDPR Expert]

**Approval Date:** [Pending Review]
**Status:** Draft v1.0

---

**Next Steps:**
1. Review PRD with stakeholders
2. Prioritize MVP features (MoSCoW)
3. Create detailed user stories in backlog
4. Finalize design mockups (Figma)
5. Begin Sprint 1 (Safety Guardian + Auth)

---

**Document Version:** 1.0
**Last Updated:** 2026-02-11
**Next Review:** 2026-02-18
