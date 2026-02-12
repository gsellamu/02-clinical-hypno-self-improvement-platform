# 🌟 5D Therapeutic Plan Generator

**The Crown Jewel of Jeeth.ai Platform**

Generates comprehensive therapeutic plans integrating data from **5 major sources** across **5 dimensions**.

---

## 📊 What It Does

Integrates data from:

1. ✅ **E&P Assessment Results**
   - Primary/secondary type, percentages, confidence
   - Communication preferences for AI personalization

2. ✅ **Screening & Onboarding Information**
   - Safety screening results, risk levels
   - Contraindications, legal compliance

3. ✅ **Client's Presenting Issues & Goals**
   - Primary/secondary issues, severity, duration
   - Goal statement, success criteria, expected timeline

4. ✅ **Therapy Scripts & Session Framework**
   - HMI protocols from Epic 6
   - AI-generated scripts from Epic 7
   - Session structure with phases

5. ✅ **Augmented Intelligence from:**
   - Custom Hypnotherapy LLMs
   - GraphRAG (Epic 8) - Protocol recommendations
   - MCP Tools - FHIR/healthcare data
   - Carl Jung - Archetype analysis, shadow work
   - Siddha - Chakra analysis, energy work
   - Traditional Psychology - Evidence-based methods

---

## 🎯 5 Dimensional Plans Generated

```
1. Mind Dimension      - Cognitive/psychological healing
2. Body Dimension      - Physical/somatic wellness
3. Social Dimension    - Relationships/environment
4. Spiritual Dimension - Purpose/meaning/transcendence
5. Integration Dimension - Holistic synthesis
```

Each dimension includes:
- Current state assessment
- Baseline score (0-100)
- Areas of concern & strengths
- Short-term & long-term goals
- Primary protocols & complementary practices
- Progress indicators & measurement frequency
- Recommended reading & exercises
- E&P type adaptations

Plus:
- Executive summary
- Treatment philosophy
- Session structure (6 phases)
- Milestones (4 checkpoints)
- Safety protocols (3-tier escalation)
- Baseline & target metrics
- Jung/Siddha/Hypno/Clinical insights

---

## 🚀 Quick Start

### Install Dependencies
```bash
cd therapeutic-plan-service
pip install -r requirements.txt --break-system-packages
```

### Start Service
```bash
python main.py
```

Service starts on: **http://localhost:8013**

API docs: **http://localhost:8013/docs**

---

## 📡 API Endpoints

### Generate Plan
```bash
POST /api/v1/plan/generate

Body: ClientProfile (see models.py)

Returns: TherapeuticPlan
```

### Get Existing Plan
```bash
GET /api/v1/plan/{user_id}

Returns: TherapeuticPlan
```

### Health Check
```bash
GET /health

Returns: {"status": "healthy"}
```

---

## 🧪 Test It

### Example Request:
```python
import requests

profile = {
    "user_id": "user-123",
    "ep_type": "Physical",
    "ep_primary_percentage": 65.0,
    "ep_secondary_percentage": 35.0,
    "ep_confidence": 85.0,
    "communication_preferences": {"tone": "direct"},
    
    "safety_screening_passed": True,
    "safety_risk_level": "LOW",
    "contraindications": [],
    
    "primary_issue": "Anxiety",
    "secondary_issues": ["Stress", "Sleep issues"],
    "issue_duration": "6+ months",
    "issue_severity": 7,
    
    "goal_statement": "Reduce anxiety and improve daily functioning",
    "expected_timeline": "months",
    "success_criteria": [
        "Anxiety reduced by 60%",
        "Better sleep quality",
        "Daily activities manageable"
    ],
    
    "previous_therapy": False,
    "previous_hypnotherapy": False,
    "medications": [],
    "medical_conditions": [],
    "support_system": "moderate",
    
    "referral_verified": True,
    "referral_provider": "Dr. Smith",
    "consent_signed": True
}

response = requests.post(
    "http://localhost:8013/api/v1/plan/generate",
    json=profile
)

plan = response.json()
print(plan["executive_summary"])
print(f"Mind baseline: {plan['mind_dimension']['baseline_score']}")
```

---

## 📁 Files Structure

```
therapeutic-plan-service/
├── main.py           - Main service & endpoints
├── models.py         - Pydantic models & mock integrations
├── requirements.txt  - Python dependencies
└── README.md         - This file
```

---

## 🔧 Current Status

**Status:** ✅ Mock Data - Ready for Integration

**Mock data sources (replace with real):**
- GraphRAG search → Replace with Epic 8 API
- Hypno LLM → Replace with Anthropic Claude/Custom LLM
- Jung analysis → Replace with Jung library
- Siddha analysis → Replace with Siddha library
- FHIR data → Replace with MCP integration

**To integrate real data sources:**
1. Update functions in `models.py`
2. Add API clients for Epic 6/7/8
3. Add LLM integration (Anthropic, OpenAI, etc.)
4. Add database for plan storage

---

## 🎯 Next Steps

1. ✅ Service is ready to run
2. 🔄 Replace mock data with real integrations
3. 🔄 Add database for plan storage
4. 🔄 Add authentication/authorization
5. 🔄 Deploy to production

---

## 💡 Example Output

```json
{
  "plan_id": "550e8400-e29b-41d4-a716-446655440000",
  "user_id": "user-123",
  "executive_summary": "5D Therapeutic Plan for user-123...",
  "estimated_duration": "30 weeks",
  "session_frequency": "weekly",
  
  "mind_dimension": {
    "dimension": "Mind",
    "baseline_score": 30.0,
    "current_state": "Client presents with Anxiety (severity 7/10)",
    "short_term_goals": [
      "Reduce Anxiety intensity by 30%",
      "Develop awareness of cognitive patterns"
    ],
    "primary_protocols": [
      {
        "name": "Anxiety Reduction Protocol",
        "sessions": 6
      }
    ]
  },
  
  "milestones": [
    {
      "week": 2,
      "title": "Initial Progress Check",
      "criteria": ["Comfortable with process"]
    }
  ],
  
  "safety_protocols": [
    "Begin each session with safety check",
    "Emergency contact on file"
  ]
}
```

---

**Transform 1 Billion Lives by 2035!** 🕉️✨
