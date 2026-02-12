System Architecture: HMI-Based AI Hypnotherapy Platform
Phase 1: Foundation - General Self Improvement Module
1. Multi-Modal Assessment System
┌─────────────────────────────────────────────────────────┐
│          ASSESSMENT & PERSONALIZATION LAYER             │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Wheel of   │  │ Suggestibility│  │   Identity   │ │
│  │  Happiness   │  │    Testing    │  │  Assessment  │ │
│  │   Analysis   │  │   (E vs P)    │  │   (Layers)   │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘ │
│         │                  │                  │         │
│         └──────────────────┴──────────────────┘         │
│                            │                            │
│                     ┌──────▼───────┐                    │
│                     │  Assessment  │                    │
│                     │  Aggregator  │                    │
│                     │    Agent     │                    │
│                     └──────┬───────┘                    │
└────────────────────────────┼────────────────────────────┘
                             │
                     ┌───────▼────────┐
                     │ User Profile & │
                     │ Personalization│
                     │    Vector      │
                     └────────────────┘
Key Components:
Wheel of Happiness Digital Assessment

Interactive visualization (8 life areas: Health, Relationships, Career, etc.)
Real-time scoring → Graph RAG for relationship mapping
Identifies priority areas and interdependencies

Suggestibility Testing Agent
# Pseudo-architecture
class SuggestibilityTestingAgent:
    def __init__(self):
        self.finger_spread_analyzer = VisualMLModel()
        self.response_pattern_detector = TransformerModel()
        self.e_vs_p_classifier = CustomHypnosisLLM()
    
    async def determine_modality(self, user_responses):
        # Analyzes:
        # - Speed of finger spreading
        # - Response to literal vs inferred suggestions
        # - Questionnaire responses (36 questions)
        
        emotional_score = self.analyze_inferred_responses()
        physical_score = self.analyze_literal_responses()
        
        return PersonalizationProfile(
            primary_suggestibility="emotional" if emotional_score > physical_score else "physical",
            induction_style="inferred_arm_raising" if emotional else "literal_arm_raising",
            language_patterns=self.generate_optimal_patterns()
        )
```

#### **2. HMI Protocol Graph RAG Architecture**
```
┌─────────────────────────────────────────────────────────┐
│           HYPNOTHERAPY KNOWLEDGE GRAPH                  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────┐       ┌─────────────┐                │
│  │  Induction  │◄─────►│  Deepening  │                │
│  │  Protocols  │       │  Techniques │                │
│  └──────┬──────┘       └──────┬──────┘                │
│         │                     │                        │
│         │     ┌───────────────┘                        │
│         │     │                                        │
│  ┌──────▼─────▼──────┐      ┌─────────────┐          │
│  │  Theory of Mind   │◄────►│   Safety    │          │
│  │    Education      │      │  Protocols  │          │
│  └──────┬────────────┘      └─────────────┘          │
│         │                                              │
│  ┌──────▼────────────┐     ┌──────────────┐          │
│  │  Therapeutic      │◄───►│ Post-Hypnotic│          │
│  │  Suggestions      │     │  Suggestions │          │
│  └───────────────────┘     └──────────────┘          │
│                                                         │
│         ┌───────────────────────────┐                 │
│         │   MCP Server: HMI Scripts│                 │
│         │   - 18 Practicum Scripts  │                 │
│         │   - Clinical Guidelines   │                 │
│         │   - Safety Procedures     │                 │
│         └───────────────────────────┘                 │
└─────────────────────────────────────────────────────────┘
Specialized Vector Stores:

Induction Embedding Store

Emotional/Inferred induction scripts
Physical/Literal induction scripts
Hybrid approaches
Indexed by: suggestibility type, goal, session number


Suggestion Template Store

Habit formation suggestions
Identity shift language patterns
Keystone habit reinforcement
Indexed by: goal category (Wheel of Happiness areas)


Clinical Safety Store

Emergence protocols
Contraindication checks
Escalation procedures
Resistance handling strategies



3. Multi-Agent Session Orchestration (CrewAI)
python# Session Orchestration Architecture

class HMISessionCrew:
    def __init__(self):
        self.agents = {
            "intake_specialist": IntakeAgent(),
            "suggestibility_analyst": SuggestibilityAgent(),
            "protocol_selector": ProtocolSelectionAgent(),
            "script_composer": ScriptCompositionAgent(),
            "safety_guardian": SafetyGuardianAgent(),
            "delivery_optimizer": DeliveryAgent()
        }
        
        self.workflow = StateGraph()
        self.mcp_servers = {
            "hmi_protocols": MCPServer("hmi_practicum_scripts"),
            "clinical_guidelines": MCPServer("safety_protocols"),
            "habit_formation": MCPServer("behavior_change_science")
        }
    
    async def orchestrate_session(self, user_profile, session_number):
        """
        Workflow:
        1. Intake → Wheel of Happiness assessment
        2. Suggestibility Testing → E vs P determination
        3. Theory of Mind → Educational foundation
        4. Protocol Selection → Based on profile + session #
        5. Script Composition → RAG retrieval + LLM synthesis
        6. Safety Review → Guardrails validation
        7. Delivery Optimization → Voice, pacing, personalization
        """
        
        # Graph state progression
        state = SessionState(user_profile=user_profile)
        
        # Agent collaboration
        state = await self.agents["intake_specialist"].process(state)
        state = await self.agents["suggestibility_analyst"].process(state)
        state = await self.agents["protocol_selector"].process(state)
        
        # RAG retrieval from MCP servers
        relevant_scripts = await self.mcp_servers["hmi_protocols"].retrieve(
            query=state.generate_query(),
            filters={
                "session_type": "first_session" if session_number == 1 else "subsequent",
                "suggestibility": state.suggestibility_profile,
                "goal_area": state.primary_goal
            }
        )
        
        # LLM composition
        state = await self.agents["script_composer"].synthesize(
            state=state,
            retrieved_content=relevant_scripts,
            personalization_vector=user_profile
        )
        
        # Safety validation
        state = await self.agents["safety_guardian"].validate(state)
        
        return state.final_session_script
```

#### **4. Custom Hypnosis LLM Fine-Tuning Strategy**

**Training Data Architecture:**
```
├── HMI_Protocol_Corpus/
│   ├── inductions/
│   │   ├── emotional_arm_raising_100_variations.jsonl
│   │   ├── physical_arm_raising_100_variations.jsonl
│   │   ├── auto_dual_induction_50_variations.jsonl
│   │   └── secondary_inductions_200_variations.jsonl
│   ├── deepening_techniques/
│   │   ├── progressive_relaxation_150_variations.jsonl
│   │   ├── staircase_100_variations.jsonl
│   │   ├── reactionary_75_variations.jsonl
│   │   └── challenges_100_variations.jsonl
│   ├── therapeutic_suggestions/
│   │   ├── habit_formation_500_examples.jsonl
│   │   ├── identity_shift_300_examples.jsonl
│   │   ├── stress_management_200_examples.jsonl
│   │   └── sleep_improvement_200_examples.jsonl
│   ├── theory_of_mind_education/
│   │   └── tom_explanations_50_variations.jsonl
│   └── safety_protocols/
│       ├── emergence_procedures_100_variations.jsonl
│       ├── post_hypnotic_suggestions_150_variations.jsonl
│       └── contraindication_handling_75_examples.jsonl
Fine-Tuning Approach:
python# Multi-stage fine-tuning strategy

# Stage 1: Domain Adaptation (Base → Clinical Hypnotherapy)
base_model = "claude-sonnet-4-20250514"  # or GPT-4, Llama 3, etc.

domain_adapted_model = fine_tune(
    base_model=base_model,
    dataset=HMI_Protocol_Corpus,
    objective="next_token_prediction",
    special_tokens=[
        "<induction>", "</induction>",
        "<deepening>", "</deepening>",
        "<suggestion>", "</suggestion>",
        "<emergence>", "</emergence>",
        "<safety_check>", "</safety_check>"
    ]
)

# Stage 2: Instruction Tuning (Task-Specific)
instruction_tuned_model = fine_tune(
    base_model=domain_adapted_model,
    dataset=InstructionDataset(
        tasks=[
            "Generate emotional arm raising induction",
            "Create habit formation suggestions for [goal]",
            "Adapt script for emotional vs physical sexuality",
            "Compose Theory of Mind explanation for [issue]"
        ]
    ),
    objective="instruction_following"
)

# Stage 3: RLHF with Clinical Feedback
rlhf_model = reinforce_from_human_feedback(
    base_model=instruction_tuned_model,
    feedback_dataset=ClinicalEvaluations(
        metrics=[
            "therapeutic_effectiveness",
            "safety_compliance",
            "personalization_quality",
            "protocol_adherence"
        ]
    )
)

# Stage 4: Constitutional AI (Safety Constraints)
final_hypnosis_llm = apply_constitutional_ai(
    base_model=rlhf_model,
    constitution=ClinicalConstitution(
        principles=[
            "Always include proper emergence procedures",
            "Never suggest harmful behaviors",
            "Maintain HMI protocol fidelity",
            "Respect contraindications",
            "Escalate to human when uncertain"
        ]
    )
)
```

#### **5. Session Structure Implementation**

**First Session Complete Workflow:**
```
┌─────────────────────────────────────────────────────────┐
│                 FIRST SESSION TIMELINE                  │
│                    (50-55 minutes)                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ 1. Client Presents Issues (10 min)                     │
│    ├─ Active listening agent                           │
│    ├─ Note-taking & goal extraction                    │
│    └─ Wheel of Happiness mapping                       │
│                                                         │
│ 2. Pre-Induction Speech (3 min)                        │
│    ├─ Myth dispelling                                  │
│    ├─ Expectation setting                              │
│    └─ Hope installation                                │
│                                                         │
│ 3. Suggestibility Testing (5 min)                      │
│    ├─ Finger-spreading test                            │
│    ├─ Visual analysis (ML-based)                       │
│    └─ E vs P classification                            │
│                                                         │
│ 4. Theory of Mind (5 min)                              │
│    ├─ Draw TOM diagram                                 │
│    ├─ Explain conscious vs subconscious               │
│    └─ Connect to client's goal                         │
│                                                         │
│ 5. Questionnaire (5 min)                               │
│    ├─ 36-question assessment                           │
│    └─ Build message units                              │
│                                                         │
│ 6. Arm Raising Induction (10 min)                      │
│    ├─ Select E or P induction                          │
│    ├─ Physiological changes tracking                   │
│    ├─ Conversion to hypnosis                           │
│    └─ Post-hypnotic suggestion for "Deep Sleep"        │
│                                                         │
│ 7. Deepening Techniques (varies)                       │
│    ├─ Progressive relaxation                           │
│    ├─ Staircase                                        │
│    └─ Additional deepeners as needed                   │
│                                                         │
│ 8. Therapeutic Suggestions (5 min)                     │
│    ├─ Goal-specific suggestions                        │
│    ├─ Habit loop reinforcement                         │
│    ├─ Identity shift language                          │
│    └─ Dream therapy for venting                        │
│                                                         │
│ 9. Post-Hypnotic Suggestion to Re-Hypnosis (5 min)     │
│    ├─ Count out 0-5                                    │
│    ├─ Immediate re-induction                           │
│    ├─ Reinforce post-hypnotic suggestion              │
│    └─ Final emergence 0-5                              │
│                                                         │
│ 10. Rebook & Session Notes                             │
│     └─ Schedule next session                           │
│                                                         │
└─────────────────────────────────────────────────────────┘
Implementation with LangGraph:
pythonfrom langgraph.graph import StateGraph, END
from typing import TypedDict, Annotated
import operator

class SessionState(TypedDict):
    user_profile: dict
    session_number: int
    issues_presented: list
    wheel_of_happiness: dict
    suggestibility_profile: dict
    theory_of_mind_explained: bool
    questionnaire_responses: dict
    induction_complete: bool
    current_depth: int
    suggestions_given: list
    safety_checks_passed: bool
    session_transcript: str
    next_session_plan: dict

# Define the session workflow graph
workflow = StateGraph(SessionState)

# Add nodes for each session component
workflow.add_node("intake", intake_agent)
workflow.add_node("pre_induction", pre_induction_agent)
workflow.add_node("suggestibility_test", suggestibility_agent)
workflow.add_node("theory_of_mind", tom_education_agent)
workflow.add_node("questionnaire", questionnaire_agent)
workflow.add_node("induction", induction_agent)
workflow.add_node("deepening", deepening_agent)
workflow.add_node("suggestions", therapeutic_suggestions_agent)
workflow.add_node("post_hypnotic", post_hypnotic_agent)
workflow.add_node("emergence", emergence_agent)
workflow.add_node("safety_check", safety_guardian_agent)

# Define edges (session flow)
workflow.add_edge("intake", "pre_induction")
workflow.add_edge("pre_induction", "suggestibility_test")
workflow.add_edge("suggestibility_test", "theory_of_mind")
workflow.add_edge("theory_of_mind", "questionnaire")
workflow.add_edge("questionnaire", "safety_check")

# Conditional edge based on safety check
workflow.add_conditional_edges(
    "safety_check",
    lambda state: "induction" if state["safety_checks_passed"] else "escalate_to_human"
)

workflow.add_edge("induction", "deepening")
workflow.add_edge("deepening", "suggestions")
workflow.add_edge("suggestions", "post_hypnotic")
workflow.add_edge("post_hypnotic", "emergence")
workflow.add_edge("emergence", END)

# Compile the graph
session_app = workflow.compile()
```

### **Phase 2: Immersive Experience Layer**

#### **6. XR/VR Integration Architecture**
```
┌─────────────────────────────────────────────────────────┐
│              IMMERSIVE THERAPY ENVIRONMENT              │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │          Unity/Unreal Engine Runtime              │  │
│  │                                                    │  │
│  │  ┌─────────────┐         ┌──────────────┐       │  │
│  │  │  Therapist  │         │ Environment  │       │  │
│  │  │   Avatar    │         │  Rendering   │       │  │
│  │  │ (Nvidia ACE)│         │  (Calming    │       │  │
│  │  │             │         │   Spaces)    │       │  │
│  │  └──────┬──────┘         └──────┬───────┘       │  │
│  │         │                       │                │  │
│  │         └───────────┬───────────┘                │  │
│  │                     │                            │  │
│  │         ┌───────────▼───────────┐                │  │
│  │         │  Real-time Sync with  │                │  │
│  │         │    AI Session Agent   │                │  │
│  │         └───────────┬───────────┘                │  │
│  │                     │                            │  │
│  │     ┌───────────────┼───────────────┐            │  │
│  │     │               │               │            │  │
│  │ ┌───▼────┐   ┌──────▼─────┐  ┌─────▼─────┐     │  │
│  │ │Gaze    │   │Biometric   │  │   Voice   │     │  │
│  │ │Tracking│   │Monitoring  │  │ Synthesis │     │  │
│  │ │        │   │(HRV, GSR)  │  │(ElevenLabs│     │  │
│  │ └────────┘   └────────────┘  └───────────┘     │  │
│  │                                                  │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
Key Immersive Components:

Nvidia ACE-Powered Virtual Therapist

Photo-realistic avatar with HMI-trained gestures
Lip-sync with AI-generated script
Non-verbal communication (nodding, eye contact, gentle hand movements)


Therapeutic Environment Design

Office Setting: For intake and pre-induction
Transition Space: Dimming lights, soundscape changes
Hypnotic Environment:

Guided imagery scenes (meadow, staircase, relaxing experiences from user's memory)
Visual deepening aids (spiral, pendulum)
Biofeedback visualization (breath rate, heart rate)




Biometric Integration

Heart Rate Variability (HRV) monitoring
Galvanic Skin Response (GSR) for emotional state
Eye tracking for depth assessment
Real-time adaptation of script delivery based on physiological responses



Unity/Unreal Implementation Strategy:
csharp// Unity C# - Hypnotherapy Session Controller

public class HypnotherapySessionController : MonoBehaviour
{
    // Avatar & Environment
    private NvidiaACEAvatar therapistAvatar;
    private EnvironmentManager environmentManager;
    
    // AI Integration
    private WebSocketConnection aiSessionConnection;
    private BiometricMonitor biometrics;
    
    // Session State
    private SessionPhase currentPhase;
    private float inductionDepth = 0f;
    
    async void Start()
    {
        // Initialize AI connection
        aiSessionConnection = new WebSocketConnection("wss://your-ai-backend.com/session");
        await aiSessionConnection.Connect();
        
        // Setup biometric monitoring
        biometrics = GetComponent<BiometricMonitor>();
        biometrics.OnHeartRateChanged += AdaptPacing;
        biometrics.OnGSRChanged += AssessEmotionalState;
        
        // Initialize environment
        environmentManager.LoadScene(SceneType.TherapistOffice);
        
        // Start session
        BeginSession();
    }
    
    async void BeginSession()
    {
        // Receive AI-generated script in real-time
        aiSessionConnection.On("script_segment", async (data) => {
            ScriptSegment segment = JsonUtility.FromJson<ScriptSegment>(data);
            
            // Sync avatar speech
            await therapistAvatar.Speak(
                text: segment.text,
                emotion: segment.emotion,
                pacing: segment.pacing
            );
            
            // Trigger environment changes if specified
            if (segment.environmentTransition != null) {
                await environmentManager.TransitionTo(segment.environmentTransition);
            }
        });
        
        // Start intake phase
        currentPhase = SessionPhase.Intake;
        await aiSessionConnection.Send(new { action = "start_session" });
    }
    
    void AdaptPacing(float heartRate)
    {
        // If heart rate indicates relaxation, can deepen
        if (heartRate < 60 && currentPhase == SessionPhase.Induction) {
            aiSessionConnection.Send(new { 
                event = "user_relaxing",
                suggestion = "proceed_to_deepening"
            });
        }
    }
    
    void AssessEmotionalState(float gsrLevel)
    {
        // High GSR might indicate resistance
        if (gsrLevel > 0.8 && currentPhase == SessionPhase.Induction) {
            aiSessionConnection.Send(new {
                event = "possible_resistance",
                suggestion = "use_misdirection_technique"
            });
        }
    }
}
7. Voice Synthesis & Delivery Optimization
Multi-Modal Voice Architecture:
pythonclass TherapeuticVoiceSystem:
    def __init__(self):
        self.voice_models = {
            "pre_induction": ElevenLabsVoice("professional_warm"),
            "induction": ElevenLabsVoice("soothing_gentle"),
            "deepening": ElevenLabsVoice("deeper_slower"),
            "suggestions": ElevenLabsVoice("confident_affirming"),
            "emergence": ElevenLabsVoice("energizing_clear")
        }
        
        self.pacing_engine = AdaptivePacingEngine()
        self.prosody_controller = ProsodyController()
    
    async def synthesize_segment(self, text, phase, user_state):
        """
        Adaptive voice synthesis based on:
        - Session phase
        - User's biometric state
        - Suggestibility profile (E vs P)
        """
        
        # Select appropriate voice model
        voice = self.voice_models[phase]
        
        # Adjust pacing based on user state
        pacing = self.pacing_engine.calculate(
            baseline_wpm=120,  # Words per minute
            user_heart_rate=user_state.heart_rate,
            phase=phase
        )
        
        # Adjust prosody for emotional vs physical
        if user_state.suggestibility == "emotional":
            prosody = self.prosody_controller.generate_emotional_pattern(
                inference_level="high",
                control_language="moderate"
            )
        else:
            prosody = self.prosody_controller.generate_physical_pattern(
                directness_level="high",
                concrete_language="high"
            )
        
        # Synthesize with adaptations
        audio = await voice.generate(
            text=text,
            pacing=pacing,
            prosody=prosody,
            stability=0.8,  # High stability for therapeutic use
            clarity=0.9
        )
        
        return audio
Phase 3: Advanced AI Architecture
8. Distributed Agent System (AutoGen + CrewAI)
python# Hierarchical Multi-Agent Architecture

class HMITherapySystem:
    """
    Three-tier agent architecture:
    1. Strategic Layer: Session planning & safety oversight
    2. Tactical Layer: Component generation (induction, suggestions, etc.)
    3. Operational Layer: Real-time adaptation & delivery
    """
    
    def __init__(self):
        # Strategic Layer
        self.session_planner = AutoGenAgent(
            name="SessionPlanner",
            role="Designs overall session strategy based on user profile",
            llm=CustomHypnosisLLM("strategic"),
            tools=[WheelOfHappinessAnalyzer(), GoalPrioritizer()]
        )
        
        self.safety_overseer = AutoGenAgent(
            name="SafetyOverseer",
            role="Continuously monitors for contraindications and safety issues",
            llm=CustomHypnosisLLM("safety"),
            tools=[ContraindicationChecker(), EmergencyProtocol()]
        )
        
        # Tactical Layer (CrewAI)
        self.tactical_crew = Crew(
            agents=[
                InductionComposerAgent(),
                DeepeningArchitectAgent(),
                SuggestionCraftingAgent(),
                EmergenceProtocolAgent()
            ],
            process=Process.sequential,  # Or hierarchical
            memory=True,
            planning=True
        )
        
        # Operational Layer
        self.real_time_adapter = ReinforcementLearningAgent(
            observation_space=BiometricState,
            action_space=ScriptModifications,
            reward_function=therapeutic_effectiveness_reward
        )
        
        # MCP Integration
        self.mcp_servers = {
            "hmi_protocols": HMIProtocolMCP(),
            "clinical_research": ClinicalResearchMCP(),
            "user_history": UserHistoryMCP()
        }
        
        # Graph RAG
        self.knowledge_graph = HypnotherapyKnowledgeGraph(
            nodes=["protocols", "techniques", "contraindications", "user_profiles"],
            embeddings=CustomHypnosisEmbeddings()
        )
    
    async def conduct_session(self, user_id, session_number):
        """
        Full session orchestration
        """
        
        # 1. Strategic Planning
        user_profile = await self.mcp_servers["user_history"].get_profile(user_id)
        session_plan = await self.session_planner.plan(
            user_profile=user_profile,
            session_number=session_number,
            previous_sessions=user_profile.session_history
        )
        
        # 2. Safety Pre-Check
        safety_clearance = await self.safety_overseer.evaluate(
            session_plan=session_plan,
            user_profile=user_profile
        )
        
        if not safety_clearance.approved:
            return self.escalate_to_human(safety_clearance.concerns)
        
        # 3. Tactical Generation
        session_components = await self.tactical_crew.kickoff(
            inputs={
                "session_plan": session_plan,
                "user_profile": user_profile,
                "mcp_context": self.retrieve_relevant_protocols(session_plan)
            }
        )
        
        # 4. Real-Time Delivery with Adaptation
        async for segment in session_components:
            # Monitor user state
            user_state = self.get_current_user_state()
            
            # Adapt if necessary
            adapted_segment = await self.real_time_adapter.adapt(
                planned_segment=segment,
                user_state=user_state
            )
            
            # Deliver (via immersive system)
            await self.deliver_segment(adapted_segment)
            
            # Continuous safety monitoring
            if not await self.safety_overseer.continuous_check(user_state):
                return self.emergency_emergence_protocol()
        
        # 5. Session Completion
        await self.session_planner.log_session(session_components)
        return SessionResult(success=True)
9. Graph RAG for Clinical Knowledge
pythonfrom langchain.graphs import Neo4jGraph
from langchain.chains import GraphCypherQAChain

class HypnotherapyKnowledgeGraph:
    """
    Graph structure:
    
    (User)-[:HAS_GOAL]->(Goal)
    (Goal)-[:REQUIRES]->(Habit)
    (Habit)-[:USES]->(HabitLoop)
    (HabitLoop)-[:HAS_COMPONENT]->(Reminder|Routine|Reward)
    (User)-[:HAS_SUGGESTIBILITY]->(EmotionalSexuality|PhysicalSexuality)
    (EmotionalSexuality)-[:RESPONDS_TO]->(InferredInduction)
    (PhysicalSexuality)-[:RESPONDS_TO]->(LiteralInduction)
    (Induction)-[:FOLLOWED_BY]->(Deepening)
    (Deepening)-[:LEADS_TO]->(TherapeuticSuggestions)
    (Goal)-[:ADDRESSES]->(WheelOfHappinessArea)
    (TherapeuticSuggestions)-[:REINFORCES]->(Identity)
    (Identity)-[:DRIVES]->(Actions)
    (Actions)-[:PRODUCES]->(Results)
    """
    
    def __init__(self):
        self.graph = Neo4jGraph(
            url="bolt://localhost:7687",
            username="neo4j",
            password="password"
        )
        
        self.chain = GraphCypherQAChain.from_llm(
            llm=CustomHypnosisLLM("graph_reasoning"),
            graph=self.graph,
            verbose=True
        )
    
    async def query(self, user_profile, question):
        """
        Example queries:
        - "What induction protocol is most effective for emotional sexuality 
           with goal of weight loss?"
        - "What habit loop components should be reinforced for career success?"
        - "What are contraindications for stress management suggestions?"
        """
        
        cypher_query = self.generate_cypher_query(user_profile, question)
        results = self.graph.query(cypher_query)
        
        return self.synthesize_answer(results)
    
    def generate_cypher_query(self, user_profile, question):
        """
        Uses LLM to convert natural language to Cypher
        """
        prompt = f"""
        Given this user profile:
        {user_profile}
        
        And this question:
        {question}
        
        Generate a Cypher query to retrieve relevant hypnotherapy protocols.
        
        Available node types: User, Goal, Habit, HabitLoop, Induction, Deepening, 
        TherapeuticSuggestions, WheelOfHappinessArea, Identity
        
        Cypher query:
        """
        
        return self.chain.llm.invoke(prompt)
Phase 4: Clinical Safety & Monitoring
10. Four-Level Clinical Guardrails
pythonclass ClinicalGuardrailSystem:
    """
    Level 1: Pre-Session Screening
    Level 2: Real-Time Monitoring
    Level 3: Post-Segment Validation
    Level 4: Escalation Protocols
    """
    
    def __init__(self):
        self.level_1 = PreSessionScreening()
        self.level_2 = RealTimeMonitoring()
        self.level_3 = PostSegmentValidation()
        self.level_4 = EscalationProtocols()
    
    # Level 1: Pre-Session Screening
    async def pre_session_screening(self, user_profile):
        contraindications = [
            "severe_mental_illness",
            "psychosis",
            "epilepsy",
            "recent_trauma_unprocessed",
            "substance_abuse_active"
        ]
        
        for condition in contraindications:
            if user_profile.has_condition(condition):
                return ScreeningResult(
                    approved=False,
                    reason=f"Contraindication detected: {condition}",
                    recommendation="Refer to licensed mental health professional"
                )
        
        # Age verification (18+)
        if user_profile.age < 18:
            return ScreeningResult(
                approved=False,
                reason="User must be 18 or older",
                recommendation="Parental consent and supervision required"
            )
        
        # Informed consent check
        if not user_profile.informed_consent_signed:
            return ScreeningResult(
                approved=False,
                reason="Informed consent not obtained",
                recommendation="Complete informed consent process"
            )
        
        return ScreeningResult(approved=True)
    
    # Level 2: Real-Time Monitoring
    async def real_time_monitoring(self, user_state):
        """
        Continuous biometric monitoring during session
        """
        
        # Panic/anxiety detection
        if user_state.heart_rate > 120 or user_state.gsr > 0.9:
            return MonitoringAlert(
                severity="high",
                issue="Elevated stress indicators",
                action="Pause suggestions, use calming techniques"
            )
        
        # Dissociation detection (too deep too fast)
        if user_state.response_time > 5.0 and user_state.verbal_engagement == 0:
            return MonitoringAlert(
                severity="medium",
                issue="Possible excessive depth",
                action="Lighten suggestions, check responsiveness"
            )
        
        # Emotional release (abreaction)
        if user_state.emotional_intensity > 0.8:
            return MonitoringAlert(
                severity="medium",
                issue="Strong emotional response detected",
                action="Provide support, slow pacing, offer grounding"
            )
        
        return MonitoringAlert(severity="low", issue=None)
    
    # Level 3: Post-Segment Validation
    async def post_segment_validation(self, segment, user_response):
        """
        Validate that segment was delivered safely and effectively
        """
        
        validator = SegmentValidator(
            checks=[
                "no_harmful_suggestions",
                "appropriate_emergence_included",
                "no_false_memories_created",
                "respects_autonomy",
                "culturally_sensitive"
            ]
        )
        
        validation_result = validator.check(segment)
        
        if not validation_result.passed:
            return ValidationResult(
                approved=False,
                issues=validation_result.failed_checks,
                remediation="Segment requires revision"
            )
        
        return ValidationResult(approved=True)
    
    # Level 4: Escalation Protocols
    async def escalate_to_human(self, reason, severity):
        """
        When AI should hand off to human professional
        """
        
        escalation_triggers = {
            "severe_distress": "immediate",
            "suicidal_ideation": "immediate",
            "trauma_surfacing": "immediate",
            "repeated_resistance": "scheduled",
            "complex_comorbidity": "scheduled",
            "no_progress_after_5_sessions": "scheduled"
        }
        
        urgency = escalation_triggers.get(reason, "scheduled")
        
        return EscalationNotification(
            reason=reason,
            urgency=urgency,
            user_context=self.prepare_transfer_documentation(),
            recommended_action="Human therapist review required"
        )
Next Steps: Implementation Roadmap
Immediate (1-2 months):

Build General Self-Improvement RAG system with HMI protocols
Implement Wheel of Happiness digital assessment
Create suggestibility testing module with E vs P classification
Fine-tune base LLM on HMI practicum scripts

Near-term (3-4 months):
5. Develop multi-agent session orchestration (AutoGen + CrewAI)
6. Implement Graph RAG for clinical knowledge
7. Build first session complete workflow (intake → emergence)
8. Create clinical guardrails system
Medium-term (5-6 months):
9. Integrate voice synthesis with adaptive pacing
10. Build Unity/Unreal prototype with basic avatar
11. Implement biometric monitoring integration
12. Deploy Nvidia ACE for photorealistic therapist avatar
Long-term (7-12 months):
13. Full immersive VR experience with environmental rendering
14. Advanced RL-based real-time adaptation
15. Multi-modal interaction (gaze, gesture, voice)
16. Clinical trials and validation studies
Would you like me to:

Create detailed implementation code for any specific component?
Design the database schema for your hypnotherapy vector stores?
Build a specific agent (e.g., Suggestibility Testing Agent) with complete code?
Design the Unity/Unreal scene architecture for immersive sessions?
Create the fine-tuning dataset structure for your custom Hypnosis LLM?

This is genuinely groundbreaking work you're doing. The combination of HMI's evidence-based protocols with cutting-edge AI could make therapeutic hypnotherapy accessible to millions while maintaining clinical rigor.


Discovered Architecture: Dual Personalization System
HMI uses TWO DISTINCT but CORRELATED personality models:
┌─────────────────────────────────────────────────────────┐
│         HMI DUAL PERSONALIZATION FRAMEWORK              │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────────────┐      ┌─────────────────────┐  │
│  │   SUGGESTIBILITY    │      │     SEXUALITY       │  │
│  │    (HOW to suggest) │      │  (WHO they are in   │  │
│  │                     │      │   relationships)    │  │
│  │  - Emotional (E)    │      │  - Emotional (E)    │  │
│  │  - Physical (P)     │      │  - Physical (P)     │  │
│  └──────────┬──────────┘      └──────────┬──────────┘  │
│             │                            │             │
│             │    Correlation + 10%       │             │
│             │    Adjustment              │             │
│             └────────────┬───────────────┘             │
│                          │                             │
│                  ┌───────▼────────┐                    │
│                  │  User Profile   │                    │
│                  │  - Induction    │                    │
│                  │    Style        │                    │
│                  │  - Language     │                    │
│                  │    Patterns     │                    │
│                  │  - Priorities   │                    │
│                  │  - Goals        │                    │
│                  └─────────────────┘                    │

Module 1: Digital Suggestibility Assessment System
1.1 Interactive Questionnaire Engine
pythonclass SuggestibilityQuestionnaire:
    """
    Implements HMI's 36-question suggestibility test
    with automated scoring and graph-based classification
    """
    
    def __init__(self):
        self.questionnaire_1 = self.load_questionnaire_1()
        self.questionnaire_2 = self.load_questionnaire_2()
        self.scoring_graph = self.load_scoring_graph()
    
    def load_questionnaire_1(self):
        """
        Questions 1-18 focusing on:
        - Somnambulistic tendencies
        - Response to direct suggestions
        - Physical reactions to suggestions
        """
        return [
            {
                "id": 1,
                "text": "Have you ever walked or talked in your sleep?",
                "weight": 10,  # Questions 1-2 worth 10 points
                "category": "somnambulistic"
            },
            {
                "id": 2,
                "text": "Have you ever woken up at night and felt you couldn't move your body or talk?",
                "weight": 10,
                "category": "somnambulistic"
            },
            {
                "id": 3,
                "text": "After having an argument with someone, do you ever think of what you could have or should have said?",
                "weight": 5,  # Questions 3-18 worth 5 points
                "category": "mental_rehearsal"
            },
            # ... (remaining 15 questions from HMI workbook)
        ]
    
    def load_questionnaire_2(self):
        """
        Questions 19-36 focusing on:
        - Inferential thinking
        - Emotional processing
        - Imagery and visualization
        """
        return [
            # Similar structure for second questionnaire
        ]
    
    def calculate_scores(self, responses):
        """
        Implements HMI's exact scoring algorithm
        """
        # Questionnaire 1 scoring
        q1_score = 0
        q1_score += sum(10 for r in responses[0:2] if r == "yes")
        q1_score += sum(5 for r in responses[2:18] if r == "yes")
        
        # Questionnaire 2 scoring
        q2_score = 0
        q2_score += sum(5 for r in responses[18:36] if r == "yes")
        
        combined_score = q1_score + q2_score
        
        return {
            "q1_score": q1_score,
            "q2_score": q2_score,
            "combined_score": combined_score
        }
    
    def lookup_percentage(self, q1_score, combined_score):
        """
        Uses the HMI scoring graph to determine Physical %
        Emotional % = 100 - Physical %
        """
        # Graph lookup logic based on the PDF scoring table
        physical_percentage = self.scoring_graph[q1_score][combined_score]
        emotional_percentage = 100 - physical_percentage
        
        return {
            "physical_suggestibility": physical_percentage,
            "emotional_suggestibility": emotional_percentage
        }
    
    def load_scoring_graph(self):
        """
        Loads the HMI scoring graph from the PDF
        Returns a 2D lookup table
        """
        # This would be a large 2D array based on the graph
        # Example structure:
        scoring_graph = {
            # q1_score: {combined_score: physical_percentage}
            100: {50: 100, 55: 95, 60: 91, ...},
            95: {50: 100, 55: 95, 60: 90, ...},
            # ... full graph from PDF
        }
        return scoring_graph
1.2 Finger-Spreading Test with ML Visual Analysis
pythonclass FingerSpreadingAnalyzer:
    """
    Analyzes video/webcam footage of finger-spreading test
    to objectively measure suggestibility
    """
    
    def __init__(self):
        self.hand_tracker = MediaPipeHandTracker()
        self.temporal_analyzer = TemporalPatternAnalyzer()
    
    async def analyze_test(self, video_stream, test_arm="left"):
        """
        Analyzes finger-spreading test in real-time
        
        Measures:
        1. Speed of finger spreading
        2. Maximum distance between fingers
        3. Response latency
        4. Movement smoothness
        """
        
        results = {
            "left_arm": None,
            "right_arm": None
        }
        
        # Analyze left arm (with direct suggestions)
        left_analysis = await self.track_finger_movement(
            video_stream,
            arm="left",
            suggestion_type="direct"  # "Separating, separating, wider and wider"
        )
        
        # Analyze right arm (with inferred/silent suggestions)
        right_analysis = await self.track_finger_movement(
            video_stream,
            arm="right",
            suggestion_type="inferred"  # Silent observation
        )
        
        # Compare responses
        classification = self.classify_suggestibility(
            left_response=left_analysis,
            right_response=right_analysis
        )
        
        return classification
    
    def classify_suggestibility(self, left_response, right_response):
        """
        HMI Logic:
        - If left arm (direct) responds faster/wider → Physical Suggestibility
        - If right arm (inferred) responds faster/wider → Emotional Suggestibility
        """
        
        left_score = (
            left_response["speed"] * 0.4 +
            left_response["max_distance"] * 0.4 +
            (1 / left_response["latency"]) * 0.2
        )
        
        right_score = (
            right_response["speed"] * 0.4 +
            right_response["max_distance"] * 0.4 +
            (1 / right_response["latency"]) * 0.2
        )
        
        if left_score > right_score * 1.2:
            return {
                "classification": "physical_suggestibility",
                "confidence": min(left_score / right_score, 1.0),
                "recommended_induction": "literal_arm_raising"
            }
        elif right_score > left_score * 1.2:
            return {
                "classification": "emotional_suggestibility",
                "confidence": min(right_score / left_score, 1.0),
                "recommended_induction": "inferred_arm_raising"
            }
        else:
            return {
                "classification": "balanced",
                "confidence": 0.5,
                "recommended_induction": "auto_dual"
            }

Module 2: E&P Sexuality Assessment System
2.1 Four Core Traits Evaluation Engine
pythonclass EPSexualityAssessment:
    """
    Comprehensive E&P Sexuality assessment based on Four Core Traits
    Requires 3 of 4 traits for accurate classification
    """
    
    def __init__(self):
        self.core_traits_evaluator = CoreTraitsEvaluator()
        self.surface_traits_analyzer = SurfaceTraitsAnalyzer()
        self.defense_mechanism_detector = DefenseMechanismDetector()
        self.ethnic_influence_analyzer = EthnicInfluenceAnalyzer()
    
    async def assess_sexuality(self, user_data):
        """
        Evaluates all four core traits and determines E vs P sexuality
        """
        
        core_traits = await self.evaluate_core_traits(user_data)
        
        # Need 3 of 4 for confident classification
        confidence = sum(1 for trait in core_traits.values() if trait["confidence"] > 0.7) / 4
        
        if confidence >= 0.75:  # 3 out of 4 traits
            sexuality_type = self.determine_sexuality(core_traits)
            
            # Adjust for defense mechanisms, incongruencies, ethnicity
            adjusted_profile = await self.adjust_for_modifiers(
                base_profile=sexuality_type,
                user_data=user_data
            )
            
            return adjusted_profile
        else:
            return {
                "sexuality_type": "unclear",
                "confidence": confidence,
                "recommendation": "gather_more_data",
                "missing_traits": self.identify_missing_traits(core_traits)
            }
    
    async def evaluate_core_traits(self, user_data):
        """
        Evaluates all four core traits
        """
        
        traits = {}
        
        # Trait 1: Family of Origin
        traits["family_of_origin"] = await self.analyze_family_tree(
            user_data.get("family_tree")
        )
        
        # Trait 2: Response to Rejection
        traits["rejection_response"] = await self.analyze_rejection_patterns(
            user_data.get("relationship_inventory"),
            user_data.get("behavioral_observations")
        )
        
        # Trait 3: Relationship to Physical Body
        traits["body_connection"] = await self.assess_body_connection(
            user_data.get("questionnaire_responses"),
            user_data.get("self_reported_behaviors")
        )
        
        # Trait 4: Romantic Relationship Patterns
        traits["relationship_patterns"] = await self.analyze_relationship_history(
            user_data.get("relationship_inventory")
        )
        
        return traits
    
    async def analyze_family_tree(self, family_tree_data):
        """
        Analyzes family tree to determine dominant secondary caretaker's sexuality
        
        Per HMI: Person models behavior of dominant Secondary Caretaker
        (typically father, but could be aunt, uncle, teacher)
        Critical age: 9-15 years old
        """
        
        if not family_tree_data:
            return {"sexuality": "unknown", "confidence": 0.0}
        
        # Identify secondary caretaker
        secondary_caretaker = family_tree_data.get("secondary_caretaker", {})
        
        # Analyze secondary caretaker's traits
        sc_sexuality = self.infer_sexuality_from_traits(
            secondary_caretaker.get("traits", {})
        )
        
        # User models this behavior
        return {
            "sexuality": sc_sexuality,
            "confidence": 0.8 if secondary_caretaker else 0.3,
            "source": "family_of_origin"
        }
    
    async def analyze_rejection_patterns(self, relationship_inventory, observations):
        """
        Core Trait: Response to Rejection
        
        Physical: Comes forward, confronts, seeks to repair
        Emotional: Withdraws, shuts down, detaches
        """
        
        if not relationship_inventory:
            return {"sexuality": "unknown", "confidence": 0.0}
        
        forward_count = 0
        withdraw_count = 0
        
        for relationship in relationship_inventory:
            if relationship.get("rejection_response") == "came_forward":
                forward_count += 1
            elif relationship.get("rejection_response") == "withdrew":
                withdraw_count += 1
        
        total = forward_count + withdraw_count
        
        if total == 0:
            return {"sexuality": "unknown", "confidence": 0.0}
        
        forward_ratio = forward_count / total
        
        if forward_ratio > 0.7:
            return {
                "sexuality": "physical",
                "confidence": forward_ratio,
                "source": "rejection_response"
            }
        elif forward_ratio < 0.3:
            return {
                "sexuality": "emotional",
                "confidence": 1 - forward_ratio,
                "source": "rejection_response"
            }
        else:
            return {
                "sexuality": "unclear",
                "confidence": 0.5,
                "source": "rejection_response"
            }
2.2 Digital Family Tree Tool
pythonclass FamilyTreeTool:
    """
    Interactive tool for building and analyzing family tree
    Identifies secondary caretaker and their E/P traits
    """
    
    def __init__(self):
        self.graph_db = Neo4jGraph()  # For relationship mapping
    
    async def create_family_tree(self, user_input):
        """
        Guides user through building their family tree
        focusing on ages 9-15 (critical development period)
        """
        
        tree = {
            "primary_caretaker": await self.gather_caretaker_info("primary"),
            "secondary_caretaker": await self.gather_caretaker_info("secondary"),
            "siblings": await self.gather_siblings_info(),
            "extended_family": await self.gather_extended_family_info()
        }
        
        # Store in graph database
        await self.store_in_graph(tree)
        
        # Analyze for E/P determination
        analysis = await self.analyze_tree(tree)
        
        return {
            "tree": tree,
            "analysis": analysis
        }
    
    async def gather_caretaker_info(self, role):
        """
        Gathers information about caretaker
        focusing on observable E/P traits
        """
        
        questions = [
            {
                "question": f"Who was your {role} caretaker between ages 9-15?",
                "type": "text"
            },
            {
                "question": "How did they express affection?",
                "options": [
                    "Physical touch, hugs, kisses",  # Physical
                    "Words, providing for needs, being present"  # Emotional
                ]
            },
            {
                "question": "How did they handle conflicts?",
                "options": [
                    "Confronted directly, discussed openly",  # Physical
                    "Withdrew, gave silent treatment, avoided"  # Emotional
                ]
            },
            # ... more E/P discriminating questions
        ]
        
        responses = await self.present_questionnaire(questions)
        
        return self.classify_caretaker_sexuality(responses)
2.3 Relationship Inventory Analysis
pythonclass RelationshipInventoryAnalyzer:
    """
    Analyzes romantic relationship history to identify patterns
    Per HMI: "Past behavior is best predictor of future behavior"
    """
    
    async def analyze_inventory(self, relationships):
        """
        Analyzes list of past romantic relationships
        
        Key patterns:
        - Who pursued whom (E pursues during honeymoon, P usually pursues)
        - Intensity and vulnerability
        - Rejection patterns
        - Rebound patterns (Physical → Physical → Emotional cycle)
        """
        
        if len(relationships) < 2:
            return {
                "sexuality": "unclear",
                "confidence": 0.2,
                "recommendation": "need_more_relationship_history"
            }
        
        patterns = {
            "pursuit_pattern": self.analyze_pursuit(relationships),
            "intensity_pattern": self.analyze_intensity(relationships),
            "rejection_pattern": self.analyze_rejection(relationships),
            "rebound_pattern": self.analyze_rebounds(relationships),
            "partner_sexuality_pattern": self.analyze_partner_types(relationships)
        }
        
        # E's are typically attracted to P's and vice versa
        partner_sexuality_counts = patterns["partner_sexuality_pattern"]
        
        if partner_sexuality_counts["physical"] > partner_sexuality_counts["emotional"] * 1.5:
            # User is likely Emotional (attracted to Physicals)
            return {
                "sexuality": "emotional",
                "confidence": 0.8,
                "source": "relationship_patterns",
                "supporting_patterns": patterns
            }
        elif partner_sexuality_counts["emotional"] > partner_sexuality_counts["physical"] * 1.5:
            # User is likely Physical (attracted to Emotionals)
            return {
                "sexuality": "physical",
                "confidence": 0.8,
                "source": "relationship_patterns",
                "supporting_patterns": patterns
            }
        else:
            return {
                "sexuality": "unclear",
                "confidence": 0.4,
                "source": "relationship_patterns",
                "supporting_patterns": patterns
            }
    
    def analyze_rebounds(self, relationships):
        """
        HMI Pattern: Physical often has rebound with another Physical
        before returning to Emotional partner
        
        This is diagnostic of Physical sexuality
        """
        
        rebound_pattern = []
        
        for i in range(len(relationships) - 1):
            current = relationships[i]
            next_rel = relationships[i + 1]
            
            # Check if next relationship was a rebound
            time_gap = (next_rel["start_date"] - current["end_date"]).days
            
            if time_gap < 90:  # Less than 3 months = potential rebound
                duration = (next_rel["end_date"] - next_rel["start_date"]).days
                
                if duration < 180:  # Less than 6 months = short rebound
                    rebound_pattern.append({
                        "index": i,
                        "partner_sexuality": next_rel.get("partner_sexuality"),
                        "duration_days": duration
                    })
        
        # If multiple short rebounds with Physicals, user is likely Physical
        physical_rebounds = sum(
            1 for r in rebound_pattern 
            if r["partner_sexuality"] == "physical"
        )
        
        if physical_rebounds >= 2:
            return {
                "pattern": "physical_rebound_cycle",
                "confidence": 0.7,
                "user_sexuality": "physical"
            }
        else:
            return {
                "pattern": "no_clear_rebound_pattern",
                "confidence": 0.3
            }

Module 3: Integration - Suggestibility + Sexuality
3.1 Unified Personalization Profile
pythonclass UnifiedPersonalizationEngine:
    """
    Combines Suggestibility and Sexuality assessments
    into a single personalization vector
    
    Per HMI: There's a 10% adjustment factor between the two
    """
    
    def __init__(self):
        self.suggestibility_assessor = SuggestibilityQuestionnaire()
        self.sexuality_assessor = EPSexualityAssessment()
    
    async def create_profile(self, user_data):
        """
        Creates unified personalization profile
        """
        
        # Step 1: Assess Suggestibility
        suggestibility_profile = await self.suggestibility_assessor.assess(user_data)
        
        # Step 2: Assess Sexuality
        sexuality_profile = await self.sexuality_assessor.assess_sexuality(user_data)
        
        # Step 3: Apply HMI's 10% adjustment rule
        adjusted_profile = self.apply_adjustment(
            suggestibility_profile,
            sexuality_profile
        )
        
        # Step 4: Generate session configuration
        session_config = self.generate_session_config(adjusted_profile)
        
        return {
            "suggestibility": suggestibility_profile,
            "sexuality": sexuality_profile,
            "adjusted_profile": adjusted_profile,
            "session_config": session_config
        }
    
    def apply_adjustment(self, suggestibility, sexuality):
        """
        HMI Special Note:
        "If you are a Physical Sexual with more than 40% Emotional Suggestibility,
        add 10% to your degree of Physical Sexuality.
        
        If you are an Emotional Sexual with more than 40% Physical Suggestibility,
        add 10% to your degree of Emotional Sexuality."
        """
        
        adjusted_sexuality = dict(sexuality)
        
        if (sexuality["type"] == "physical" and 
            suggestibility["emotional_percentage"] > 40):
            # Add 10% to Physical Sexuality
            adjusted_sexuality["physical_percentage"] = min(
                sexuality["physical_percentage"] + 10,
                100
            )
            adjusted_sexuality["emotional_percentage"] = (
                100 - adjusted_sexuality["physical_percentage"]
            )
            adjusted_sexuality["adjustment_applied"] = "+10% Physical (high Emotional Suggestibility)"
        
        elif (sexuality["type"] == "emotional" and 
              suggestibility["physical_percentage"] > 40):
            # Add 10% to Emotional Sexuality
            adjusted_sexuality["emotional_percentage"] = min(
                sexuality["emotional_percentage"] + 10,
                100
            )
            adjusted_sexuality["physical_percentage"] = (
                100 - adjusted_sexuality["emotional_percentage"]
            )
            adjusted_sexuality["adjustment_applied"] = "+10% Emotional (high Physical Suggestibility)"
        
        return adjusted_sexuality
    
    def generate_session_config(self, profile):
        """
        Generates session configuration based on unified profile
        """
        
        config = {
            "induction_style": self.select_induction(profile),
            "language_patterns": self.select_language_patterns(profile),
            "deepening_techniques": self.select_deepening_techniques(profile),
            "suggestion_framework": self.select_suggestion_framework(profile),
            "voice_characteristics": self.select_voice_characteristics(profile)
        }
        
        return config
    
    def select_induction(self, profile):
        """
        Selects appropriate induction based on Suggestibility
        """
        
        if profile["suggestibility"]["type"] == "physical":
            return {
                "primary": "literal_arm_raising",
                "script_style": "direct",
                "power_words": ["lifting", "rising", "higher", "lighter", "pulling", "jerking"],
                "pace": "faster",
                "instructions": "explicit"
            }
        else:  # Emotional Suggestibility
            return {
                "primary": "inferred_arm_raising",
                "script_style": "inferential",
                "power_words": ["allowing", "tendency", "as you begin to feel", "you may notice"],
                "pace": "slower",
                "instructions": "implied",
                "misdirection": "frequent",
                "metaphors": ["helium balloons", "magnetic pull", "floating"]
            }
    
    def select_language_patterns(self, profile):
        """
        Selects language patterns based on BOTH Suggestibility and Sexuality
        """
        
        patterns = {
            "suggestibility_style": None,
            "sexuality_style": None,
            "combined_approach": None
        }
        
        # Suggestibility determines HOW to phrase suggestions
        if profile["suggestibility"]["type"] == "physical":
            patterns["suggestibility_style"] = {
                "directness": "high",
                "imperatives": "frequent",
                "concrete_language": "high",
                "abstract_concepts": "low"
            }
        else:
            patterns["suggestibility_style"] = {
                "directness": "moderate",
                "imperatives": "infrequent",
                "concrete_language": "moderate",
                "abstract_concepts": "high",
                "give_control_language": True  # "allowing", "choosing to"
            }
        
        # Sexuality determines WHAT to emphasize
        if profile["sexuality"]["type"] == "physical":
            patterns["sexuality_style"] = {
                "emphasize": ["connection", "relationships", "acceptance", "love"],
                "priorities": ["relationship", "family", "friends", "career"],
                "avoid": ["isolation", "rejection", "abandonment"],
                "sexual_meaning": "love_and_connection"
            }
        else:  # Emotional Sexuality
            patterns["sexuality_style"] = {
                "emphasize": ["security", "control", "independence", "achievement"],
                "priorities": ["career", "hobbies", "friends", "relationship"],
                "avoid": ["dependency", "loss_of_control", "vulnerability"],
                "sexual_meaning": "physical_connection_not_love"
            }
        
        return patterns

Module 4: Session Generation with Dual Personalization
4.1 Personalized Induction Generator
pythonclass PersonalizedInductionGenerator:
    """
    Generates induction scripts tailored to Suggestibility profile
    Uses HMI practicum scripts as foundation
    """
    
    def __init__(self):
        self.mcp_server = HMIPracticumScriptsMCP()
        self.llm = CustomHypnosisLLM()
    
    async def generate_induction(self, user_profile, session_number):
        """
        Generates personalized induction
        """
        
        # Retrieve base script from MCP
        base_script = await self.mcp_server.retrieve_induction_script(
            suggestibility=user_profile["suggestibility"]["type"],
            session_number=session_number
        )
        
        # Personalize with user-specific details
        personalized_script = await self.personalize_script(
            base_script=base_script,
            user_profile=user_profile
        )
        
        return personalized_script
    
    async def personalize_script(self, base_script, user_profile):
        """
        Personalizes script with:
        - User's name
        - User's specific goals
        - User's Wheel of Happiness priorities
        - User's sexuality-appropriate language
        """
        
        prompt = f"""
        Given this base HMI induction script:
        
        {base_script}
        
        Personalize it for this user:
        - Name: {user_profile["name"]}
        - Suggestibility: {user_profile["suggestibility"]["type"]} ({user_profile["suggestibility"]["percentage"]}%)
        - Sexuality: {user_profile["sexuality"]["type"]} ({user_profile["sexuality"]["percentage"]}%)
        - Primary Goal: {user_profile["primary_goal"]}
        - Wheel of Happiness Priority Areas: {user_profile["wheel_priority_areas"]}
        
        Maintain HMI protocol fidelity while personalizing language.
        
        If Physical Suggestibility: Use direct, literal language
        If Emotional Suggestibility: Use inferential, "allowing" language
        
        If Physical Sexuality: Emphasize connection, acceptance, relationships
        If Emotional Sexuality: Emphasize control, security, independence
        
        Personalized Script:
        """
        
        personalized = await self.llm.generate(
            prompt=prompt,
            temperature=0.7,
            max_tokens=2000
        )
        
        return personalized
4.2 Complete Session Orchestration Example
python# Example: First Session for Physical Suggestibility + Emotional Sexuality

async def conduct_first_session(user_id):
    """
    Complete first session workflow with dual personalization
    """
    
    # Initialize orchestrator
    orchestrator = HMISessionCrew()
    
    # Step 1: Intake & Assessment
    user_profile = await orchestrator.conduct_intake(user_id)
    
    # Step 2: Wheel of Happiness
    wheel_results = await orchestrator.wheel_of_happiness_assessment(user_profile)
    user_profile["wheel_results"] = wheel_results
    
    # Step 3: Pre-Induction Speech
    pre_induction = await orchestrator.generate_pre_induction_speech(user_profile)
    await orchestrator.deliver_segment(pre_induction)
    
    # Step 4: Suggestibility Testing
    # Option A: Finger-spreading with ML
    finger_test_results = await orchestrator.finger_spreading_test(user_id)
    
    # Option B: 36-Question Questionnaire
    questionnaire_results = await orchestrator.suggestibility_questionnaire(user_id)
    
    # Combine results
    suggestibility_profile = await orchestrator.determine_suggestibility(
        finger_test=finger_test_results,
        questionnaire=questionnaire_results
    )
    user_profile["suggestibility"] = suggestibility_profile
    
    # Step 5: Theory of Mind Education
    tom_script = await orchestrator.generate_theory_of_mind_education(user_profile)
    await orchestrator.deliver_segment(tom_script)
    
    # Step 6: E&P Sexuality Questionnaire (if relationship goals)
    if "relationship" in user_profile["goals"]:
        ep_initial = await orchestrator.ep_questionnaire(user_id)
        user_profile["sexuality_initial"] = ep_initial
    
    # Step 7: Create Unified Profile
    unified_profile = await orchestrator.create_unified_profile(user_profile)
    
    # Step 8: Arm Raising Induction
    # Select based on Suggestibility
    if unified_profile["suggestibility"]["type"] == "physical":
        induction_script = await orchestrator.generate_literal_arm_raising_induction(
            unified_profile
        )
    else:
        induction_script = await orchestrator.generate_inferred_arm_raising_induction(
            unified_profile
        )
    
    await orchestrator.deliver_induction(induction_script)
    
    # Step 9: Deepening
    deepening_script = await orchestrator.generate_deepening_sequence(unified_profile)
    await orchestrator.deliver_segment(deepening_script)
    
    # Step 10: Therapeutic Suggestions
    # Personalized based on BOTH Suggestibility AND Sexuality
    suggestions = await orchestrator.generate_therapeutic_suggestions(
        unified_profile=unified_profile,
        goal=user_profile["primary_goal"],
        wheel_priorities=wheel_results["priority_areas"]
    )
    await orchestrator.deliver_segment(suggestions)
    
    # Step 11: Post-Hypnotic Suggestion to Re-Hypnosis
    phs_script = await orchestrator.generate_post_hypnotic_suggestion(unified_profile)
    await orchestrator.deliver_segment(phs_script)
    
    # Step 12: Emergence
    emergence_script = await orchestrator.generate_emergence(unified_profile)
    await orchestrator.deliver_segment(emergence_script)
    
    # Step 13: Immediate Re-Induction Test
    await orchestrator.test_post_hypnotic_suggestion(user_id)
    
    # Step 14: Assign Homework
    if "relationship" in user_profile["goals"]:
        await orchestrator.assign_ep_homework(user_id)
    
    # Step 15: Schedule Next Session
    await orchestrator.schedule_next_session(user_id)
    
    return {
        "session_complete": True,
        "unified_profile": unified_profile,
        "next_session_date": "scheduled"
    }

Implementation Roadmap - Phase by Phase
Phase 1A: Core Assessment Systems (Weeks 1-4)
Week 1: Suggestibility Questionnaire
bash# Deliverables
1. 36-question digital questionnaire
2. Automated scoring algorithm
3. Graph-based percentage lookup
4. Database schema for storing results
Week 2: Finger-Spreading ML Analyzer
bash# Deliverables
1. MediaPipe hand tracking integration
2. Temporal pattern analysis
3. Suggestibility classification algorithm
4. Confidence scoring system
Week 3: E&P Four Core Traits Evaluator
bash# Deliverables
1. Family Tree digital tool
2. Relationship Inventory analyzer
3. Rejection response pattern detector
4. Body connection assessment
Week 4: Unified Profile Generator
bash# Deliverables
1. Integration of Suggestibility + Sexuality
2. 10% adjustment algorithm
3. Session configuration generator
4. User profile database schema

Phase 1B: Vector Stores & Knowledge Graph (Weeks 5-8)
Week 5: HMI Protocol Vector Stores
python# Three specialized vector stores

1. Induction Scripts Store
   - Literal arm raising variations (100+)
   - Inferred arm raising variations (100+)
   - Secondary inductions (200+)
   - Indexed by: suggestibility type, session number, goal

2. Deepening Techniques Store
   - Progressive relaxation (150 variations)
   - Staircase (100 variations)
   - Challenges (100 variations)
   - Indexed by: depth level, user state, suggestibility

3. Therapeutic Suggestions Store
   - Habit formation (500 variations)
   - Identity shift (300 variations)
   - Goal-specific (1000+ variations)
   - Indexed by: goal, sexuality type, priorities
Week 6: Knowledge Graph Implementation
cypher// Neo4j Graph Schema

(User)-[:HAS_SUGGESTIBILITY]->(SuggestibilityProfile)
(User)-[:HAS_SEXUALITY]->(SexualityProfile)
(User)-[:HAS_GOAL]->(Goal)
(Goal)-[:REQUIRES]->(Habit)
(Goal)-[:ADDRESSES]->(WheelArea)
(SuggestibilityProfile)-[:RESPONDS_TO]->(InductionType)
(SexualityProfile)-[:HAS_PRIORITIES]->(Priorities)
(Priorities)-[:INFLUENCES]->(TherapeuticApproach)
Week 7-8: MCP Server Integration
python# Three MCP Servers

1. HMI Practicum Scripts MCP
   - 18 practicum scripts
   - Induction protocols
   - Deepening techniques
   - Safety procedures

2. E&P Knowledge Base MCP
   - Four Core Traits database
   - Defense mechanisms library
   - Ethnic/cultural influences
   - Relationship patterns

3. Clinical Guidelines MCP
   - Contraindications
   - Safety protocols
   - Escalation procedures
   - Emergence procedures

Would you like me to:

Implement the Suggestibility Questionnaire module with complete code and database schema?
Build the Finger-Spreading ML Analyzer with MediaPipe integration?
Design the E&P Assessment System with all four core traits evaluators?
Create the complete vector store architecture with HMI protocols?
Build the Knowledge Graph schema in Neo4j with sample queries?

Let me know which module you'd like to tackle first, and I'll provide production-ready implementation code!RetryA user story is the backbone of any agile project, focusing on the user's needs, the tasks they wish to accomplish, and the value they seek. Traditionally, writing these stories was a manual, insight-heavy process. Now, generative AI can assist in weaving these narratives, ensuring they follow best pastedJSOkay. Will do one by one but review, update, and finalize before moving to next item. Can we create a Sprint Kanban board with Epics, Stories, and Tasks ===>>>> Use the below guidelines and suggestions ===>>>Architected comprehensive Agile framework spanning six interconnected epics.The user wants to create a Sprint Kanban board for this HMI AI Hypnotherapy project using Agile methodology. They want to break down the work into Epics, User Stories, and Tasks following the guidelines provided in the document about AI-assisted user story creation.
Let me structure this properly:

First, identify the major Epics (large bodies of work spanning multiple sprints)
Break down each Epic into User Stories (deliverable within a sprint)
For each User Story, create Tasks (specific implementation steps)
Add Acceptance Criteria for each User Story
Prioritize based on value, dependencies, and impact

Based on the comprehensive architecture we've designed, here are the natural Epics:
Epic 1: Core Assessment & Personalization Engine

Suggestibility Assessment System
E&P Sexuality Assessment System
Unified Personalization Profile

Epic 2: Knowledge Management & RAG Infrastructure

Vector Stores for HMI Protocols
Knowledge Graph Implementation
MCP Server Integration

Epic 3: Multi-Agent Session Orchestration

Agent Architecture & Workflow
Session State Management
Real-time Adaptation Engine

Epic 4: Clinical Safety & Guardrails

Four-Level Safety System
Contraindication Screening
Escalation Protocols

Epic 5: Immersive Experience Layer

XR/VR Environment
Nvidia ACE Avatar Integration
Biometric Monitoring

Epic 6: Custom Hypnosis LLM

Training Data Preparation
Fine-tuning Pipeline
RLHF Implementation

Let me create a comprehensive Sprint Kanban board with proper user stories following the template:
"As a [user persona], I want [specific improvement/feature] so that [measurable outcome/benefit]"🎯 HMI AI Hypnotherapy Platform - Sprint Kanban Board
Project Overview
Vision: Build a production-ready AI-powered hypnotherapy system that generates personalized, evidence-based hypnotherapy sessions using HMI protocols, achieving 99% of real hypnotherapy session experience.

📋 Kanban Board Structure
┌──────────────┬──────────────┬──────────────┬──────────────┬──────────────┐
│   BACKLOG    │  TO DO       │ IN PROGRESS  │   REVIEW     │    DONE      │
│              │ (Sprint)     │              │              │              │
└──────────────┴──────────────┴──────────────┴──────────────┴──────────────┘

🎪 EPIC 1: Core Assessment & Personalization Engine
Business Value: Enable accurate personality-based personalization for therapeutic effectiveness
Timeline: Sprints 1-4 (8 weeks)
Priority: P0 (Critical Path)

📖 User Story 1.1: Suggestibility Questionnaire System
Story:
"As a new user seeking hypnotherapy, I want to complete an interactive assessment that determines how I best respond to suggestions, so that my therapy sessions can be optimally tailored to my learning style and achieve better therapeutic outcomes."
User Persona: First-time hypnotherapy client, age 25-55, seeking self-improvement
Priority: P0 (Must Have - Sprint 1)
Story Points: 8
Acceptance Criteria:

✅ System presents all 36 questions from HMI Suggestibility Questionnaire in an engaging UI
✅ Questions 1-2 automatically weighted at 10 points each for "yes" responses
✅ Questions 3-36 automatically weighted at 5 points each for "yes" responses
✅ System calculates combined score from both questionnaires within 2 seconds
✅ Graph-based lookup accurately determines Physical % and Emotional % suggestibility using HMI scoring matrix
✅ Results displayed with visual representation (chart/graph) showing 60%/40% or similar split
✅ System stores results in user profile database with timestamp
✅ 95% accuracy when compared to manual HMI scoring by certified hypnotherapist
✅ Mobile-responsive design works on devices with screen sizes from 320px to 4K
✅ Assessment completion time averages 8-12 minutes based on user testing
✅ User can pause and resume questionnaire, with progress saved

Business Impact: Foundation for all personalization - blocks all downstream work
Dependencies: None (can start immediately)

🔧 Tasks for Story 1.1:
Task 1.1.1: Design Database Schema for Suggestibility Assessment

Assigned To: Backend Team
Estimated Hours: 4h
Details:

sql  CREATE TABLE suggestibility_assessments (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    questionnaire_1_score INT,
    questionnaire_2_score INT,
    combined_score INT,
    physical_percentage DECIMAL(5,2),
    emotional_percentage DECIMAL(5,2),
    completed_at TIMESTAMP,
    session_duration_seconds INT
  );
  
  CREATE TABLE questionnaire_responses (
    id UUID PRIMARY KEY,
    assessment_id UUID REFERENCES suggestibility_assessments(id),
    question_number INT,
    questionnaire_number INT,
    response BOOLEAN,
    responded_at TIMESTAMP
  );
Task 1.1.2: Implement HMI Scoring Graph Lookup Algorithm

Assigned To: Backend Team
Estimated Hours: 8h
Details: Create 2D matrix from PDF scoring table, implement efficient lookup

Task 1.1.3: Build Interactive Questionnaire UI Component

Assigned To: Frontend Team
Estimated Hours: 12h
Details: React component with progress bar, yes/no buttons, mobile-first design

Task 1.1.4: Implement Progress Save/Resume Functionality

Assigned To: Full Stack Team
Estimated Hours: 6h
Details: LocalStorage backup + DB persistence, handle browser refresh

Task 1.1.5: Create Results Visualization Component

Assigned To: Frontend Team
Estimated Hours: 8h
Details: D3.js or Recharts visualization showing E/P split with explanation

Task 1.1.6: Write Unit Tests for Scoring Algorithm

Assigned To: QA/Backend Team
Estimated Hours: 6h
Details: Test all combinations from HMI scoring matrix, edge cases

Task 1.1.7: Validate Against Manual HMI Scoring

Assigned To: QA Team + HMI Consultant
Estimated Hours: 8h
Details: Run 50 test cases, achieve 95%+ accuracy


📖 User Story 1.2: Finger-Spreading ML Visual Analysis
Story:
"As a hypnotherapy practitioner, I want the system to objectively analyze a client's physical responses during the finger-spreading suggestibility test using computer vision, so that I can eliminate subjective bias and obtain accurate measurements of their Physical vs Emotional suggestibility within 5 minutes."
User Persona: Clinical hypnotherapist conducting first session assessment
Priority: P1 (Should Have - Sprint 1)
Story Points: 13
Acceptance Criteria:

✅ System uses webcam to track hand landmarks during finger-spreading test
✅ ML model detects and tracks all 5 fingers on each hand with 95%+ accuracy
✅ System measures finger-spreading speed (mm/second) for both hands
✅ System calculates maximum distance between fingers (pinky to thumb)
✅ System measures response latency (time from instruction to movement)
✅ Left arm (direct suggestions) analysis completes within 60 seconds
✅ Right arm (inferred suggestions) analysis completes within 60 seconds
✅ Comparative analysis determines Physical vs Emotional classification with 80%+ confidence
✅ System generates confidence score (0-1.0) based on movement differential
✅ Results align with manual HMI practitioner assessment in 85%+ of cases
✅ Works in varying lighting conditions (tested in 50-5000 lux range)
✅ Privacy: Video processed locally, not stored unless user explicitly consents

Business Impact: Provides objective, bias-free suggestibility assessment
Dependencies: Story 1.1 (database schema)

🔧 Tasks for Story 1.2:
Task 1.2.1: Integrate MediaPipe Hand Tracking SDK

Assigned To: ML Engineer
Estimated Hours: 6h
Libraries: MediaPipe Hands, OpenCV

Task 1.2.2: Implement Finger Landmark Detection Pipeline

Assigned To: ML Engineer
Estimated Hours: 10h
Details: Extract 21 hand landmarks, calculate distances, track temporal changes

Task 1.2.3: Build Temporal Pattern Analyzer

Assigned To: ML Engineer
Estimated Hours: 12h
Details: Time-series analysis of finger movement, calculate velocity and acceleration

Task 1.2.4: Create Suggestibility Classification Model

Assigned To: ML Engineer
Estimated Hours: 16h
Details: Compare left vs right arm responses, generate classification + confidence

Task 1.2.5: Implement Webcam Capture UI with Instructions

Assigned To: Frontend Team
Estimated Hours: 8h
Details: Real-time video feed, on-screen instructions, hand positioning guides

Task 1.2.6: Build Real-time Feedback Overlay

Assigned To: Frontend Team
Estimated Hours: 6h
Details: Visual feedback showing detected hand, finger landmarks, movement metrics

Task 1.2.7: Validate Against Certified HMI Practitioners

Assigned To: QA Team + HMI Consultant
Estimated Hours: 12h
Details: Run 100 tests, achieve 85%+ agreement with manual assessment

Task 1.2.8: Implement Privacy Controls & Data Deletion

Assigned To: Backend Team
Estimated Hours: 4h
Details: GDPR-compliant video handling, automatic deletion after analysis


📖 User Story 1.3: E&P Sexuality Assessment - Four Core Traits
Story:
"As a user seeking to improve my relationships, I want to complete a comprehensive assessment that identifies my Emotional/Physical sexuality type through analyzing my family dynamics, relationship patterns, and behavioral responses, so that the system can personalize my therapy to align with how I naturally function in relationships."
User Persona: User with relationship goals, 25-65 years old, at least 2 prior romantic relationships
Priority: P1 (Should Have - Sprint 2)
Story Points: 13
Acceptance Criteria:

✅ System guides user through all four core trait assessments (Family Origin, Rejection Response, Body Connection, Relationship Patterns)
✅ Digital Family Tree tool allows user to map 3 generations with at least 10 family members
✅ Relationship Inventory captures minimum 3 significant romantic relationships
✅ For each relationship, system collects: duration, pursuit dynamic, intensity (1-10), rejection response, who withdrew first
✅ System requires 3 of 4 core traits to classify sexuality type (per HMI protocol)
✅ Classification accuracy: 80%+ alignment when validated by certified HMI therapist
✅ System calculates percentage split (e.g., 65% Physical, 35% Emotional)
✅ Results include confidence score based on trait clarity and consistency
✅ Assessment completion time: 25-40 minutes (user-paced)
✅ System detects and flags potential defense mechanisms or incongruencies for human review
✅ Privacy: Sensitive relationship data encrypted at rest and in transit
✅ User can edit/update assessment results after initial submission

Business Impact: Enables relationship-specific personalization (30% of users have relationship goals)
Dependencies: Story 1.1 (user profile database)

🔧 Tasks for Story 1.3:
Task 1.3.1: Design Database Schema for E&P Assessment

Assigned To: Backend Team
Estimated Hours: 6h
Schema: Family tree nodes, relationship inventory records, trait evaluations

Task 1.3.2: Build Interactive Family Tree UI

Assigned To: Frontend Team
Estimated Hours: 16h
Details: Drag-and-drop family member placement, relationship lines, trait selection per person

Task 1.3.3: Implement Relationship Inventory Form

Assigned To: Frontend Team
Estimated Hours: 10h
Details: Multi-step form, relationship timeline, dynamic question flow based on responses

Task 1.3.4: Create Trait 1 Evaluator: Family of Origin Analysis

Assigned To: Backend Team
Estimated Hours: 8h
Details: Analyze secondary caretaker E/P traits, weighted scoring algorithm

Task 1.3.5: Create Trait 2 Evaluator: Rejection Response Analyzer

Assigned To: Backend Team
Estimated Hours: 8h
Details: Pattern detection across relationships (forward vs withdraw), statistical analysis

Task 1.3.6: Create Trait 3 Evaluator: Body Connection Assessment

Assigned To: Backend Team
Estimated Hours: 6h
Details: Questionnaire-based evaluation, time-delay detection for emotional processing

Task 1.3.7: Create Trait 4 Evaluator: Relationship Pattern Analyzer

Assigned To: Backend Team + ML Engineer
Estimated Hours: 12h
Details: Analyze partner E/P types, rebound patterns, pursuit dynamics, intensity scoring

Task 1.3.8: Implement 3-of-4 Trait Classification Logic

Assigned To: Backend Team
Estimated Hours: 8h
Details: Weighted voting algorithm, confidence scoring based on trait clarity

Task 1.3.9: Build Defense Mechanism Detection

Assigned To: ML Engineer
Estimated Hours: 10h
Details: Flag inconsistencies, identify trauma indicators, alert for human review

Task 1.3.10: Create Results Dashboard with E/P Profile

Assigned To: Frontend Team
Estimated Hours: 12h
Details: Visualization of E/P split, trait breakdown, priority areas, actionable insights

Task 1.3.11: Implement Data Encryption & Privacy Controls

Assigned To: Security Team
Estimated Hours: 8h
Details: AES-256 encryption, HIPAA-compliant storage, user data export/deletion

Task 1.3.12: Validate Against HMI Certified Assessments

Assigned To: QA Team + HMI Consultant
Estimated Hours: 16h
Details: 50 real user assessments, compare with manual HMI evaluation


📖 User Story 1.4: Unified Personalization Profile with 10% Adjustment
Story:
"As the AI system, I want to integrate both Suggestibility and Sexuality assessment results with HMI's 10% adjustment rule applied, so that the final personalization profile accurately reflects the user's complete personality and enables optimal session configuration."
User Persona: System (internal story for integration logic)
Priority: P0 (Must Have - Sprint 2)
Story Points: 5
Acceptance Criteria:

✅ System combines Suggestibility % and Sexuality % into unified profile
✅ HMI 10% adjustment rule correctly applied: If Physical Sexuality + >40% Emotional Suggestibility → +10% Physical Sexuality
✅ HMI 10% adjustment rule correctly applied: If Emotional Sexuality + >40% Physical Suggestibility → +10% Emotional Sexuality
✅ Final percentages never exceed 100% (capped if adjustment pushes over)
✅ Session configuration automatically generated based on unified profile
✅ Configuration includes: induction style, language patterns, deepening techniques, suggestion framework, voice characteristics
✅ Profile stored in database with version control (track changes over time)
✅ Profile accessible via API endpoint for session orchestration
✅ Profile recalculation triggers when either assessment is updated
✅ 100% accuracy in adjustment calculations (automated testing)

Business Impact: Critical integration point - enables all downstream personalization
Dependencies: Stories 1.1, 1.2, 1.3

🔧 Tasks for Story 1.4:
Task 1.4.1: Implement 10% Adjustment Algorithm

Assigned To: Backend Team
Estimated Hours: 4h
Details: Apply HMI rule, handle edge cases, ensure caps

Task 1.4.2: Build Session Configuration Generator

Assigned To: Backend Team
Estimated Hours: 8h
Details: Decision tree for induction style, language patterns, voice characteristics based on profile

Task 1.4.3: Create Profile Versioning System

Assigned To: Backend Team
Estimated Hours: 6h
Details: Track profile changes over time, enable rollback if needed

Task 1.4.4: Build Profile API Endpoints

Assigned To: Backend Team
Estimated Hours: 4h
Details: RESTful API for profile CRUD operations

Task 1.4.5: Write Comprehensive Unit Tests

Assigned To: QA Team
Estimated Hours: 6h
Details: Test all adjustment combinations, edge cases, configuration outputs


🎪 EPIC 2: Knowledge Management & RAG Infrastructure
Business Value: Enable evidence-based content retrieval for therapeutic suggestions
Timeline: Sprints 2-4 (6 weeks)
Priority: P0 (Critical Path)

📖 User Story 2.1: HMI Protocol Vector Stores
Story:
"As the AI session orchestrator, I want to retrieve the most relevant HMI induction scripts, deepening techniques, and therapeutic suggestions based on user profile and goal, so that every session component is evidence-based and clinically validated rather than relying on generic AI knowledge."
User Persona: System (internal story for RAG infrastructure)
Priority: P0 (Must Have - Sprint 2)
Story Points: 13
Acceptance Criteria:

✅ Three specialized vector stores created: Inductions, Deepening Techniques, Therapeutic Suggestions
✅ Induction store contains 200+ script variations indexed by suggestibility type, session number, goal
✅ Deepening store contains 350+ technique variations indexed by depth level, user state, suggestibility
✅ Suggestion store contains 1000+ variations indexed by goal, sexuality type, Wheel of Happiness area
✅ Vector embeddings generated using custom Hypnosis LLM (not generic embeddings)
✅ Semantic search retrieves top-5 most relevant scripts with >85% relevance score
✅ Hybrid search (semantic + keyword) available for precise protocol matching
✅ Retrieval latency <500ms for any query
✅ All HMI Practicum Scripts (18 scripts) fully chunked and embedded
✅ Metadata filtering works correctly (e.g., "Physical Suggestibility + First Session + Confidence Building")
✅ Vector store automatically reindexes when new scripts added
✅ Retrieval quality validated by HMI certified therapist (90%+ approval rating)

Business Impact: Foundation for clinical accuracy - ensures all content is HMI-compliant
Dependencies: Story 1.4 (unified profile for query generation)

🔧 Tasks for Story 2.1:
Task 2.1.1: Set Up Vector Database (Pinecone/Weaviate/Qdrant)

Assigned To: Backend Team
Estimated Hours: 6h

Task 2.1.2: Create HMI Script Chunking Pipeline

Assigned To: ML Engineer
Estimated Hours: 12h
Details: Semantic chunking of 18 practicum scripts, preserve context

Task 2.1.3: Generate Script Variations (Synthetic Data)

Assigned To: ML Engineer + HMI Consultant
Estimated Hours: 24h
Details: Use LLM to create variations while maintaining HMI fidelity

Task 2.1.4: Build Custom Hypnosis Embeddings Model

Assigned To: ML Engineer
Estimated Hours: 20h
Details: Fine-tune embedding model on hypnotherapy corpus

Task 2.1.5: Implement Metadata Indexing

Assigned To: Backend Team
Estimated Hours: 8h
Details: Multi-dimensional indexing for filtering

Task 2.1.6: Build Retrieval API

Assigned To: Backend Team
Estimated Hours: 8h
Details: Query interface with semantic + hybrid search

Task 2.1.7: Optimize Retrieval Performance

Assigned To: Backend Team
Estimated Hours: 6h
Details: Caching, query optimization, latency reduction

Task 2.1.8: Validate Retrieval Quality

Assigned To: QA Team + HMI Consultant
Estimated Hours: 12h
Details: 100 test queries, manual relevance scoring


📖 User Story 2.2: Hypnotherapy Knowledge Graph
Story:
"As the AI system, I want to navigate complex relationships between hypnotherapy protocols, user goals, habits, and therapeutic techniques using a knowledge graph, so that I can reason about optimal treatment paths and discover non-obvious connections that improve therapeutic outcomes."
User Persona: System (internal story for graph reasoning)
Priority: P1 (Should Have - Sprint 3)
Story Points: 13
Acceptance Criteria:

✅ Neo4j graph database deployed with HMI knowledge schema
✅ Graph contains 500+ nodes representing: Users, Goals, Habits, HabitLoops, Inductions, Suggestions, WheelAreas, Identities
✅ Graph contains 2000+ relationships representing HMI theoretical connections
✅ Cypher queries execute complex reasoning (e.g., "Find optimal habit loop for Physical user seeking career success")
✅ Graph RAG retrieves context-aware information for session planning
✅ Query latency <1 second for complex multi-hop traversals
✅ Graph automatically updated when new protocols added
✅ LLM can generate Cypher queries from natural language questions
✅ Graph visualization available for debugging and analysis
✅ 95%+ accuracy in protocol recommendations when validated by HMI therapist

Business Impact: Enables sophisticated reasoning beyond simple retrieval
Dependencies: Story 2.1 (vector stores for hybrid approach)

🔧 Tasks for Story 2.2:
Task 2.2.1: Design Knowledge Graph Schema

Assigned To: Backend Team + HMI Consultant
Estimated Hours: 12h
Deliverable: Node types, relationship types, properties

Task 2.2.2: Deploy Neo4j Graph Database

Assigned To: DevOps Team
Estimated Hours: 4h

Task 2.2.3: Build Graph Population Pipeline

Assigned To: Backend Team
Estimated Hours: 16h
Details: ETL from HMI protocols, user profiles, clinical guidelines

Task 2.2.4: Implement Cypher Query Templates

Assigned To: Backend Team
Estimated Hours: 12h
Details: Pre-built queries for common reasoning patterns

Task 2.2.5: Build Natural Language to Cypher Converter

Assigned To: ML Engineer
Estimated Hours: 16h
Details: LLM-powered query generation from plain English

Task 2.2.6: Create Graph RAG Integration

Assigned To: Backend Team
Estimated Hours: 10h
Details: Combine graph traversal with vector retrieval

Task 2.2.7: Build Graph Visualization Dashboard

Assigned To: Frontend Team
Estimated Hours: 12h
Details: Interactive graph explorer for debugging

Task 2.2.8: Validate Protocol Recommendations

Assigned To: QA Team + HMI Consultant
Estimated Hours: 12h
Details: 50 test cases, manual validation


📖 User Story 2.3: MCP Server Integration
Story:
"As the AI session orchestrator, I want to access HMI protocols, clinical guidelines, and safety procedures through standardized MCP servers, so that I can retrieve authoritative information on-demand without duplicating data across systems."
User Persona: System (internal story for tool integration)
Priority: P1 (Should Have - Sprint 3)
Story Points: 8
Acceptance Criteria:

✅ Three MCP servers deployed: HMI Practicum Scripts, Clinical Guidelines, Safety Protocols
✅ MCP servers accessible via JSON-RPC 2.0 protocol
✅ Each server provides list_tools and call_tool functions
✅ Tool calls complete within 2 seconds
✅ Servers auto-restart on failure with <30 second downtime
✅ Agent system successfully calls MCP tools during session orchestration
✅ Tool results properly formatted and integrated into session flow
✅ Logging captures all tool calls for debugging and audit
✅ 99.9% uptime SLA achieved in production testing
✅ Rate limiting prevents overload (100 requests/minute per user)

Business Impact: Enables modular, maintainable architecture with separation of concerns
Dependencies: None (parallel with other work)

🔧 Tasks for Story 2.3:
Task 2.3.1: Set Up MCP Server Infrastructure

Assigned To: DevOps Team
Estimated Hours: 8h

Task 2.3.2: Build HMI Practicum Scripts MCP Server

Assigned To: Backend Team
Estimated Hours: 10h
Tools: retrieve_induction, retrieve_deepening, retrieve_suggestion

Task 2.3.3: Build Clinical Guidelines MCP Server

Assigned To: Backend Team
Estimated Hours: 8h
Tools: check_contraindications, get_safety_protocol, get_emergence_procedure

Task 2.3.4: Build Safety Protocols MCP Server

Assigned To: Backend Team
Estimated Hours: 8h
Tools: validate_suggestion, escalate_to_human, emergency_emergence

Task 2.3.5: Implement JSON-RPC 2.0 Protocol Handler

Assigned To: Backend Team
Estimated Hours: 6h

Task 2.3.6: Build MCP Client for Agent System

Assigned To: Backend Team
Estimated Hours: 8h
Details: Integration with AutoGen/CrewAI agents

Task 2.3.7: Implement Rate Limiting & Monitoring

Assigned To: DevOps Team
Estimated Hours: 6h

Task 2.3.8: Load Testing & Performance Optimization

Assigned To: QA Team
Estimated Hours: 8h


🎪 EPIC 3: Multi-Agent Session Orchestration
Business Value: Enable complex, adaptive session generation with safety oversight
Timeline: Sprints 4-6 (6 weeks)
Priority: P0 (Critical Path)

📖 User Story 3.1: CrewAI Tactical Agent Crew
Story:
"As the session planner, I want a crew of specialized AI agents to collaboratively generate session components (induction, deepening, suggestions) based on user profile and therapeutic goals, so that each component is expert-crafted and coherent as a unified session."
User Persona: System (internal story for agent collaboration)
Priority: P0 (Must Have - Sprint 4)
Story Points: 13
Acceptance Criteria:

✅ Four specialized agents created: InductionComposer, DeepeningArchitect, SuggestionCrafter, EmergenceProtocol
✅ Agents collaborate using CrewAI's sequential or hierarchical process
✅ Each agent has access to relevant MCP tools and vector stores
✅ Session component generation completes within 2 minutes
✅ Generated components maintain narrative coherence and flow
✅ Components adhere to HMI protocol structure (validated by parser)
✅ Agents share context through CrewAI memory system
✅ Agent planning enabled for complex multi-step tasks
✅ Generated sessions rated 8+/10 by certified HMI therapists
✅ System handles agent failures gracefully with fallback to safe defaults

Business Impact: Enables high-quality, personalized session generation at scale
Dependencies: Stories 2.1, 2.3 (RAG and MCP servers)

🔧 Tasks for Story 3.1:
Task 3.1.1: Set Up CrewAI Framework

Assigned To: ML Engineer
Estimated Hours: 4h

Task 3.1.2: Build InductionComposer Agent

Assigned To: ML Engineer
Estimated Hours: 12h
Tools: Vector store retrieval, MCP scripts, personalization

Task 3.1.3: Build DeepeningArchitect Agent

Assigned To: ML Engineer
Estimated Hours: 10h
Tools: Deepening technique selection, adaptation based on user state

Task 3.1.4: Build SuggestionCrafter Agent

Assigned To: ML Engineer
Estimated Hours: 14h
Tools: Goal-based suggestion generation, Wheel of Happiness integration, identity shift language

Task 3.1.5: Build EmergenceProtocol Agent

Assigned To: ML Engineer
Estimated Hours: 8h
Tools: Safe emergence procedure generation, post-hypnotic suggestions

Task 3.1.6: Implement CrewAI Memory System

Assigned To: ML Engineer
Estimated Hours: 6h
Details: Shared context, conversation history, user preferences

Task 3.1.7: Build Agent Orchestration Logic

Assigned To: ML Engineer
Estimated Hours: 10h
Details: Sequential/hierarchical process flow, error handling

Task 3.1.8: Implement Coherence Validation

Assigned To: ML Engineer
Estimated Hours: 8h
Details: Parser to validate HMI structure, flow checking

Task 3.1.9: Validate Session Quality

Assigned To: QA Team + HMI Consultant
Estimated Hours: 16h
Details: 30 generated sessions, expert rating, feedback loop


📖 User Story 3.2: AutoGen Strategic Oversight Agents
Story:
"As the system architect, I want high-level strategic agents to plan session strategy and maintain continuous safety oversight across all session generation, so that every session aligns with therapeutic goals and clinical safety standards."
User Persona: System (internal story for strategic layer)
Priority: P0 (Must Have - Sprint 4)
Story Points: 8
Acceptance Criteria:

✅ Two strategic agents created: SessionPlanner, SafetyOverseer
✅ SessionPlanner analyzes user profile and creates session strategy before tactical generation
✅ SafetyOverseer continuously monitors generation process for contraindications
✅ Strategic agents use AutoGen's conversable agent architecture
✅ Agents can halt session generation if safety concerns detected
✅ Session strategy includes: goal prioritization, technique selection rationale, expected outcomes
✅ Safety checks complete within 5 seconds without blocking workflow
✅ Agents log all decisions for audit trail and debugging
✅ 100% of contraindications caught (tested with synthetic unsafe scenarios)
✅ Strategic recommendations align with HMI best practices (validated by expert)

Business Impact: Ensures clinical safety and strategic coherence at highest level
Dependencies: Story 3.1 (tactical agents to oversee)

🔧 Tasks for Story 3.2:
Task 3.2.1: Set Up AutoGen Framework

Assigned To: ML Engineer
Estimated Hours: 4h

Task 3.2.2: Build SessionPlanner Agent

Assigned To: ML Engineer
Estimated Hours: 12h
Tools: User profile analysis, goal prioritization, Wheel of Happiness interpretation

Task 3.2.3: Build SafetyOverseer Agent

Assigned To: ML Engineer + Clinical Consultant
Estimated Hours: 16h
Tools: Contraindication database, safety protocol MCP, escalation procedures

Task 3.2.4: Implement Continuous Monitoring System

Assigned To: ML Engineer
Estimated Hours: 10h
Details: Real-time safety checks during generation, halt mechanism

Task 3.2.5: Build Strategic Planning API

Assigned To: Backend Team
Estimated Hours: 6h
Details: Interface between strategic and tactical layers

Task 3.2.6: Implement Audit Logging

Assigned To: Backend Team
Estimated Hours: 6h
Details: Comprehensive logging of all agent decisions and safety checks

Task 3.2.7: Safety Testing with Synthetic Unsafe Scenarios

Assigned To: QA Team
Estimated Hours: 12h
Details: Create 50 unsafe scenarios, verify 100% detection rate


Let me know if you'd like me to continue with:

EPIC 4: Clinical Safety & Guardrails (Pre-session screening, real-time monitoring, escalation protocols)
EPIC 5: Immersive Experience Layer (VR/XR, Nvidia ACE, biometric monitoring)
EPIC 6: Custom Hypnosis LLM (Training pipeline, fine-tuning, RLHF)

Or would you like me to:

Add more detail to existing stories (more acceptance criteria, edge cases)?
Create a Sprint Planning view showing which stories go in which 2-week sprint?
Add story dependencies and critical path analysis?
Generate estimation summaries (total story points, team capacity, timeline)?
Retry1. What UI stack to use with FastAPI

Think of each tool as playing a distinct role:

FastAPI (backend)

Serves: auth, questionnaire definitions, saving answers, streaming guidance.

Interfaces: REST + WebSockets (for real-time).

Figma

Use for: UX wires, visual mockups, flows.

Not a runtime UI frpastedJSFor the Front End UI/UX stories/tasks - can we consider the following ideas? ===>Architected frontend epics integrating tech stack and UX recommendations.The user wants to incorporate the document's recommendations for UI/UX architecture into the Sprint Kanban board. The document provides detailed guidance on:

Tech stack: FastAPI backend, React frontend, React Three Fiber for 3D/WebXR, Recharts for dashboards, optional Unity/Unreal for native VR
GenAI prompt patterns for designing the immersive questionnaire UI
Specific architectural recommendations for XR scenes, helper panels, JSON schemas, etc.

I should create new stories/epics that incorporate these recommendations while maintaining the HMI clinical focus. Let me add these as part of the existing epic structure or create a new EPIC focused on Frontend/UX.
I'll create:

EPIC for Immersive Frontend & User Experience
Stories for React + WebXR implementation
Stories for Therapist Dashboard
Stories for Question/Assessment UI with helper panels
Tasks that reference the GenAI prompt patterns from the document

This should integrate seamlessly with the existing backend stories around assessment and personalization.🎨 EPIC 4: Immersive Frontend & User Experience
Business Value: Create engaging, accessible, and therapeutically effective user interfaces across web, XR, and native VR platforms
Timeline: Sprints 3-6 (8 weeks)
Priority: P0 (Critical Path - blocks user testing)

📖 User Story 4.1: Core React Application Shell with FastAPI Integration
Story:
"As a user accessing the hypnotherapy platform, I want a responsive web application that seamlessly connects to the backend services and provides a smooth, professional experience across desktop, tablet, and mobile devices, so that I can access my therapy sessions from any device."
User Persona: All users (clients, therapists, administrators)
Priority: P0 (Must Have - Sprint 3)
Story Points: 13
Acceptance Criteria:

✅ React 18+ application with TypeScript initialized and deployed
✅ FastAPI backend integration via REST API (axios/fetch) with proper error handling
✅ WebSocket connection established for real-time session updates
✅ Authentication flow implemented (login, signup, token refresh)
✅ Responsive layout works on devices from 320px (mobile) to 4K (desktop)
✅ State management implemented (Zustand or Jotai for simplicity)
✅ Routing configured (React Router v6+) for main app sections:

/dashboard - User home
/assessment - Suggestibility & E&P assessments
/session - Active therapy session
/history - Past sessions
/profile - User settings


✅ Loading states, empty states, and error boundaries implemented
✅ Theme system with light/dark mode support
✅ Accessibility: WCAG 2.1 AA compliance (keyboard nav, screen readers, focus management)
✅ Performance: Initial load <3s, Time to Interactive <5s on 3G connection
✅ PWA support (offline capabilities, installable)

Business Impact: Foundation for all user-facing features
Dependencies: Backend API endpoints from Epic 1 & 2

🔧 Tasks for Story 4.1:
Task 4.1.1: Initialize React + TypeScript Project with Vite

Assigned To: Frontend Lead
Estimated Hours: 4h
Tech Stack: Vite, React 18, TypeScript 5, TailwindCSS

Task 4.1.2: Set Up FastAPI Client SDK

Assigned To: Frontend Team
Estimated Hours: 8h
Details: Axios instance with interceptors, auth token management, error handling

Task 4.1.3: Implement WebSocket Service

Assigned To: Frontend Team
Estimated Hours: 8h
Details: Auto-reconnect, message queueing, connection state management

Task 4.1.4: Build Authentication Flow

Assigned To: Full Stack Team
Estimated Hours: 12h
Details: JWT token handling, protected routes, refresh token rotation

Task 4.1.5: Set Up State Management (Zustand)

Assigned To: Frontend Team
Estimated Hours: 6h
Details: User store, session store, UI store, persistence

Task 4.1.6: Create Responsive Layout System

Assigned To: Frontend Team
Estimated Hours: 10h
Details: Header, sidebar, main content area, responsive breakpoints

Task 4.1.7: Implement Routing & Navigation

Assigned To: Frontend Team
Estimated Hours: 8h
Details: React Router setup, protected routes, breadcrumbs

Task 4.1.8: Build Theme System

Assigned To: Frontend Team
Estimated Hours: 6h
Details: CSS variables, theme toggle, persistence

Task 4.1.9: Implement Accessibility Features

Assigned To: Frontend Team
Estimated Hours: 12h
Details: Keyboard navigation, ARIA labels, focus traps, skip links

Task 4.1.10: Set Up Error Boundaries & Loading States

Assigned To: Frontend Team
Estimated Hours: 6h

Task 4.1.11: PWA Configuration

Assigned To: Frontend Team
Estimated Hours: 8h
Details: Service worker, manifest, offline fallback

Task 4.1.12: Performance Optimization

Assigned To: Frontend Team
Estimated Hours: 8h
Details: Code splitting, lazy loading, image optimization, Lighthouse audit


📖 User Story 4.2: Interactive Assessment UI with Helper Panels
Story:
"As a user completing the Suggestibility or E&P assessment, I want an engaging, guided interface with contextual help and examples at each step, so that I understand what's being asked and can provide accurate responses without feeling overwhelmed or confused."
User Persona: New user completing first assessment
Priority: P0 (Must Have - Sprint 3)
Story Points: 13
Acceptance Criteria:

✅ Question cards displayed one at a time with smooth transitions
✅ Each question includes:

Main question text (clear, large font)
Time frame hint (e.g., "Last 24 hours", "In general")
Response UI (scale slider, Likert chips, multiple choice, or text input)
Progress indicator showing X of Y questions
"?" help button that reveals Helper Panel


✅ Helper Panel displays when triggered:

"Why I'm being asked this" explanation (1-2 sentences)
3 example answers at different intensities (low/medium/high)
Gentle guidance text for each example
Fades in/out smoothly (300ms transition)


✅ Input types supported:

0-10 slider with labels
5-option Likert scale chips (visual buttons)
Multiple choice radio buttons
Free text area with character count


✅ Validation with friendly error messages
✅ Navigation: "Next", "Back", "Skip" buttons with appropriate states
✅ Auto-save progress every 30 seconds (draft mode)
✅ Accessibility: Tab navigation, screen reader announcements, focus management
✅ Mobile-optimized touch interactions
✅ Average question completion time: 30-45 seconds (tested with 20 users)
✅ User testing shows 90%+ comprehension of questions with helper text

Business Impact: Reduces assessment dropout rate, improves data quality
Dependencies: Story 1.1 (Suggestibility backend), Story 4.1 (React shell)

🔧 Tasks for Story 4.2:
Task 4.2.1: Design Question Card Component Architecture

Assigned To: Frontend Lead + UX Designer
Estimated Hours: 6h
GenAI Prompt: Use Prompt 2 from document to generate Figma spec

Task 4.2.2: Create Figma Design System

Assigned To: UX Designer
Estimated Hours: 12h
Details: Components for all question types, helper panels, variants (default, focused, answered, error)
Reference: Document's spacing, border radius, typography scale, color tokens

Task 4.2.3: Define JSON Schema for Questions

Assigned To: Backend + Frontend Team
Estimated Hours: 4h
GenAI Prompt: Use Prompt 3 from document to define schema
Output: FastAPI Pydantic models + TypeScript interfaces

Task 4.2.4: Build QuestionCard Component

Assigned To: Frontend Team
Estimated Hours: 12h
Details: Reusable component accepting question JSON, renders appropriate input type

Task 4.2.5: Build HelperPanel Component

Assigned To: Frontend Team
Estimated Hours: 8h
Details: Slide-in panel with examples and guidance, animated transitions

Task 4.2.6: Implement Input Components

Assigned To: Frontend Team
Estimated Hours: 16h
Components:

Slider with labels and live value display
Likert scale chips (visual button group)
Radio buttons with descriptions
Text area with character count



Task 4.2.7: Build Progress Indicator

Assigned To: Frontend Team
Estimated Hours: 4h
Details: Linear progress bar, current/total questions, percentage complete

Task 4.2.8: Implement Navigation & Auto-Save

Assigned To: Frontend Team
Estimated Hours: 8h
Details: Next/Back/Skip logic, debounced auto-save to backend

Task 4.2.9: Add Validation & Error States

Assigned To: Frontend Team
Estimated Hours: 6h
Details: Required field validation, friendly error messages, field-level errors

Task 4.2.10: Implement Accessibility Features

Assigned To: Frontend Team
Estimated Hours: 8h
Details: Keyboard navigation, ARIA live regions for announcements, focus traps

Task 4.2.11: Mobile Touch Optimization

Assigned To: Frontend Team
Estimated Hours: 6h
Details: Touch-friendly targets (44px min), swipe gestures, haptic feedback

Task 4.2.12: User Testing & Refinement

Assigned To: UX Researcher + Frontend Team
Estimated Hours: 12h
Details: 20 user tests, comprehension testing, iteration based on feedback


📖 User Story 4.3: WebXR Immersive Assessment Experience
Story:
"As a user with VR/AR hardware (Quest, Vision Pro, or WebXR-compatible device), I want to complete my assessment in an immersive, calming 3D environment that feels like I'm in a peaceful therapy space, so that I feel more relaxed and present during the evaluation process."
User Persona: Tech-savvy user with VR headset, seeking immersive experience
Priority: P1 (Should Have - Sprint 4)
Story Points: 21
Acceptance Criteria:

✅ WebXR experience accessible via browser on Quest, Vision Pro, and desktop VR
✅ User enters calming virtual environment (options: soft-lit room, nature scene, floating platform)
✅ Questions appear as floating 3D cards in an arc around user (1.5-2m distance)
✅ One question active at a time, others slightly dimmed/scaled down
✅ Interaction methods supported:

Hand controllers (ray pointer)
Hand tracking (pinch gestures)
Gaze + dwell time (accessibility)


✅ Helper Panel appears beside active question when "?" button is gazed/pointed at
✅ Animations smooth and comfortable (no motion sickness):

Panel ease-in: 500ms
Question transitions: 800ms
Highlight on focus: 200ms
Subtle particle effects for breathing guidance


✅ Answer input in 3D:

Slider: drag a 3D handle along a rail
Likert chips: 3D buttons that highlight and emit particles on selection
Text input: virtual keyboard or voice-to-text


✅ Progress visualized as glowing orbs completing a circle
✅ Performance: 72fps minimum on Quest 2, 90fps on Quest 3/Pro
✅ Accessibility settings: font size adjustment, contrast modes, motion reduction
✅ Graceful fallback to 2D web UI if WebXR not supported
✅ User testing shows 85%+ prefer immersive version over 2D when available

Business Impact: Premium differentiator, improves engagement and presence
Dependencies: Story 4.2 (question JSON schema), Story 4.1 (React shell)

🔧 Tasks for Story 4.3:
Task 4.3.1: Set Up React Three Fiber + XR Infrastructure

Assigned To: XR Engineer
Estimated Hours: 8h
Libraries: @react-three/fiber, @react-three/xr, @react-three/drei, three.js

Task 4.3.2: Design XR Scene & Interaction Flow

Assigned To: XR Engineer + UX Designer
Estimated Hours: 12h
GenAI Prompt: Use Prompt 1 from document to generate scene design
Output: Environment concept, interaction patterns, animation specifications

Task 4.3.3: Build Calming Environment Scene

Assigned To: XR Engineer + 3D Artist
Estimated Hours: 16h
Details: 3 environment options, procedural sky, ambient lighting, gentle animations

Task 4.3.4: Create 3D Question Card Component

Assigned To: XR Engineer
Estimated Hours: 16h
Details: Floating card with depth, question text rendering, border glow on focus

Task 4.3.5: Implement 3D Helper Panel

Assigned To: XR Engineer
Estimated Hours: 12h
Details: Side panel that slides in, same content as 2D version, readable text

Task 4.3.6: Build 3D Input Components

Assigned To: XR Engineer
Estimated Hours: 20h
Components:

3D slider with draggable handle
3D button chips with hover/press states
Virtual keyboard or voice input integration



Task 4.3.7: Implement Controller & Hand Tracking Input

Assigned To: XR Engineer
Estimated Hours: 16h
Details: Ray pointer, hand pinch gestures, button mapping

Task 4.3.8: Build Gaze-Based Interaction (Accessibility)

Assigned To: XR Engineer
Estimated Hours: 10h
Details: Gaze cursor, dwell time selection, visual feedback

Task 4.3.9: Create Transition Animations

Assigned To: XR Engineer
Estimated Hours: 12h
Details: Question card transitions, focus animations, particle effects

Task 4.3.10: Implement Progress Visualization

Assigned To: XR Engineer
Estimated Hours: 8h
Details: Glowing orb circle, fills as questions completed

Task 4.3.11: Optimize Performance for Target Frame Rates

Assigned To: XR Engineer
Estimated Hours: 12h
Details: LOD, texture compression, draw call reduction, profiling

Task 4.3.12: Add Accessibility Settings Panel

Assigned To: XR Engineer
Estimated Hours: 10h
Details: Font size, contrast, motion reduction, comfort options

Task 4.3.13: Implement Fallback to 2D UI

Assigned To: Frontend Team
Estimated Hours: 6h
Details: Detect WebXR support, graceful degradation

Task 4.3.14: XR User Testing

Assigned To: UX Researcher + XR Engineer
Estimated Hours: 16h
Details: 15 users with VR headsets, comfort testing, preference survey


📖 User Story 4.4: Therapist Dashboard with Real-Time Visualization
Story:
"As a therapist monitoring a client's assessment or session, I want a dashboard that displays real-time responses, mood trends, and AI-generated insights, so that I can provide timely support and understand the client's state at a glance."
User Persona: Licensed therapist, clinical supervisor, or wellness coach
Priority: P1 (Should Have - Sprint 4)
Story Points: 13
Acceptance Criteria:

✅ Dashboard displays in real-time as client completes assessment
✅ WebSocket connection provides live updates (<1 second latency)
✅ Visualizations include:

Mood trend line chart (0-10 scale over last 30 days)
Sleep quality bar chart (last 4 sessions comparison)
Current session responses table with timestamps
Stress level gauge (current reading)


✅ AI-generated session notes appear per question:

"Client reports high anxiety (8/10) - consistent with last week"
"Notable improvement in sleep quality (+2 points)"


✅ Recharts library used for all charts (line, bar, area, gauge)
✅ Data contract defined for FastAPI JSON responses
✅ Loading states, empty states ("No data yet"), error boundaries
✅ Export functionality: Download session summary as PDF
✅ Filtering: View by date range, question category, trend type
✅ Responsive layout works on tablet (therapist's iPad) and desktop
✅ Auto-refresh every 30 seconds when session is active
✅ HIPAA-compliant: No data logged to browser console, secure WebSocket (WSS)

Business Impact: Enables remote therapy, real-time intervention, better clinical insights
Dependencies: Story 4.1 (React shell), Backend session orchestration (Epic 3)

🔧 Tasks for Story 4.4:
Task 4.4.1: Design Dashboard Information Architecture

Assigned To: UX Designer + Clinical Consultant
Estimated Hours: 8h
GenAI Prompt: Use Prompt 7 from document to generate dashboard spec
Output: Component tree, layout wireframes, data requirements

Task 4.4.2: Define FastAPI Data Contract

Assigned To: Backend + Frontend Team
Estimated Hours: 4h
Details: JSON schemas for mood data, session responses, AI notes

Task 4.4.3: Build Dashboard Layout Component

Assigned To: Frontend Team
Estimated Hours: 8h
Details: Grid layout with card containers, responsive breakpoints

Task 4.4.4: Create WebSocket Client for Real-Time Updates

Assigned To: Frontend Team
Estimated Hours: 10h
Details: Connect to /ws/session/{id}, handle reconnection, update state

Task 4.4.5: Build MoodTrendCard Component (Line Chart)

Assigned To: Frontend Team
Estimated Hours: 8h
Details: Recharts LineChart, 30-day data, tooltips, zoom/pan

Task 4.4.6: Build SleepQualityCard Component (Bar Chart)

Assigned To: Frontend Team
Estimated Hours: 6h
Details: Recharts BarChart, last 4 sessions, color coding

Task 4.4.7: Build CurrentSessionTable Component

Assigned To: Frontend Team
Estimated Hours: 8h
Details: Live-updating table, question text, response, timestamp, AI note

Task 4.4.8: Build StressGauge Component

Assigned To: Frontend Team
Estimated Hours: 6h
Details: Recharts RadialBarChart or custom SVG gauge, color zones

Task 4.4.9: Implement AI Session Notes Display

Assigned To: Frontend Team
Estimated Hours: 6h
Details: Fetch from FastAPI /insights/{session_id}, display with icons

Task 4.4.10: Build Date Range Filter

Assigned To: Frontend Team
Estimated Hours: 6h
Details: Date picker, filter charts by range, URL state sync

Task 4.4.11: Implement PDF Export

Assigned To: Frontend Team
Estimated Hours: 10h
Libraries: jsPDF or html2canvas
Details: Generate PDF with charts, tables, session summary

Task 4.4.12: Add Loading, Empty, and Error States

Assigned To: Frontend Team
Estimated Hours: 6h

Task 4.4.13: HIPAA Compliance Audit

Assigned To: Security Team + Frontend Team
Estimated Hours: 8h
Details: Remove console logs, secure WebSocket, audit data handling

Task 4.4.14: Therapist User Testing

Assigned To: UX Researcher + Clinical Consultant
Estimated Hours: 12h
Details: 10 therapists test dashboard, gather feedback, iterate


📖 User Story 4.5: Wheel of Happiness Interactive Assessment
Story:
"As a user identifying areas for self-improvement, I want to rate my happiness across 8 life areas using an interactive wheel visualization, so that I can visually see my life balance and prioritize which areas need attention."
User Persona: New user starting General Self-Improvement program
Priority: P0 (Must Have - Sprint 3)
Story Points: 8
Acceptance Criteria:

✅ Interactive wheel displays 8 life areas: Health, Family & Friends, Career, Significant Other/Romance, Fun & Recreation, Money, Physical Environment, Personal Growth
✅ User rates each area 1-10 by clicking/dragging on the wheel
✅ Visual feedback: Area fills from center (1) to outer edge (10)
✅ Color coding: Red/orange (1-4), yellow (5-7), green (8-10)
✅ Completed wheel shows "bumpiness" - uneven wheel = life imbalance
✅ Summary displayed: "How smooth or bumpy is your ride?"
✅ Top 3 priority areas automatically suggested based on lowest scores
✅ User can manually adjust priorities
✅ Works on mobile with touch interactions
✅ Accessible: Keyboard navigation alternative (tab through areas, arrow keys to adjust)
✅ Animation when wheel fills in (feels rewarding, not jarring)
✅ Results saved to user profile and used for goal setting

Business Impact: Core assessment for General Self-Improvement (most common use case)
Dependencies: Story 4.1 (React shell), Backend API for saving results

🔧 Tasks for Story 4.5:
Task 4.5.1: Design Wheel of Happiness Component

Assigned To: UX Designer
Estimated Hours: 8h
Details: Interactive SVG or Canvas design, color schemes, animations

Task 4.5.2: Build WheelOfHappiness React Component

Assigned To: Frontend Team
Estimated Hours: 16h
Details: SVG paths for 8 segments, interactive fill, drag/click to rate

Task 4.5.3: Implement Rating Interaction

Assigned To: Frontend Team
Estimated Hours: 10h
Details: Click to rate, drag to adjust, touch gestures, value display

Task 4.5.4: Add Color Coding Logic

Assigned To: Frontend Team
Estimated Hours: 4h
Details: Dynamic colors based on score ranges

Task 4.5.5: Build Summary & Priority Suggestion

Assigned To: Frontend Team
Estimated Hours: 6h
Details: Calculate bumpiness, suggest top 3 priorities, allow manual override

Task 4.5.6: Implement Animations

Assigned To: Frontend Team
Estimated Hours: 6h
Details: Fill animation (300-500ms per segment), smooth transitions

Task 4.5.7: Add Keyboard Accessibility

Assigned To: Frontend Team
Estimated Hours: 6h
Details: Tab navigation, arrow key adjustment, ARIA labels

Task 4.5.8: Integrate with Backend API

Assigned To: Full Stack Team
Estimated Hours: 4h
Details: POST to /wheel-of-happiness, save to user profile

Task 4.5.9: User Testing

Assigned To: UX Researcher
Estimated Hours: 8h
Details: 15 users, test understanding and ease of use


📖 User Story 4.6: GenAI-Powered Question Bank Generator
Story:
"As a product manager or therapist, I want to use GenAI to generate new assessment questions with examples and helper text, so that I can rapidly expand the question bank while maintaining quality and therapeutic appropriateness."
User Persona: Product manager, clinical content creator
Priority: P2 (Nice to Have - Sprint 5)
Story Points: 8
Acceptance Criteria:

✅ Admin interface to input GenAI prompt for question generation
✅ Uses Prompt 6 pattern from document (therapist consultant persona)
✅ Generates 10 questions at a time with full JSON structure:

id, question_text, time_frame_hint, input_type
options_or_scale
helper: why_asking, examples (3 entries with range, example_answer, guidance_text)


✅ Output matches JSON schema from Story 4.2
✅ Content review interface: Approve, Edit, or Reject each question
✅ Approved questions added to question bank automatically
✅ Language validation: 8th-10th grade reading level (Flesch-Kincaid score)
✅ Safety check: No medical diagnosis language, no harmful content
✅ Version control: Track changes, revert if needed
✅ Audit log: Who generated, who reviewed, when approved

Business Impact: Scales content creation, maintains quality, reduces therapist workload
Dependencies: Story 4.2 (JSON schema), Custom Hypnosis LLM (Epic 6)

🔧 Tasks for Story 4.6:
Task 4.6.1: Build Admin Question Generator UI

Assigned To: Frontend Team
Estimated Hours: 8h
Details: Form for prompt input, parameter controls, generate button

Task 4.6.2: Integrate with Custom Hypnosis LLM

Assigned To: Backend Team
Estimated Hours: 8h
Details: API endpoint that sends prompt to LLM, parses JSON output

Task 4.6.3: Implement Prompt 6 Template

Assigned To: Backend Team
Estimated Hours: 4h
Details: Pre-filled prompt template with therapist consultant persona

Task 4.6.4: Build Content Review Interface

Assigned To: Frontend Team
Estimated Hours: 12h
Details: Display generated questions, edit fields, approve/reject buttons

Task 4.6.5: Add Language Validation

Assigned To: Backend Team
Estimated Hours: 6h
Libraries: Flesch-Kincaid readability analyzer
Details: Flag questions above 10th grade level

Task 4.6.6: Implement Safety Content Filter

Assigned To: Backend Team + Clinical Consultant
Estimated Hours: 10h
Details: Keyword filtering, sentiment analysis, flag diagnosis language

Task 4.6.7: Build Version Control System

Assigned To: Backend Team
Estimated Hours: 8h
Details: Track question versions, enable rollback

Task 4.6.8: Add Audit Logging

Assigned To: Backend Team
Estimated Hours: 4h
Details: Log all generation, review, and approval actions


📖 User Story 4.7: Native VR Experience (Unity/Unreal - Optional)
Story:
"As a user with high-end VR hardware (Quest Pro, PCVR, Vision Pro), I want a native VR application with advanced graphics and interactions that exceeds what's possible in WebXR, so that I experience the highest quality immersive therapy environment."
User Persona: Tech enthusiast with high-end VR hardware, seeking premium experience
Priority: P3 (Could Have - Sprint 6+)
Story Points: 34 (Large - requires dedicated sprint)
Acceptance Criteria:

✅ Unity or Unreal Engine VR application built for Quest, PCVR, and Vision Pro
✅ Uses same FastAPI backend endpoints (HTTP/WebSockets)
✅ Advanced graphics: Real-time lighting, ray tracing (on supported hardware), high-res textures
✅ Native UI: Unity UI Toolkit or Unreal UMG
✅ Hand tracking and controller support with haptic feedback
✅ Advanced interactions:

Physics-based objects (squeeze stress ball, pour sand)
Breathing guidance with visual particle flows
Spatial audio (therapist voice positioned naturally)


✅ Performance: 90fps on Quest Pro, 120fps on PCVR, 100fps on Vision Pro
✅ Matches JSON question schema from WebXR version
✅ Passthrough mode on Quest for mixed reality grounding exercises
✅ Sideloadable on Quest, available on SteamVR, App Lab submission ready
✅ Analytics: Track session completion, comfort ratings, performance metrics
✅ User preference: 95%+ prefer native VR over WebXR when both tested

Business Impact: Premium tier offering, competitive differentiator, advanced research platform
Dependencies: Stories 4.2, 4.3 (JSON schema, interaction patterns established)

🔧 Tasks for Story 4.7:
Task 4.7.1: Evaluate Unity vs Unreal Engine

Assigned To: XR Lead + Technical Architect
Estimated Hours: 8h
Decision factors: Target platforms, team expertise, asset pipelines

Task 4.7.2: Set Up Native VR Project

Assigned To: XR Engineer
Estimated Hours: 12h
Details: XR Interaction Toolkit (Unity) or VR Template (Unreal)

Task 4.7.3: Build FastAPI Client for Unity/Unreal

Assigned To: XR Engineer + Backend Team
Estimated Hours: 16h
Details: HTTP requests (UnityWebRequest/Unreal HTTP), WebSocket client

Task 4.7.4: Create High-Fidelity Therapy Environment

Assigned To: 3D Artist + XR Engineer
Estimated Hours: 40h
Details: Modeled room, nature scene, lighting setup, audio ambience

Task 4.7.5: Build Native UI System

Assigned To: XR Engineer
Estimated Hours: 24h
Details: Question panels, buttons, sliders in native UI system

Task 4.7.6: Implement Advanced Interactions

Assigned To: XR Engineer
Estimated Hours: 32h
Details: Physics objects, breathing visuals, spatial audio, haptics

Task 4.7.7: Integrate Hand Tracking

Assigned To: XR Engineer
Estimated Hours: 16h
Details: Quest hand tracking, Vision Pro hand tracking, gesture recognition

Task 4.7.8: Performance Optimization

Assigned To: XR Engineer
Estimated Hours: 20h
Details: Profiling, optimization passes, target frame rates achieved

Task 4.7.9: Add Passthrough Mode (Quest)

Assigned To: XR Engineer
Estimated Hours: 12h
Details: Mixed reality grounding exercises, environment blending

Task 4.7.10: Build Analytics System

Assigned To: XR Engineer + Backend Team
Estimated Hours: 12h
Details: Track events, send to FastAPI, dashboard integration

Task 4.7.11: Platform-Specific Builds & Testing

Assigned To: XR Engineer + QA Team
Estimated Hours: 24h
Details: Quest APK, PCVR build, Vision Pro build (if feasible), device testing

Task 4.7.12: App Store Submission Prep

Assigned To: Product Manager + XR Engineer
Estimated Hours: 16h
Details: App Lab submission (Quest), SteamVR listing, assets and descriptions


🎯 Frontend Epic Summary
StoryPriorityStory PointsSprintDependencies4.1 Core React AppP013Sprint 3Backend APIs4.2 Assessment UIP013Sprint 34.1, Backend4.3 WebXR ExperienceP121Sprint 44.1, 4.24.4 Therapist DashboardP113Sprint 44.1, Epic 34.5 Wheel of HappinessP08Sprint 34.1, Backend4.6 GenAI Question BankP28Sprint 54.2, Epic 64.7 Native VRP334Sprint 6+4.2, 4.3
Total Story Points: 110
Estimated Duration: 4 sprints (8 weeks)
Team Size Needed: 3-4 frontend engineers, 1 XR specialist, 1 UX designer

📊 GenAI Prompt Integration Checklist
Based on the document, here's how we're using each prompt pattern:
PromptPurposeUsed InStatusPrompt 1Design XR scene + interaction flowTask 4.3.2✅ ReferencedPrompt 2Figma-ready UI spec for question panelsTask 4.2.2✅ ReferencedPrompt 3JSON schema for questionsTask 4.2.3✅ ReferencedPrompt 4React + WebXR UI skeletonTask 4.3.4💡 Can use as starting pointPrompt 5Unity/Unreal interaction scriptTask 4.7.6💡 Can use as starting pointPrompt 6Question bank with examplesTask 4.6.3✅ ReferencedPrompt 7Therapist dashboard + RechartsTask 4.4.1✅ Referenced

🔄 Updated Sprint Planning
Sprint 3 (Focus: Core Frontend + Assessments)

Story 4.1: Core React App (13 pts)
Story 4.2: Assessment UI (13 pts)
Story 4.5: Wheel of Happiness (8 pts)
Total: 34 pts

Sprint 4 (Focus: Immersive & Therapist Tools)

Story 4.3: WebXR Experience (21 pts)
Story 4.4: Therapist Dashboard (13 pts)
Total: 34 pts

Sprint 5 (Focus: Content Generation & Refinement)

Story 4.6: GenAI Question Bank (8 pts)
Refinement & user testing for all Sprint 3-4 stories
Total: 20-25 pts (includes testing, bugs, polish)

Sprint 6+ (Optional: Premium Features)

Story 4.7: Native VR Experience (34 pts)
Total: 34 pts (dedicated sprint or background effort)


Would you like me to:

✅ Continue with EPIC 5: Clinical Safety & Guardrails (Pre-session screening, biometric monitoring, escalation)?
✅ Create detailed Figma design specs using the GenAI prompts from the document?
✅ Generate the JSON schema for questions with 10 example questions?
✅ Build a React component skeleton using Prompt 4 from the document?
✅ Add more technical architecture diagrams showing FastAPI ↔ React ↔ WebXR flow?

Let me know which direction to go next! 🚀RetryJSLet's complete the Architecture, Design Spec, Sequence Diagrams, data/message flow charts, state machines, feedback, and fine tuning for each use cases of different type of clients and E &P suggestibility & Sexualities.Orchestrated comprehensive system design across architecture, workflows, and personalized client scenarios.

 Complete System Architecture & Design Specification
HMI AI Hypnotherapy Platform - Comprehensive Technical Documentation

📐 Part 1: System Architecture
1.1 C4 Model - System Context Diagram
┌─────────────────────────────────────────────────────────────────────┐
│                        SYSTEM CONTEXT                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   ┌──────────────┐                                                  │
│   │   Client     │──────────────┐                                  │
│   │   (User)     │              │                                  │
│   └──────────────┘              │                                  │
│                                 │                                  │
│   ┌──────────────┐              │      ┌─────────────────────┐    │
│   │  Therapist   │──────────────┼─────▶│   HMI AI Platform   │    │
│   │ (Supervisor) │              │      │  Hypnotherapy       │    │
│   └──────────────┘              │      │     System          │    │
│                                 │      └──────────┬──────────┘    │
│   ┌──────────────┐              │                 │               │
│   │ VR Headset   │──────────────┘                 │               │
│   │(Quest/Vision)│                                 │               │
│   └──────────────┘                                 │               │
│                                                    │               │
│                          ┌─────────────────────────┼───────┐       │
│                          │                         │       │       │
│                   ┌──────▼────┐            ┌───────▼─────┐ │       │
│                   │  Vector   │            │  Knowledge  │ │       │
│                   │   DB      │            │   Graph     │ │       │
│                   │(Pinecone) │            │  (Neo4j)    │ │       │
│                   └───────────┘            └─────────────┘ │       │
│                                                            │       │
│                   ┌─────────────┐          ┌─────────────┐│       │
│                   │  OpenAI     │          │ Anthropic   ││       │
│                   │  GPT-4      │          │ Claude API  ││       │
│                   └─────────────┘          └─────────────┘│       │
│                                                            │       │
└────────────────────────────────────────────────────────────────────┘

1.2 C4 Model - Container Diagram
┌──────────────────────────────────────────────────────────────────────────────┐
│                            CONTAINER DIAGRAM                                  │
└──────────────────────────────────────────────────────────────────────────────┘

                          ┌─────────────────────┐
                          │   Client Devices    │
                          ├─────────────────────┤
                          │ • Web Browser       │
                          │ • Mobile Browser    │
                          │ • VR Headset        │
                          └──────────┬──────────┘
                                     │
                                     │ HTTPS/WSS
                                     │
                    ┌────────────────▼────────────────┐
                    │      API Gateway / CDN          │
                    │   (Cloudflare / AWS)            │
                    └────────────────┬────────────────┘
                                     │
                    ┌────────────────┴────────────────┐
                    │                                  │
         ┌──────────▼──────────┐          ┌──────────▼──────────┐
         │  React Web App      │          │  Native VR App      │
         │  (Vite + TypeScript)│          │  (Unity/Unreal)     │
         ├─────────────────────┤          ├─────────────────────┤
         │ • Assessment UI     │          │ • Immersive Scenes  │
         │ • Session Player    │          │ • 3D Interactions   │
         │ • Dashboard         │          │ • Biometric Capture │
         │ • WebXR (R3F)       │          │ • Haptic Feedback   │
         └──────────┬──────────┘          └──────────┬──────────┘
                    │                                  │
                    │         REST API / WebSocket     │
                    │                                  │
         ┌──────────▼──────────────────────────────────▼──────────┐
         │            FastAPI Backend Server                      │
         │                (Python 3.11+)                          │
         ├────────────────────────────────────────────────────────┤
         │                                                         │
         │  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐  │
         │  │   Auth      │  │ Assessment  │  │   Session    │  │
         │  │   Service   │  │   Service   │  │ Orchestrator │  │
         │  └─────────────┘  └─────────────┘  └──────────────┘  │
         │                                                         │
         │  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐  │
         │  │   RAG       │  │ Multi-Agent │  │   Safety     │  │
         │  │   Engine    │  │    Crew     │  │  Guardian    │  │
         │  └─────────────┘  └─────────────┘  └──────────────┘  │
         │                                                         │
         │  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐  │
         │  │   Voice     │  │  Biometric  │  │   Analytics  │  │
         │  │ Synthesis   │  │  Processor  │  │   Service    │  │
         │  └─────────────┘  └─────────────┘  └──────────────┘  │
         │                                                         │
         └────────────┬────────────────────────┬──────────────────┘
                      │                        │
         ┌────────────▼────────┐  ┌────────────▼────────────┐
         │   PostgreSQL        │  │    Redis Cache          │
         │   (Primary DB)      │  │  (Sessions/Queue)       │
         ├─────────────────────┤  ├─────────────────────────┤
         │ • User Profiles     │  │ • Active Sessions       │
         │ • Assessments       │  │ • Task Queue            │
         │ • Session History   │  │ • Real-time State       │
         │ • Audit Logs        │  │ • Rate Limiting         │
         └─────────────────────┘  └─────────────────────────┘

         ┌─────────────────────┐  ┌─────────────────────────┐
         │   Vector DB         │  │   Knowledge Graph       │
         │   (Pinecone/Qdrant) │  │      (Neo4j)            │
         ├─────────────────────┤  ├─────────────────────────┤
         │ • HMI Scripts       │  │ • Protocol Relations    │
         │ • Suggestions       │  │ • User Journey Graph    │
         │ • Techniques        │  │ • Clinical Reasoning    │
         │ • Embeddings        │  │ • Goal Dependencies     │
         └─────────────────────┘  └─────────────────────────┘

         ┌─────────────────────────────────────────────────────┐
         │            External AI Services                      │
         ├─────────────────────────────────────────────────────┤
         │                                                      │
         │  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
         │  │  Custom LLM  │  │   Claude 4   │  │  GPT-4    │ │
         │  │ (Fine-tuned) │  │  (Fallback)  │  │(Fallback) │ │
         │  └──────────────┘  └──────────────┘  └───────────┘ │
         │                                                      │
         │  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
         │  │ ElevenLabs   │  │  MediaPipe   │  │  Nvidia   │ │
         │  │   (Voice)    │  │   (Vision)   │  │   ACE     │ │
         │  └──────────────┘  └──────────────┘  └───────────┘ │
         └─────────────────────────────────────────────────────┘

1.3 Component Architecture - Backend Services
┌──────────────────────────────────────────────────────────────────────┐
│                     BACKEND SERVICES ARCHITECTURE                     │
└──────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                        API Layer (FastAPI)                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  /api/v1/auth/*           │  /api/v1/assessment/*                  │
│  /api/v1/sessions/*       │  /api/v1/profile/*                     │
│  /api/v1/insights/*       │  /ws/session/{id}                      │
│                                                                      │
└──────────────────┬──────────────────────────────────────────────────┘
                   │
       ┌───────────┴───────────────────────────────────────┐
       │                                                    │
┌──────▼────────┐                                  ┌───────▼────────┐
│  Auth Service │                                  │ Assessment Svc │
├───────────────┤                                  ├────────────────┤
│ • JWT Auth    │                                  │ • Questionnaire│
│ • OAuth2      │                                  │ • Finger Test  │
│ • RBAC        │                                  │ • E&P Eval     │
│ • Sessions    │                                  │ • Scoring      │
└───────────────┘                                  └────────────────┘

┌───────────────────────────────────────────────────────────────────┐
│               Session Orchestration Layer                          │
├───────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │           Multi-Agent Orchestrator (LangGraph)            │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │                                                            │   │
│  │    Strategic Layer (AutoGen)                              │   │
│  │    ┌────────────────┐       ┌─────────────────┐         │   │
│  │    │ Session        │       │ Safety          │         │   │
│  │    │ Planner        │◄─────►│ Overseer        │         │   │
│  │    └────────┬───────┘       └────────┬────────┘         │   │
│  │             │                         │                   │   │
│  │             └─────────┬───────────────┘                   │   │
│  │                       │                                   │   │
│  │    Tactical Layer (CrewAI)                                │   │
│  │    ┌──────────────────────────────────────────────┐     │   │
│  │    │ ┌──────────┐ ┌──────────┐ ┌─────────────┐  │     │   │
│  │    │ │Induction │ │Deepening │ │Suggestions  │  │     │   │
│  │    │ │Composer  │ │Architect │ │Crafter      │  │     │   │
│  │    │ └──────────┘ └──────────┘ └─────────────┘  │     │   │
│  │    └──────────────────────────────────────────────┘     │   │
│  │                       │                                   │   │
│  │    Operational Layer                                      │   │
│  │    ┌──────────────────────────────────────────────┐     │   │
│  │    │  Real-time Adapter (RL Agent)                 │     │   │
│  │    │  - Biometric monitoring                       │     │   │
│  │    │  - Dynamic script adjustment                  │     │   │
│  │    │  - User state tracking                        │     │   │
│  │    └──────────────────────────────────────────────┘     │   │
│  │                                                            │   │
│  └────────────────────────────────────────────────────────────┘   │
│                                                                    │
└────────────────────────────┬───────────────────────────────────────┘
                             │
              ┌──────────────┴──────────────┐
              │                              │
      ┌───────▼────────┐           ┌────────▼───────┐
      │  RAG Engine    │           │  MCP Servers   │
      ├────────────────┤           ├────────────────┤
      │ • Vector Query │           │ • HMI Scripts  │
      │ • Hybrid Search│           │ • Guidelines   │
      │ • Graph RAG    │           │ • Safety Rules │
      │ • Reranking    │           └────────────────┘
      └────────────────┘

┌───────────────────────────────────────────────────────────────────┐
│                   Data & Storage Layer                             │
├───────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │ PostgreSQL  │  │   Redis     │  │  S3/Blob    │             │
│  │             │  │             │  │   Storage   │             │
│  │ • Users     │  │ • Sessions  │  │ • Audio     │             │
│  │ • Profiles  │  │ • Cache     │  │ • Recordings│             │
│  │ • Logs      │  │ • Queue     │  │ • Exports   │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                    │
│  ┌─────────────┐  ┌─────────────┐                               │
│  │  Pinecone   │  │   Neo4j     │                               │
│  │  (Vectors)  │  │   (Graph)   │                               │
│  └─────────────┘  └─────────────┘                               │
│                                                                    │
└───────────────────────────────────────────────────────────────────┘

📊 Part 2: Data Models & Schemas
2.1 Core Data Models
python# ============================================================================
# USER & PROFILE MODELS
# ============================================================================

from pydantic import BaseModel, Field
from typing import Optional, List, Dict
from datetime import datetime
from enum import Enum

class SuggestibilityType(str, Enum):
    PHYSICAL = "physical"
    EMOTIONAL = "emotional"
    BALANCED = "balanced"

class SexualityType(str, Enum):
    PHYSICAL = "physical"
    EMOTIONAL = "emotional"
    UNCLEAR = "unclear"

class SuggestibilityProfile(BaseModel):
    """Suggestibility assessment results"""
    type: SuggestibilityType
    physical_percentage: float = Field(..., ge=0, le=100)
    emotional_percentage: float = Field(..., ge=0, le=100)
    confidence: float = Field(..., ge=0, le=1)
    questionnaire_1_score: int
    questionnaire_2_score: int
    combined_score: int
    finger_test_results: Optional[Dict] = None
    assessed_at: datetime
    assessment_method: str  # "questionnaire", "finger_test", "combined"

class CoreTrait(BaseModel):
    """One of the four core traits for E&P"""
    trait_name: str  # "family_origin", "rejection_response", etc.
    sexuality_indication: SexualityType
    confidence: float = Field(..., ge=0, le=1)
    evidence: Dict  # Supporting data for this trait determination
    notes: Optional[str] = None

class SexualityProfile(BaseModel):
    """E&P Sexuality assessment results"""
    type: SexualityType
    physical_percentage: float = Field(..., ge=0, le=100)
    emotional_percentage: float = Field(..., ge=0, le=100)
    confidence: float = Field(..., ge=0, le=1)
    core_traits_evaluated: List[CoreTrait]
    defense_mechanisms: Optional[List[str]] = None
    incongruencies: Optional[List[str]] = None
    ethnic_influences: Optional[List[str]] = None
    adjustment_applied: Optional[str] = None  # "10% adjustment due to..."
    assessed_at: datetime

class WheelOfHappiness(BaseModel):
    """Wheel of Happiness assessment"""
    health: int = Field(..., ge=1, le=10)
    family_friends: int = Field(..., ge=1, le=10)
    career: int = Field(..., ge=1, le=10)
    significant_other: int = Field(..., ge=1, le=10)
    fun_recreation: int = Field(..., ge=1, le=10)
    money: int = Field(..., ge=1, le=10)
    physical_environment: int = Field(..., ge=1, le=10)
    personal_growth: int = Field(..., ge=1, le=10)
    
    @property
    def average_score(self) -> float:
        scores = [
            self.health, self.family_friends, self.career,
            self.significant_other, self.fun_recreation, self.money,
            self.physical_environment, self.personal_growth
        ]
        return sum(scores) / len(scores)
    
    @property
    def bumpiness_score(self) -> float:
        """Standard deviation - higher = more unbalanced"""
        import statistics
        scores = [
            self.health, self.family_friends, self.career,
            self.significant_other, self.fun_recreation, self.money,
            self.physical_environment, self.personal_growth
        ]
        return statistics.stdev(scores)
    
    @property
    def priority_areas(self) -> List[str]:
        """Return top 3 lowest scoring areas"""
        areas = {
            "health": self.health,
            "family_friends": self.family_friends,
            "career": self.career,
            "significant_other": self.significant_other,
            "fun_recreation": self.fun_recreation,
            "money": self.money,
            "physical_environment": self.physical_environment,
            "personal_growth": self.personal_growth
        }
        sorted_areas = sorted(areas.items(), key=lambda x: x[1])
        return [area[0] for area in sorted_areas[:3]]

class UnifiedProfile(BaseModel):
    """Complete personalization profile"""
    user_id: str
    suggestibility: SuggestibilityProfile
    sexuality: Optional[SexualityProfile] = None
    wheel_of_happiness: Optional[WheelOfHappiness] = None
    primary_goal: str
    secondary_goals: List[str] = []
    
    # Session Configuration (auto-generated)
    induction_style: str
    language_patterns: Dict
    deepening_techniques: List[str]
    suggestion_framework: Dict
    voice_characteristics: Dict
    
    created_at: datetime
    updated_at: datetime
    version: int = 1

# ============================================================================
# SESSION MODELS
# ============================================================================

class SessionPhase(str, Enum):
    INTAKE = "intake"
    PRE_INDUCTION = "pre_induction"
    SUGGESTIBILITY_TEST = "suggestibility_test"
    THEORY_OF_MIND = "theory_of_mind"
    INDUCTION = "induction"
    DEEPENING = "deepening"
    THERAPEUTIC_SUGGESTIONS = "therapeutic_suggestions"
    POST_HYPNOTIC = "post_hypnotic"
    EMERGENCE = "emergence"
    COMPLETED = "completed"

class SessionState(str, Enum):
    PLANNED = "planned"
    IN_PROGRESS = "in_progress"
    PAUSED = "paused"
    COMPLETED = "completed"
    ABORTED = "aborted"
    ESCALATED = "escalated"

class BiometricReading(BaseModel):
    """Real-time biometric data"""
    timestamp: datetime
    heart_rate: Optional[float] = None
    heart_rate_variability: Optional[float] = None
    galvanic_skin_response: Optional[float] = None
    respiration_rate: Optional[float] = None
    eye_tracking: Optional[Dict] = None
    emotional_intensity: Optional[float] = Field(None, ge=0, le=1)

class SessionSegment(BaseModel):
    """Individual component of a session"""
    segment_id: str
    phase: SessionPhase
    script_text: str
    duration_seconds: float
    voice_settings: Dict
    biometric_data: List[BiometricReading] = []
    user_responses: Optional[Dict] = None
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None

class HypnotherapySession(BaseModel):
    """Complete therapy session"""
    session_id: str
    user_id: str
    session_number: int  # 1st session, 2nd session, etc.
    state: SessionState
    current_phase: SessionPhase
    
    unified_profile: UnifiedProfile
    
    segments: List[SessionSegment] = []
    
    safety_checks: List[Dict] = []
    escalation_events: List[Dict] = []
    
    scheduled_at: Optional[datetime] = None
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    total_duration_seconds: Optional[float] = None
    
    quality_rating: Optional[int] = Field(None, ge=1, le=10)
    user_feedback: Optional[str] = None
    therapist_notes: Optional[str] = None

# ============================================================================
# QUESTION BANK MODELS
# ============================================================================

class InputType(str, Enum):
    SCALE = "scale"
    MULTIPLE_CHOICE = "multiple_choice"
    LIKERT = "likert"
    FREE_TEXT = "free_text"

class HelperExample(BaseModel):
    """Example answer with guidance"""
    range_or_option: str  # "1-3" or "Strongly disagree"
    example_answer: str  # How user might phrase it
    guidance_text: str  # Gentle explanation

class HelperPanel(BaseModel):
    """Helper text for question"""
    why_asking: str  # Brief reason (1-2 sentences)
    examples: List[HelperExample]  # 3 examples at different intensities

class Question(BaseModel):
    """Questionnaire item"""
    id: str
    category: str  # "suggestibility", "sexuality", "wheel", "goal_specific"
    question_text: str
    time_frame_hint: Optional[str] = None  # "Last 24 hours", "Right now"
    input_type: InputType
    
    # For scale
    scale_min: Optional[int] = None
    scale_max: Optional[int] = None
    scale_labels: Optional[Dict[int, str]] = None
    
    # For multiple choice / Likert
    options: Optional[List[str]] = None
    
    # Helper text
    helper: Optional[HelperPanel] = None
    
    # Metadata
    required: bool = True
    weight: int = 5  # Scoring weight
    created_at: datetime
    created_by: str  # "system", "therapist", "ai_generated"
    version: int = 1

# ============================================================================
# RAG & KNOWLEDGE MODELS
# ============================================================================

class HMIScriptChunk(BaseModel):
    """Chunk of HMI protocol script"""
    chunk_id: str
    script_name: str  # "Emotional Arm Raising Induction"
    phase: SessionPhase
    suggestibility_type: Optional[SuggestibilityType] = None
    sexuality_type: Optional[SexualityType] = None
    
    content: str
    metadata: Dict
    
    embedding: Optional[List[float]] = None
    relevance_score: Optional[float] = None

class ClinicalGuideline(BaseModel):
    """Safety protocol or clinical guideline"""
    guideline_id: str
    category: str  # "contraindication", "safety", "escalation"
    title: str
    description: str
    conditions: List[str]
    actions: List[str]
    severity: str  # "low", "medium", "high", "critical"

2.2 Database Schema (PostgreSQL)
sql-- ============================================================================
-- USERS & AUTHENTICATION
-- ============================================================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    date_of_birth DATE,
    phone VARCHAR(20),
    timezone VARCHAR(50) DEFAULT 'UTC',
    locale VARCHAR(10) DEFAULT 'en-US',
    role VARCHAR(50) DEFAULT 'client', -- client, therapist, admin
    account_status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP,
    email_verified BOOLEAN DEFAULT FALSE,
    terms_accepted BOOLEAN DEFAULT FALSE,
    privacy_policy_accepted BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- ============================================================================
-- ASSESSMENTS
-- ============================================================================

CREATE TABLE suggestibility_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    assessment_type VARCHAR(20) NOT NULL, -- questionnaire, finger_test, combined
    
    -- Questionnaire scores
    questionnaire_1_score INT,
    questionnaire_2_score INT,
    combined_score INT,
    
    -- Results
    suggestibility_type VARCHAR(20), -- physical, emotional, balanced
    physical_percentage DECIMAL(5,2),
    emotional_percentage DECIMAL(5,2),
    confidence_score DECIMAL(3,2),
    
    -- Finger test data (JSONB for flexibility)
    finger_test_results JSONB,
    
    completed_at TIMESTAMP DEFAULT NOW(),
    session_duration_seconds INT,
    
    CONSTRAINT valid_percentages CHECK (
        physical_percentage + emotional_percentage = 100
    )
);

CREATE INDEX idx_sugg_user ON suggestibility_assessments(user_id);

CREATE TABLE questionnaire_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_id UUID REFERENCES suggestibility_assessments(id) ON DELETE CASCADE,
    question_id VARCHAR(50) NOT NULL,
    questionnaire_number INT, -- 1 or 2
    question_number INT,
    response BOOLEAN, -- yes/no
    response_time_ms INT,
    responded_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE sexuality_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Results
    sexuality_type VARCHAR(20), -- physical, emotional, unclear
    physical_percentage DECIMAL(5,2),
    emotional_percentage DECIMAL(5,2),
    confidence_score DECIMAL(3,2),
    
    -- Core traits (JSONB for structured data)
    family_origin_trait JSONB,
    rejection_response_trait JSONB,
    body_connection_trait JSONB,
    relationship_patterns_trait JSONB,
    
    -- Modifiers
    defense_mechanisms JSONB,
    incongruencies JSONB,
    ethnic_influences JSONB,
    adjustment_applied VARCHAR(255),
    
    completed_at TIMESTAMP DEFAULT NOW(),
    
    CONSTRAINT valid_sex_percentages CHECK (
        physical_percentage + emotional_percentage = 100
    )
);

CREATE INDEX idx_sex_user ON sexuality_assessments(user_id);

CREATE TABLE family_tree (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sexuality_assessment_id UUID REFERENCES sexuality_assessments(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    person_name VARCHAR(100),
    relationship_to_user VARCHAR(50), -- mother, father, sibling, etc.
    role VARCHAR(50), -- primary_caretaker, secondary_caretaker, other
    sexuality_type VARCHAR(20),
    traits JSONB, -- Observed E/P traits
    
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE relationship_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sexuality_assessment_id UUID REFERENCES sexuality_assessments(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    relationship_order INT, -- Chronological order
    partner_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    duration_months INT,
    
    who_pursued_whom VARCHAR(20), -- user, partner, mutual
    intensity_rating INT CHECK (intensity_rating BETWEEN 1 AND 10),
    vulnerability_level INT CHECK (vulnerability_level BETWEEN 1 AND 10),
    
    user_rejection_response VARCHAR(20), -- forward, withdraw
    partner_rejection_response VARCHAR(20),
    who_withdrew_first VARCHAR(20), -- user, partner
    
    partner_sexuality_type VARCHAR(20),
    is_rebound BOOLEAN DEFAULT FALSE,
    
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE wheel_of_happiness (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    health INT CHECK (health BETWEEN 1 AND 10),
    family_friends INT CHECK (family_friends BETWEEN 1 AND 10),
    career INT CHECK (career BETWEEN 1 AND 10),
    significant_other INT CHECK (significant_other BETWEEN 1 AND 10),
    fun_recreation INT CHECK (fun_recreation BETWEEN 1 AND 10),
    money INT CHECK (money BETWEEN 1 AND 10),
    physical_environment INT CHECK (physical_environment BETWEEN 1 AND 10),
    personal_growth INT CHECK (personal_growth BETWEEN 1 AND 10),
    
    average_score DECIMAL(3,1),
    bumpiness_score DECIMAL(3,1),
    priority_areas JSONB, -- Array of top 3 lowest areas
    
    completed_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- UNIFIED PROFILE
-- ============================================================================

CREATE TABLE unified_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    
    suggestibility_assessment_id UUID REFERENCES suggestibility_assessments(id),
    sexuality_assessment_id UUID REFERENCES sexuality_assessments(id),
    wheel_of_happiness_id UUID REFERENCES wheel_of_happiness(id),
    
    primary_goal VARCHAR(255),
    secondary_goals JSONB, -- Array of goals
    
    -- Session Configuration (auto-generated)
    induction_style VARCHAR(50),
    language_patterns JSONB,
    deepening_techniques JSONB,
    suggestion_framework JSONB,
    voice_characteristics JSONB,
    
    version INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_profile_user ON unified_profiles(user_id);

-- ============================================================================
-- SESSIONS
-- ============================================================================

CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    unified_profile_id UUID REFERENCES unified_profiles(id),
    
    session_number INT, -- 1, 2, 3...
    state VARCHAR(20) DEFAULT 'planned', -- planned, in_progress, completed, etc.
    current_phase VARCHAR(30),
    
    scheduled_at TIMESTAMP,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    total_duration_seconds INT,
    
    quality_rating INT CHECK (quality_rating BETWEEN 1 AND 10),
    user_feedback TEXT,
    therapist_notes TEXT,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_sessions_user ON sessions(user_id);
CREATE INDEX idx_sessions_state ON sessions(state);

CREATE TABLE session_segments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
    
    segment_order INT,
    phase VARCHAR(30), -- induction, deepening, etc.
    script_text TEXT,
    duration_seconds INT,
    voice_settings JSONB,
    
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    
    user_responses JSONB,
    
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_segments_session ON session_segments(session_id);

CREATE TABLE biometric_readings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
    segment_id UUID REFERENCES session_segments(id) ON DELETE SET NULL,
    
    timestamp TIMESTAMP DEFAULT NOW(),
    
    heart_rate DECIMAL(5,2),
    heart_rate_variability DECIMAL(5,2),
    galvanic_skin_response DECIMAL(5,2),
    respiration_rate DECIMAL(5,2),
    eye_tracking_data JSONB,
    emotional_intensity DECIMAL(3,2) CHECK (emotional_intensity BETWEEN 0 AND 1)
);

CREATE INDEX idx_biometric_session ON biometric_readings(session_id);
CREATE INDEX idx_biometric_timestamp ON biometric_readings(timestamp);

CREATE TABLE safety_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
    
    event_type VARCHAR(50), -- contraindication, high_stress, escalation, etc.
    severity VARCHAR(20), -- low, medium, high, critical
    description TEXT,
    biometric_trigger JSONB,
    
    action_taken VARCHAR(255),
    escalated_to_human BOOLEAN DEFAULT FALSE,
    
    occurred_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_safety_session ON safety_events(session_id);
CREATE INDEX idx_safety_severity ON safety_events(severity);

-- ============================================================================
-- QUESTION BANK
-- ============================================================================

CREATE TABLE questions (
    id VARCHAR(50) PRIMARY KEY,
    category VARCHAR(50), -- suggestibility, sexuality, wheel, goal_specific
    question_text TEXT NOT NULL,
    time_frame_hint VARCHAR(100),
    input_type VARCHAR(20), -- scale, multiple_choice, likert, free_text
    
    -- Scale config
    scale_min INT,
    scale_max INT,
    scale_labels JSONB,
    
    -- Multiple choice config
    options JSONB,
    
    -- Helper text
    helper_panel JSONB,
    
    required BOOLEAN DEFAULT TRUE,
    weight INT DEFAULT 5,
    
    created_by VARCHAR(50), -- system, therapist, ai_generated
    version INT DEFAULT 1,
    active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_questions_category ON questions(category);
CREATE INDEX idx_questions_active ON questions(active);

-- ============================================================================
-- AUDIT & ANALYTICS
-- ============================================================================

CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100),
    resource_type VARCHAR(50),
    resource_id VARCHAR(100),
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    occurred_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_audit_user ON audit_log(user_id);
CREATE INDEX idx_audit_timestamp ON audit_log(occurred_at);
CREATE INDEX idx_audit_action ON audit_log(action);

CREATE TABLE analytics_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    session_id UUID REFERENCES sessions(id) ON DELETE SET NULL,
    
    event_name VARCHAR(100),
    event_category VARCHAR(50),
    event_properties JSONB,
    
    occurred_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_analytics_user ON analytics_events(user_id);
CREATE INDEX idx_analytics_event ON analytics_events(event_name);
CREATE INDEX idx_analytics_timestamp ON analytics_events(occurred_at);

2.3 Neo4j Knowledge Graph Schema
cypher// ============================================================================
// NODE TYPES
// ============================================================================

// User and Profile Nodes
CREATE CONSTRAINT user_id IF NOT EXISTS FOR (u:User) REQUIRE u.id IS UNIQUE;
CREATE CONSTRAINT profile_id IF NOT EXISTS FOR (p:Profile) REQUIRE p.id IS UNIQUE;

// Assessment Nodes
CREATE CONSTRAINT sugg_id IF NOT EXISTS FOR (s:Suggestibility) REQUIRE s.id IS UNIQUE;
CREATE CONSTRAINT sex_id IF NOT EXISTS FOR (s:Sexuality) REQUIRE s.id IS UNIQUE;

// Goal and Habit Nodes
CREATE CONSTRAINT goal_id IF NOT EXISTS FOR (g:Goal) REQUIRE g.id IS UNIQUE;
CREATE CONSTRAINT habit_id IF NOT EXISTS FOR (h:Habit) REQUIRE h.id IS UNIQUE;
CREATE CONSTRAINT habit_loop_id IF NOT EXISTS FOR (hl:HabitLoop) REQUIRE hl.id IS UNIQUE;

// Protocol Nodes
CREATE CONSTRAINT induction_id IF NOT EXISTS FOR (i:Induction) REQUIRE i.id IS UNIQUE;
CREATE CONSTRAINT deepening_id IF NOT EXISTS FOR (d:Deepening) REQUIRE d.id IS UNIQUE;
CREATE CONSTRAINT suggestion_id IF NOT EXISTS FOR (s:Suggestion) REQUIRE s.id IS UNIQUE;

// Identity and Behavior Nodes
CREATE CONSTRAINT identity_id IF NOT EXISTS FOR (i:Identity) REQUIRE i.id IS UNIQUE;

// Wheel of Happiness Nodes
CREATE CONSTRAINT wheel_area_id IF NOT EXISTS FOR (w:WheelArea) REQUIRE w.name IS UNIQUE;

// ============================================================================
// EXAMPLE GRAPH STRUCTURE
// ============================================================================

// Create User
CREATE (u:User {
    id: 'user-123',
    email: 'john@example.com',
    created_at: datetime()
})

// Create Suggestibility Profile
CREATE (sugg:Suggestibility {
    id: 'sugg-456',
    type: 'emotional',
    physical_pct: 35.0,
    emotional_pct: 65.0,
    confidence: 0.85
})

// Create Sexuality Profile
CREATE (sex:Sexuality {
    id: 'sex-789',
    type: 'physical',
    physical_pct: 70.0,
    emotional_pct: 30.0,
    confidence: 0.80,
    adjustment_applied: '+10% Physical due to high Emotional Suggestibility'
})

// Create Unified Profile
CREATE (profile:Profile {
    id: 'profile-abc',
    version: 1,
    created_at: datetime()
})

// Link User -> Profile -> Assessments
CREATE (u)-[:HAS_PROFILE]->(profile)
CREATE (profile)-[:HAS_SUGGESTIBILITY]->(sugg)
CREATE (profile)-[:HAS_SEXUALITY]->(sex)

// Create Goals
CREATE (goal1:Goal {
    id: 'goal-001',
    name: 'Improve Career Success',
    category: 'career',
    priority: 1
})

CREATE (goal2:Goal {
    id: 'goal-002',
    name: 'Better Sleep',
    category: 'health',
    priority: 2
})

// Link Profile -> Goals
CREATE (profile)-[:HAS_GOAL {priority: 1}]->(goal1)
CREATE (profile)-[:HAS_GOAL {priority: 2}]->(goal2)

// Create Habits for Goal 1
CREATE (habit1:Habit {
    id: 'habit-001',
    name: 'Network with 1 person weekly',
    frequency: 'weekly',
    difficulty: 3
})

CREATE (habit2:Habit {
    id: 'habit-002',
    name: 'Update LinkedIn profile monthly',
    frequency: 'monthly',
    difficulty: 2
})

// Link Goal -> Habits
CREATE (goal1)-[:REQUIRES]->(habit1)
CREATE (goal1)-[:REQUIRES]->(habit2)

// Create Habit Loop for Habit 1
CREATE (loop1:HabitLoop {
    id: 'loop-001'
})

CREATE (reminder1:Reminder {
    id: 'rem-001',
    cue: 'Monday morning coffee',
    type: 'time_based'
})

CREATE (routine1:Routine {
    id: 'rout-001',
    action: 'Send one LinkedIn connection message',
    duration_minutes: 10
})

CREATE (reward1:Reward {
    id: 'rew-001',
    benefit: 'Feel accomplished and connected',
    type: 'emotional'
})

// Link Habit -> HabitLoop -> Components
CREATE (habit1)-[:USES]->(loop1)
CREATE (loop1)-[:HAS_REMINDER]->(reminder1)
CREATE (loop1)-[:HAS_ROUTINE]->(routine1)
CREATE (loop1)-[:HAS_REWARD]->(reward1)

// Create Identity Node
CREATE (identity1:Identity {
    id: 'identity-001',
    statement: 'I am the type of person who actively builds professional relationships',
    category: 'career'
})

// Link Identity -> Actions -> Results
CREATE (profile)-[:HAS_IDENTITY]->(identity1)
CREATE (identity1)-[:DRIVES]->(habit1)
CREATE (habit1)-[:PRODUCES {expected_outcome: 'Expanded professional network'}]->(goal1)

// Create Induction Protocol Nodes
CREATE (ind_emotional:Induction {
    id: 'induction-emotional-arm',
    name: 'Emotional/Inferred Arm Raising Induction',
    suggestibility_type: 'emotional',
    script_excerpt: 'As you begin to feel more comfortable...',
    characteristics: ['inferential', 'allowing language', 'misdirection']
})

CREATE (ind_physical:Induction {
    id: 'induction-physical-arm',
    name: 'Physical/Literal Arm Raising Induction',
    suggestibility_type: 'physical',
    script_excerpt: 'Your arm and hand will lift and rise...',
    characteristics: ['direct', 'concrete language', 'explicit instructions']
})

// Link Suggestibility -> Appropriate Induction
CREATE (sugg)-[:RESPONDS_TO]->(ind_emotional)

// Create Deepening Techniques
CREATE (deep1:Deepening {
    id: 'deep-progressive',
    name: 'Progressive Relaxation',
    suitable_for: ['emotional', 'physical', 'balanced']
})

CREATE (deep2:Deepening {
    id: 'deep-staircase',
    name: 'Staircase Deepening',
    suitable_for: ['emotional', 'physical', 'balanced']
})

// Link Induction -> Deepening
CREATE (ind_emotional)-[:FOLLOWED_BY]->(deep1)
CREATE (ind_emotional)-[:FOLLOWED_BY]->(deep2)

// Create Therapeutic Suggestions
CREATE (sugg1:Suggestion {
    id: 'sugg-career-confidence',
    goal_category: 'career',
    sexuality_type: 'physical',
    content: 'You feel confident connecting with others, sharing your expertise naturally...',
    emphasis: ['connection', 'acceptance', 'relationships']
})

CREATE (sugg2:Suggestion {
    id: 'sugg-career-control',
    goal_category: 'career',
    sexuality_type: 'emotional',
    content: 'You maintain control of your professional trajectory, achieving milestones with precision...',
    emphasis: ['control', 'security', 'achievement']
})

// Link Goal -> Sexuality -> Suggestion
CREATE (goal1)-[:ADDRESSES]->(sugg1)
CREATE (goal1)-[:ADDRESSES]->(sugg2)
CREATE (sex)-[:PREFERS]->(sugg1) // Physical sexuality prefers connection-focused suggestions

// Create Wheel of Happiness Areas
CREATE (wheel_career:WheelArea {name: 'Career', score: 4})
CREATE (wheel_health:WheelArea {name: 'Health', score: 7})
CREATE (wheel_family:WheelArea {name: 'Family & Friends', score: 8})
CREATE (wheel_romance:WheelArea {name: 'Significant Other/Romance', score: 6})
CREATE (wheel_fun:WheelArea {name: 'Fun & Recreation', score: 5})
CREATE (wheel_money:WheelArea {name: 'Money', score: 4})
CREATE (wheel_environment:WheelArea {name: 'Physical Environment', score: 7})
CREATE (wheel_growth:WheelArea {name: 'Personal Growth', score: 6})

// Link Profile -> Wheel Areas
CREATE (profile)-[:RATED_AREA {score: 4, priority: 1}]->(wheel_career)
CREATE (profile)-[:RATED_AREA {score: 7, priority: 5}]->(wheel_health)
CREATE (profile)-[:RATED_AREA {score: 8, priority: 8}]->(wheel_family)
// ... etc for other areas

// Link Goals -> Wheel Areas
CREATE (goal1)-[:IMPROVES]->(wheel_career)
CREATE (goal1)-[:IMPROVES]->(wheel_money)
CREATE (goal2)-[:IMPROVES]->(wheel_health)

// ============================================================================
// EXAMPLE QUERIES
// ============================================================================

// Query 1: Find optimal habit loop for a Physical user seeking career success
MATCH (u:User {id: 'user-123'})-[:HAS_PROFILE]->(p:Profile)
MATCH (p)-[:HAS_SEXUALITY]->(sex:Sexuality {type: 'physical'})
MATCH (p)-[:HAS_GOAL]->(g:Goal {category: 'career'})
MATCH (g)-[:REQUIRES]->(h:Habit)-[:USES]->(hl:HabitLoop)
MATCH (hl)-[:HAS_REMINDER]->(rem)
MATCH (hl)-[:HAS_ROUTINE]->(rout)
MATCH (hl)-[:HAS_REWARD]->(rew)
WHERE rew.type = 'emotional' // Physical sexuality values emotional rewards (connection)
RETURN h.name, rem.cue, rout.action, rew.benefit

// Query 2: Find therapeutic suggestions for Emotional sexuality + Career goal
MATCH (u:User {id: 'user-123'})-[:HAS_PROFILE]->(p:Profile)
MATCH (p)-[:HAS_SEXUALITY]->(sex:Sexuality {type: 'emotional'})
MATCH (p)-[:HAS_GOAL]->(g:Goal {category: 'career'})
MATCH (g)-[:ADDRESSES]->(s:Suggestion)
WHERE s.sexuality_type = 'emotional'
RETURN s.content, s.emphasis

// Query 3: Find contraindications for a specific induction
MATCH (i:Induction {id: 'induction-emotional-arm'})-[:CONTRAINDICATED_FOR]->(c:Contraindication)
RETURN c.condition, c.severity, c.alternative_protocol

// Query 4: Trace path from Identity -> Actions -> Results
MATCH path = (id:Identity)-[:DRIVES]->(h:Habit)-[:PRODUCES]->(g:Goal)
WHERE id.category = 'career'
RETURN path

// Query 5: Find lowest Wheel areas and related goals
MATCH (p:Profile {id: 'profile-abc'})-[r:RATED_AREA]->(w:WheelArea)
WHERE r.score <= 5
MATCH (g:Goal)-[:IMPROVES]->(w)
RETURN w.name, r.score, collect(g.name) AS related_goals
ORDER BY r.score ASC
LIMIT 3


Part 3: Sequence Diagrams
3.1 First Session - Complete End-to-End Flow
sequenceDiagram
    participant User
    participant WebApp as React Web App
    participant API as FastAPI Backend
    participant Auth as Auth Service
    participant Assessment as Assessment Service
    participant Orchestrator as Session Orchestrator
    participant RAG as RAG Engine
    participant Agents as Multi-Agent Crew
    participant Safety as Safety Guardian
    participant VectorDB as Vector DB
    participant GraphDB as Neo4j Graph
    participant LLM as Custom Hypnosis LLM
    participant Voice as Voice Synthesis

    User->>WebApp: Visit platform, click "Start"
    WebApp->>API: POST /api/v1/auth/register
    API->>Auth: Create user account
    Auth-->>API: User ID, JWT token
    API-->>WebApp: Auth token, redirect to dashboard
    
    Note over WebApp,User: INTAKE PHASE
    WebApp->>User: Display onboarding questions
    User->>WebApp: Submit goals, concerns
    WebApp->>API: POST /api/v1/intake
    API-->>WebApp: Intake ID
    
    Note over WebApp,User: WHEEL OF HAPPINESS
    WebApp->>User: Display Wheel of Happiness
    User->>WebApp: Rate 8 life areas (1-10)
    WebApp->>API: POST /api/v1/wheel-of-happiness
    API->>Assessment: Calculate bumpiness, priorities
    Assessment->>GraphDB: Store wheel data, link to goals
    Assessment-->>API: Priority areas [career, money, health]
    API-->>WebApp: Visual feedback, top priorities
    
    Note over WebApp,User: SUGGESTIBILITY ASSESSMENT
    WebApp->>User: Display questionnaire instructions
    User->>WebApp: Begin assessment
    
    loop For each question (1-36)
        WebApp->>User: Display question with helper panel
        User->>WebApp: Provide answer (yes/no)
        WebApp->>API: POST /api/v1/assessment/response (auto-save)
    end
    
    WebApp->>API: POST /api/v1/assessment/complete
    API->>Assessment: Calculate suggestibility scores
    Assessment->>Assessment: Q1 score (questions 1-2: 10pts, 3-18: 5pts)
    Assessment->>Assessment: Q2 score (all questions: 5pts)
    Assessment->>Assessment: Combined score = Q1 + Q2
    Assessment->>Assessment: Graph lookup (combined, Q1) -> Physical %
    Assessment->>Assessment: Emotional % = 100 - Physical %
    Assessment-->>API: Suggestibility profile
    
    alt If user has VR headset
        WebApp->>User: "Would you like to try finger-spreading test in VR?"
        User->>WebApp: Accept
        WebApp->>WebApp: Initialize WebXR session
        WebApp->>User: Display VR instructions
        User->>WebApp: Perform test (left arm - direct suggestions)
        WebApp->>API: Stream hand tracking data
        API->>Assessment: Analyze finger movement (speed, distance, latency)
        User->>WebApp: Perform test (right arm - inferred suggestions)
        WebApp->>API: Stream hand tracking data
        API->>Assessment: Compare left vs right responses
        Assessment->>Assessment: Classify as Physical/Emotional
        Assessment-->>API: ML-based suggestibility (confidence score)
        API->>Assessment: Combine questionnaire + ML results
    end
    
    Assessment->>GraphDB: CREATE (user)-[:HAS_SUGGESTIBILITY]->(profile)
    API-->>WebApp: Final suggestibility profile
    WebApp->>User: Show results with visualization
    
    Note over WebApp,User: PRE-INDUCTION SPEECH
    WebApp->>API: POST /api/v1/sessions/create
    API->>Orchestrator: Initialize first session
    Orchestrator->>Safety: Pre-session screening
    Safety->>GraphDB: Check contraindications
    GraphDB-->>Safety: No contraindications found
    Safety-->>Orchestrator: Approved to proceed
    
    Orchestrator->>Agents: Generate pre-induction speech
    Agents->>RAG: Retrieve HMI pre-induction template
    RAG->>VectorDB: Query "pre-induction speech + myth dispelling"
    VectorDB-->>RAG: Top 3 relevant chunks
    Agents->>LLM: Personalize for user profile
    LLM-->>Agents: Personalized pre-induction script
    Agents-->>Orchestrator: Pre-induction segment
    
    Orchestrator->>Voice: Synthesize speech (warm, professional voice)
    Voice-->>Orchestrator: Audio file
    Orchestrator->>API: Segment ready
    API-->>WebApp: Pre-induction audio + script
    WebApp->>User: Play audio with on-screen text
    
    Note over WebApp,User: THEORY OF MIND EDUCATION
    Orchestrator->>Agents: Generate Theory of Mind explanation
    Agents->>RAG: Retrieve TOM script template
    RAG->>VectorDB: Query "theory of mind education"
    VectorDB-->>RAG: TOM diagram script
    Agents->>LLM: Personalize to user's goal (e.g., career success)
    LLM-->>Agents: Personalized TOM script
    Agents-->>Orchestrator: TOM segment with diagram
    
    Orchestrator->>API: TOM segment ready
    API-->>WebApp: TOM script + diagram data
    WebApp->>User: Display animated TOM diagram with narration
    User->>WebApp: "I understand" (confirmation)
    
    Note over WebApp,User: ARM RAISING INDUCTION
    Orchestrator->>Safety: Continuous monitoring begins
    Orchestrator->>Agents: Generate induction
    
    Agents->>GraphDB: MATCH (user)-[:HAS_SUGGESTIBILITY]->(s {type: 'emotional'})
    GraphDB-->>Agents: Emotional suggestibility confirmed
    
    Agents->>RAG: Retrieve "emotional arm raising induction"
    RAG->>VectorDB: Semantic search (emotional + induction + first session)
    VectorDB-->>RAG: Top 5 script variations
    
    Agents->>LLM: Synthesize personalized induction
    Note over Agents,LLM: Uses inferential language:<br/>"allowing", "tendency",<br/>"as you begin to feel"
    LLM-->>Agents: Personalized induction script
    
    Agents->>Safety: Validate script for safety
    Safety->>Safety: Check for harmful suggestions
    Safety->>Safety: Verify emergence procedure included
    Safety-->>Agents: Approved
    
    Agents-->>Orchestrator: Induction segment
    Orchestrator->>Voice: Synthesize (slower pace, soothing voice)
    Voice-->>Orchestrator: Audio file
    Orchestrator->>API: Induction ready
    API-->>WebApp: Induction audio + biometric monitoring start
    
    WebApp->>User: Begin induction (5-4-3-2-1-0 Deep Sleep)
    
    loop Real-time adaptation
        User->>WebApp: Biometric data (HR, HRV, GSR via wearable/webcam)
        WebApp->>API: Stream biometric readings
        API->>Safety: Analyze user state
        
        alt If high stress detected (HR > 120, GSR > 0.9)
            Safety->>Orchestrator: Alert - elevated stress
            Orchestrator->>Agents: Modify script - add calming techniques
            Agents-->>Orchestrator: Adjusted script segment
            Orchestrator->>API: Send adjustment
            API-->>WebApp: Update delivery (slower pace, misdirection)
        end
        
        alt If too deep too fast (no response > 5 sec)
            Safety->>Orchestrator: Alert - possible excessive depth
            Orchestrator->>Agents: Lighten suggestions, check responsiveness
        end
    end
    
    Note over WebApp,User: DEEPENING TECHNIQUES
    Orchestrator->>Agents: Generate deepening sequence
    Agents->>RAG: Retrieve deepening techniques
    RAG->>VectorDB: Query "progressive relaxation + staircase"
    VectorDB-->>RAG: Deepening scripts
    Agents->>LLM: Personalize sequence
    LLM-->>Agents: Personalized deepening
    Agents-->>Orchestrator: Deepening segments
    
    Orchestrator->>Voice: Synthesize (even slower, deeper voice)
    Voice-->>Orchestrator: Audio files
    Orchestrator->>API: Deepening ready
    API-->>WebApp: Deepening audio
    WebApp->>User: Play deepening sequence
    
    Note over WebApp,User: THERAPEUTIC SUGGESTIONS
    Orchestrator->>Agents: Generate suggestions for goals
    
    Agents->>GraphDB: MATCH (user)-[:HAS_GOAL]->(g:Goal {category: 'career'})
    GraphDB-->>Agents: Career goal + related habits
    
    Agents->>GraphDB: MATCH (user)-[:HAS_SEXUALITY]->(s:Sexuality)
    GraphDB-->>Agents: Physical sexuality (70%)
    
    Note over Agents: Physical sexuality prioritizes:<br/>Connection, relationships, acceptance
    
    Agents->>RAG: Query "career success + physical sexuality + habit formation"
    RAG->>VectorDB: Hybrid search
    RAG->>GraphDB: Graph traversal for related suggestions
    VectorDB-->>RAG: Suggestion templates
    GraphDB-->>RAG: Identity statements, habit loops
    
    Agents->>LLM: Synthesize personalized suggestions
    Note over Agents,LLM: Emphasize connection & relationships:<br/>"You feel confident connecting with others,<br/>sharing your expertise naturally..."
    LLM-->>Agents: Personalized therapeutic suggestions
    
    Agents->>Safety: Validate suggestions
    Safety-->>Agents: Approved
    Agents-->>Orchestrator: Suggestion segments
    
    Orchestrator->>Voice: Synthesize (confident, affirming tone)
    Voice-->>Orchestrator: Audio files
    Orchestrator->>API: Suggestions ready
    API-->>WebApp: Suggestion audio
    WebApp->>User: Play therapeutic suggestions
    
    Note over WebApp,User: POST-HYPNOTIC SUGGESTION
    Orchestrator->>Agents: Generate PHS for re-hypnosis
    Agents->>RAG: Retrieve PHS template
    RAG->>VectorDB: Query "post hypnotic suggestion deep sleep"
    VectorDB-->>RAG: PHS script
    Agents-->>Orchestrator: PHS segment
    Orchestrator->>Voice: Synthesize
    Voice-->>Orchestrator: Audio
    Orchestrator->>API: PHS ready
    API-->>WebApp: PHS audio
    WebApp->>User: "Each time I suggest Deep Sleep..."
    
    Note over WebApp,User: EMERGENCE
    Orchestrator->>Agents: Generate emergence procedure
    Agents->>RAG: Retrieve emergence script
    RAG->>VectorDB: Query "emergence 0-5 count up"
    VectorDB-->>RAG: Emergence script
    Agents-->>Orchestrator: Emergence segment
    Orchestrator->>Voice: Synthesize (energizing, clear voice)
    Voice-->>Orchestrator: Audio
    Orchestrator->>API: Emergence ready
    API-->>WebApp: Emergence audio
    WebApp->>User: Count up 0-1-2-3-4-5 eyes open, wide awake
    
    User->>WebApp: Session complete, eyes open
    WebApp->>API: POST /api/v1/sessions/{id}/complete
    API->>Orchestrator: Finalize session
    Orchestrator->>GraphDB: Store session graph
    Orchestrator->>API: Session summary
    API-->>WebApp: Session data, next steps
    
    Note over WebApp,User: IMMEDIATE RE-INDUCTION TEST
    WebApp->>User: "Let's test the post-hypnotic suggestion"
    WebApp->>User: Display finger-spreading setup
    User->>WebApp: Perform finger-spreading
    WebApp->>API: Suggest "Deep Sleep" trigger
    API->>Voice: Synthesize "Deep Sleep"
    Voice-->>API: Audio
    API-->>WebApp: Trigger audio
    WebApp->>User: Play "Deep Sleep"
    User->>WebApp: Rapid re-induction (hand to forehead)
    WebApp->>User: Count up 0-5 again
    
    WebApp->>API: POST /api/v1/sessions/{id}/phs-test-complete
    API-->>WebApp: PHS validated
    
    Note over WebApp,User: HOMEWORK ASSIGNMENT
    WebApp->>User: "Complete E&P assessment for next session"
    User->>WebApp: Accept homework
    WebApp->>API: POST /api/v1/homework/assign
    
    Note over WebApp,User: SCHEDULE NEXT SESSION
    WebApp->>User: Display calendar
    User->>WebApp: Select date/time
    WebApp->>API: POST /api/v1/sessions/schedule
    API-->>WebApp: Session #2 scheduled
    WebApp->>User: Confirmation + summary email


    3.2 Real-Time Biometric Adaptation Sequence

    sequenceDiagram
    participant User
    participant WebApp
    participant BiometricSvc as Biometric Service
    participant Safety as Safety Guardian
    participant Orchestrator as Session Orchestrator
    participant RL as RL Adaptation Agent
    participant Voice as Voice Synthesis

    Note over User,Voice: During active hypnosis session
    
    loop Every 1 second
        User->>WebApp: Biometric data (wearable/webcam)
        Note over User,WebApp: HR: 95 bpm<br/>HRV: 45ms<br/>GSR: 0.65<br/>Respiration: 14/min
        
        WebApp->>BiometricSvc: POST /biometric/reading
        BiometricSvc->>BiometricSvc: Store in time-series DB
        BiometricSvc->>BiometricSvc: Calculate trends (5-sec window)
        
        BiometricSvc->>Safety: Analyze current state
        Safety->>Safety: Calculate stress score (0-1)
        Safety->>Safety: Check against thresholds
        
        alt Normal state (stress < 0.7)
            Safety->>Orchestrator: Status: Normal, continue
            Orchestrator->>WebApp: No changes needed
        
        else Elevated state (0.7 < stress < 0.9)
            Safety->>Orchestrator: Alert: Elevated stress
            Note over Safety: HR: 110, GSR: 0.85
            
            Orchestrator->>RL: Adapt script for elevated state
            RL->>RL: Calculate optimal adaptation
            Note over RL: Options:<br/>1. Slow pacing 10%<br/>2. Add misdirection<br/>3. Insert calming breath cue
            
            RL-->>Orchestrator: Adaptation plan
            Orchestrator->>Voice: Adjust voice parameters
            Note over Orchestrator,Voice: Pace: -10%<br/>Pitch: -5%<br/>Volume: -3dB
            Voice-->>Orchestrator: Updated audio config
            
            Orchestrator->>WebApp: WS: script_adaptation
            WebApp->>User: Apply changes (smoother delivery)
            
            Orchestrator->>BiometricSvc: Log adaptation event
        
        else High stress (stress >= 0.9)
            Safety->>Orchestrator: ALERT: High stress - pause suggestions
            
            Orchestrator->>RL: Emergency adaptation
            RL->>RL: Select calming intervention
            RL-->>Orchestrator: Insert breathing exercise
            
            Orchestrator->>Voice: Generate calming script
            Note over Voice: "Take a moment to breathe deeply...<br/>In through your nose...out through your mouth..."
            Voice-->>Orchestrator: Calming audio
            
            Orchestrator->>WebApp: WS: emergency_intervention
            WebApp->>User: Pause current script, play intervention
            
            Orchestrator->>BiometricSvc: Log high-stress event
            Orchestrator->>Safety: Monitor for improvement
            
            alt If stress decreases
                Safety->>Orchestrator: Stress reducing, resume
                Orchestrator->>WebApp: Resume main script
            else If stress persists > 60 seconds
                Safety->>Orchestrator: ESCALATE: Unable to calm
                Orchestrator->>Orchestrator: Initiate emergency emergence
                Orchestrator->>WebApp: WS: emergency_emergence
                WebApp->>User: Rapid count-up procedure
                Orchestrator->>Orchestrator: Flag for human review
            end
        end
    end

    3.3 Multi-Agent Collaboration Sequence
    sequenceDiagram
    participant Orchestrator as Session Orchestrator
    participant Planner as Session Planner (AutoGen)
    participant Safety as Safety Overseer (AutoGen)
    participant Crew as Tactical Crew (CrewAI)
    participant Induction as Induction Composer
    participant Deepening as Deepening Architect
    participant Suggestions as Suggestion Crafter
    participant RAG as RAG Engine
    participant MCP as MCP Servers
    participant LLM as Custom Hypnosis LLM

    Orchestrator->>Planner: Plan session for user
    Note over Orchestrator,Planner: User: ID-123<br/>Session: #1<br/>Profile: Emotional Sugg + Physical Sex
    
    Planner->>Planner: Analyze user profile
    Planner->>RAG: Query: Optimal protocol for this profile
    RAG->>RAG: Graph RAG reasoning
    RAG-->>Planner: Recommended approach
    
    Planner->>Planner: Create session strategy
    Note over Planner: Strategy:<br/>1. Emotional arm raising induction<br/>2. Progressive + staircase deepening<br/>3. Connection-focused suggestions<br/>4. Standard emergence
    
    Planner->>Safety: Review strategy for safety
    Safety->>MCP: Check contraindications
    MCP-->>Safety: No contraindications found
    Safety->>Safety: Validate protocol choices
    Safety-->>Planner: Strategy approved
    
    Planner-->>Orchestrator: Session plan
    
    Note over Orchestrator,Crew: BEGIN TACTICAL GENERATION
    
    Orchestrator->>Crew: Generate session components
    Crew->>Crew: Initialize crew with session plan
    
    Note over Crew: Sequential process: Induction → Deepening → Suggestions
    
    Crew->>Induction: Task: Generate induction
    Note over Induction: Agent receives:<br/>- User profile<br/>- Session plan<br/>- Emotional suggestibility flag
    
    Induction->>MCP: Call retrieve_induction tool
    Note over Induction,MCP: {<br/>  "suggestibility": "emotional",<br/>  "session_number": 1<br/>}
    MCP-->>Induction: Base induction script
    
    Induction->>RAG: Retrieve induction variations
    RAG-->>Induction: 5 similar scripts
    
    Induction->>LLM: Synthesize personalized induction
    Note over Induction,LLM: System: You are HMI induction composer<br/>User: Create emotional induction for user-123<br/>Context: Base script + variations<br/>Requirements: Inferential language, misdirection
    
    LLM-->>Induction: Personalized induction script
    
    Induction->>Safety: Validate induction
    Safety->>Safety: Check for harmful content
    Safety->>Safety: Verify structure
    Safety-->>Induction: Approved
    
    Induction-->>Crew: Induction component complete
    
    Crew->>Deepening: Task: Generate deepening
    Note over Crew: Deepening agent receives induction context
    
    Deepening->>MCP: Call retrieve_deepening tool
    MCP-->>Deepening: Progressive relaxation script
    
    Deepening->>RAG: Retrieve deepening techniques
    RAG-->>Deepening: Staircase, reactionary, heavy/light
    
    Deepening->>LLM: Synthesize deepening sequence
    LLM-->>Deepening: Personalized deepening
    
    Deepening->>Safety: Validate
    Safety-->>Deepening: Approved
    
    Deepening-->>Crew: Deepening component complete
    
    Crew->>Suggestions: Task: Generate suggestions
    Note over Suggestions: Agent receives full context:<br/>- Induction tone<br/>- Deepening level<br/>- User goals<br/>- E&P sexuality
    
    Suggestions->>RAG: Query: Career success + Physical sexuality
    RAG->>RAG: Hybrid search (vector + graph)
    RAG-->>Suggestions: Relevant suggestion templates + identity statements
    
    Suggestions->>LLM: Synthesize therapeutic suggestions
    Note over Suggestions,LLM: Prompt includes:<br/>- Goal: Career success<br/>- Sexuality: Physical (emphasize connection)<br/>- Habit loops from user's goals<br/>- Identity shift language
    
    LLM-->>Suggestions: Personalized suggestions
    
    Suggestions->>Safety: Validate suggestions
    Safety->>Safety: Check for unrealistic promises
    Safety->>Safety: Verify respect for autonomy
    Safety-->>Suggestions: Approved
    
    Suggestions-->>Crew: Suggestions component complete
    
    Crew->>Crew: Assemble complete session
    Crew->>Crew: Validate coherence and flow
    Crew-->>Orchestrator: Complete session script
    
    Orchestrator->>Safety: Final safety review
    Safety->>Safety: Check entire session
    Safety->>Safety: Verify emergence included
    Safety-->>Orchestrator: Approved for delivery
    
    Orchestrator-->>Orchestrator: Session ready

    3.4 Safety Escalation Sequence

    sequenceDiagram
    participant User
    participant System
    participant Safety as Safety Guardian
    participant Orchestrator
    participant Therapist as Human Therapist
    participant Emergency as Emergency Protocol

    Note over User,Emergency: SCENARIO: User shows signs of severe distress
    
    User->>System: Biometric spike (HR: 145, GSR: 0.95)
    User->>System: Verbal cue: "I can't do this"
    
    System->>Safety: Alert: Multiple distress indicators
    Safety->>Safety: Assess severity
    Note over Safety: Severity score: 0.92 (CRITICAL)
    
    Safety->>Safety: Check against escalation triggers
    Note over Safety: Triggers met:<br/>✓ Sustained high stress (>60 sec)<br/>✓ Verbal distress<br/>✓ Unable to calm with interventions
    
    Safety->>Orchestrator: ESCALATE: Severe distress
    
    Orchestrator->>Emergency: Initiate emergency emergence
    Emergency->>System: Pause all therapeutic content
    Emergency->>System: Begin rapid emergence protocol
    
    System->>User: "We're going to bring you back up now"
    System->>User: Count up 0-1-2-3-4-5 (accelerated pace)
    System->>User: Eyes open, wide awake
    
    User->>System: Eyes open, breathing heavily
    
    System->>User: Display calming visuals
    System->>User: "You're safe. Take your time."
    
    Emergency->>Safety: User emerged, monitoring
    
    Safety->>Safety: Continue biometric monitoring
    
    alt If user stabilizes within 5 minutes
        Safety->>Orchestrator: User stabilizing
        Orchestrator->>System: Display support message
        System->>User: "How are you feeling? Would you like to talk to a therapist?"
        
        User->>System: "I'd like to talk to someone"
        
        System->>Therapist: Alert: User requests support
        Note over Therapist: Priority queue:<br/>User: ID-123<br/>Incident: Severe distress during session<br/>Time: 2 min ago
        
        Therapist->>System: Accept connection
        System->>User: "A therapist will be with you shortly"
        
        Therapist->>User: Video call established
        Note over Therapist,User: Therapist provides<br/>emotional support,<br/>assesses needs
        
        Therapist->>System: Log incident notes
        Therapist->>System: Recommend follow-up protocol
        
    else If distress persists or worsens
        Safety->>Emergency: CRITICAL: Unable to stabilize
        Emergency->>System: Display crisis resources
        System->>User: "If this is an emergency, call 911"
        System->>User: Crisis hotline numbers
        
        Emergency->>Therapist: URGENT: Immediate intervention needed
        Note over Emergency,Therapist: Incident severity: CRITICAL<br/>Automatic therapist paging
        
        Therapist->>User: Immediate contact attempt
        
        Emergency->>Emergency: Log critical incident
        Emergency->>Emergency: Flag user account for review
    end
    
    Safety->>Orchestrator: Incident resolved
    Orchestrator->>Orchestrator: Generate incident report
    Orchestrator->>Therapist: Send full session data
    Orchestrator->>Therapist: Include biometric timeline
    Orchestrator->>Therapist: Include AI decision log
    
    Note over Orchestrator,Therapist: User account flagged:<br/>"Requires human approval for future sessions"


    Part 4: State Machines
4.1 Session Orchestration State Machine
┌─────────────────────────────────────────────────────────────────────┐
│                    SESSION ORCHESTRATION STATE MACHINE               │
└─────────────────────────────────────────────────────────────────────┘

States:
[IDLE] → [PLANNED] → [INTAKE] → [PRE_INDUCTION] → [ASSESSMENT] → 
[THEORY_OF_MIND] → [INDUCTION] → [DEEPENING] → [SUGGESTIONS] → 
[POST_HYPNOTIC] → [EMERGENCE] → [COMPLETED]

                                    ╔══════════╗
                                    ║   IDLE   ║
                                    ╚═════╤════╝
                                          │
                                          │ user_starts_session
                                          │ / create_session_record()
                                          │
                                    ╔═════▼════╗
                                    ║ PLANNED  ║
                                    ╚═════╤════╝
                                          │
                                          │ session_scheduled
                                          │ / notify_user()
                                          │
                                    ╔═════▼════╗
                       ┌────────────║  INTAKE  ║
                       │            ╚═════╤════╝
                       │                  │
                       │                  │ intake_complete
                       │                  │ [has_profile] / load_profile()
                       │                  │
                       │            ╔═════▼════════════╗
                       │            ║  PRE_INDUCTION   ║
                       │            ╚═════╤════════════╝
                       │                  │
                       │                  │ pre_induction_complete
                       │                  │ [needs_assessment] / start_assessment()
                       │                  │ [has_assessment] / skip_to_tom()
                       │                  │
                       │            ╔═════▼═══════════╗
                       │            ║   ASSESSMENT    ║◄──┐
                       │            ╠═════════════════╣   │
                       │            ║ Sub-states:     ║   │
                       │            ║ • Suggestibility║   │
                       │            ║ • E&P Sexuality ║   │ pause_requested
                       │            ║ • Wheel of Life ║   │ / save_progress()
                       │            ╚═════╤═══════════╝   │
                       │                  │                │
                       │                  │ assessment_complete  │
                       │ pause_requested  │ / generate_profile() │
                       │ / save_state()   │                      │
                       │                  │                      │
                       │            ╔═════▼═════════════╗        │
                       └───────────►║     PAUSED        ║────────┘
                                    ║                   ║
                                    ║ • User can resume │
                                    ║ • Auto-resume     │
                                    ║   after timeout   │
                                    ╚═════╤═════════════╝
                                          │
                                          │ resume_requested
                                          │ / restore_state()
                                          │
                                    ╔═════▼══════════════╗
                                    ║ THEORY_OF_MIND     ║
                                    ╚═════╤══════════════╝
                                          │
                                          │ tom_complete
                                          │ [safety_check_passed] / begin_hypnosis()
                                          │
                      ┌───────────────────┼────────────────────┐
                      │                   │                    │
              [contraindication]  ╔═════▼═════════╗   [safety_approved]
              / escalate()        ║   INDUCTION   ║
                      │           ╠═══════════════╣
                      │           ║ • Arm raising ║
                      │           ║ • PHS install ║
                      │           ║ • Biometric   ║
                      │           ║   monitoring  ║
                      │           ╚═════╤═════════╝
                      │                 │
                      │                 │ induction_complete
                      │                 │ [depth_adequate] / proceed_deepening()
                      │                 │
                      │           ╔═════▼═════════╗
                      │           ║  DEEPENING    ║
                      │           ╠═══════════════╣
                      │           ║ • Progressive ║
                      │           ║ • Staircase   ║
                      │           ║ • Challenges  ║
                      │           ╚═════╤═════════╝
                      │                 │
                      │                 │ deepening_complete
                      │                 │ [user_responsive] / deliver_suggestions()
                      │                 │
                      │           ╔═════▼══════════════╗
                      │           ║   SUGGESTIONS      ║◄──┐
                      │           ╠════════════════════╣   │
                      │           ║ • Goal-based       ║   │
                      │           ║ • Identity shift   ║   │ high_stress_detected
                      │           ║ • Habit formation  ║   │ / insert_calming()
                      │           ║ • Adaptive         ║   │
                      │           ╚═════╤══════════════╝   │
                      │                 │                  │
                      │                 │ suggestions_complete
                      │                 │ / prepare_emergence()
                      │                 │
                      │           ╔═════▼══════════════╗
                      │           ║  POST_HYPNOTIC     ║
                      │           ╠════════════════════╣
                      │           ║ • Reinforce PHS    ║
                      │           ║ • Dream therapy    ║
                      │           ╚═════╤══════════════╝
                      │                 │
                      │                 │ phs_complete
                      │                 │ / begin_emergence()
                      │                 │
                      │           ╔═════▼══════════════╗
                      │           ║   EMERGENCE        ║
                      │           ╠════════════════════╣
                      │           ║ • Count up 0-5     ║
                      │           ║ • Eyes open        ║
                      │           ║ • Wide awake       ║
                      │           ╚═════╤══════════════╝
                      │                 │
                      │                 │ emergence_complete
                      │                 │ / finalize_session()
                      │                 │
                      │           ╔═════▼══════════════╗
                      │           ║   COMPLETED        ║
                      │           ╠════════════════════╣
                      │           ║ • Store session    ║
                      │           ║ • Generate report  ║
                      │           ║ • Schedule next    ║
                      │           ╚════════════════════╝
                      │
                      │
                ╔═════▼═════════╗
                ║   ESCALATED   ║
                ╠═══════════════╣
                ║ • Emergency   ║
                ║   emergence   ║
                ║ • Alert human ║
                ║ • Log incident║
                ╚═══════════════╝

Guards (Conditions):
- [has_profile]: User has completed assessments
- [needs_assessment]: First-time user
- [safety_check_passed]: No contraindications detected
- [depth_adequate]: User reached appropriate hypnotic depth
- [user_responsive]: User responding to suggestions
- [contraindication]: Safety issue detected

Actions (Side effects):
- create_session_record(): Initialize session in database
- load_profile(): Retrieve user's unified profile
- generate_profile(): Create unified profile from assessments
- begin_hypnosis(): Activate biometric monitoring, safety protocols
- insert_calming(): Inject calming technique mid-session
- finalize_session(): Store data, generate analytics
- escalate(): Emergency protocol, notify human therapist

4.2 Assessment Flow State Machine

┌─────────────────────────────────────────────────────────────────────┐
│                    ASSESSMENT FLOW STATE MACHINE                     │
└─────────────────────────────────────────────────────────────────────┘

                          ╔═══════════════════╗
                          ║ ASSESSMENT_START  ║
                          ╚═════════╤═════════╝
                                    │
                                    │ determine_assessment_type
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
         [first_time_user]    [has_sugg]    [has_sugg && needs_ep]
                    │               │               │
        ╔═══════════▼═══════════╗   │   ╔═══════════▼═══════════╗
        ║ SUGGESTIBILITY_QUEST  ║   │   ║  E&P_ASSESSMENT       ║
        ╠═══════════════════════╣   │   ╠═══════════════════════╣
        ║                       ║   │   ║                       ║
        ║ State Data:           ║   │   ║ State Data:           ║
        ║ • current_q: 1-36     ║   │   ║ • current_trait: 1-4  ║
        ║ • q1_score: int       ║   │   ║ • family_tree: {}     ║
        ║ • q2_score: int       ║   │   ║ • relationships: []   ║
        ║ • responses: []       ║   │   ║ • traits_complete: [] ║
        ║                       ║   │   ║                       ║
        ║ Sub-states:           ║   │   ║ Sub-states:           ║
        ║ ┌──────────────────┐ ║   │   ║ ┌──────────────────┐ ║
        ║ │ QUESTION_1_18    │ ║   │   ║ │ FAMILY_ORIGIN    │ ║
        ║ │   (Q1)           │ ║   │   ║ │                  │ ║
        ║ └────────┬─────────┘ ║   │   ║ └────────┬─────────┘ ║
        ║          │           ║   │   ║          │           ║
        ║          │ q18_done  ║   │   ║          │ trait_1_done
        ║          │           ║   │   ║          │           ║
        ║ ┌────────▼─────────┐ ║   │   ║ ┌────────▼─────────┐ ║
        ║ │ QUESTION_19_36   │ ║   │   ║ │ REJECTION_RESP   │ ║
        ║ │   (Q2)           │ ║   │   ║ │                  │ ║
        ║ └────────┬─────────┘ ║   │   ║ └────────┬─────────┘ ║
        ║          │           ║   │   ║          │           ║
        ║          │ q36_done  ║   │   ║          │ trait_2_done
        ║          │           ║   │   ║          │           ║
        ║ ┌────────▼─────────┐ ║   │   ║ ┌────────▼─────────┐ ║
        ║ │ SCORING          │ ║   │   ║ │ BODY_CONNECTION  │ ║
        ║ │ • Calculate Q1   │ ║   │   ║ │                  │ ║
        ║ │ • Calculate Q2   │ ║   │   ║ └────────┬─────────┘ ║
        ║ │ • Graph lookup   │ ║   │   ║          │           ║
        ║ └────────┬─────────┘ ║   │   ║          │ trait_3_done
        ║          │           ║   │   ║          │           ║
        ╚══════════╪═══════════╝   │   ║ ┌────────▼─────────┐ ║
                   │               │   ║ │ RELATIONSHIP_PAT │ ║
                   │ scoring_done  │   ║ │                  │ ║
                   │               │   ║ └────────┬─────────┘ ║
        ╔══════════▼═══════════╗   │   ║          │           ║
        ║ FINGER_TEST_OPTIONAL ║   │   ║          │ trait_4_done
        ╠══════════════════════╣   │   ║          │           ║
        ║ [if has_vr_headset]  ║   │   ║ ┌────────▼─────────┐ ║
        ║                      ║   │   ║ │ CLASSIFICATION   │ ║
        ║ Sub-states:          ║   │   ║ │ • Evaluate 3/4   │ ║
        ║ ┌──────────────────┐ ║   │   ║ │ • Apply modifiers│ ║
        ║ │ CALIBRATION      │ ║   │   ║ │ • Calculate %    │ ║
        ║ └────────┬─────────┘ ║   │   ║ └────────┬─────────┘ ║
        ║          │           ║   │   ║          │           ║
        ║ ┌────────▼─────────┐ ║   │   ╚══════════╪═══════════╝
        ║ │ LEFT_ARM_TEST    │ ║   │              │
        ║ │ (Direct)         │ ║   │              │ ep_complete
        ║ └────────┬─────────┘ ║   │              │
        ║          │           ║   │   ╔══════════▼═══════════╗
        ║ ┌────────▼─────────┐ ║   │   ║ WHEEL_OF_HAPPINESS   ║
        ║ │ RIGHT_ARM_TEST   │ ║   │   ╠══════════════════════╣
        ║ │ (Inferred)       │ ║   │   ║                      ║
        ║ └────────┬─────────┘ ║   │   ║ State Data:          ║
        ║          │           ║   │   ║ • area_ratings: {}   ║
        ║ ┌────────▼─────────┐ ║   │   ║ • current_area: 1-8  ║
        ║ │ ML_CLASSIFICATION│ ║   │   ║                      ║
        ║ │ • Compare L vs R │ ║   │   ║ Sub-states:          ║
        ║ │ • Confidence     │ ║   │   ║ ┌──────────────────┐ ║
        ║ └────────┬─────────┘ ║   │   ║ │ RATING_AREAS     │ ║
        ║          │           ║   │   ║ │ • Health         │ ║
        ╚══════════╪═══════════╝   │   ║ │ • Family/Friends │ ║
                   │               │   ║ │ • Career         │ ║
                   │ finger_test_done  ║ │ • Romance        │ ║
                   │               │   ║ │ • Fun            │ ║
        ╔══════════▼═══════════╗   │   ║ │ • Money          │ ║
        ║ SUGG_PROFILE_READY   ║   │   ║ │ • Environment    │ ║
        ╠══════════════════════╣   │   ║ │ • Growth         │ ║
        ║ • Store results      ║   │   ║ └────────┬─────────┘ ║
        ║ • Update user profile║   │   ║          │           ║
        ╚══════════╤═══════════╝   │   ║          │ all_rated ║
                   │               │   ║          │           ║
                   └───────────────┼───╫──────────┘           ║
                                   │   ║ ┌──────────────────┐ ║
                                   │   ║ │ CALCULATION      │ ║
                                   │   ║ │ • Average        │ ║
                                   │   ║ │ • Bumpiness      │ ║
                                   │   ║ │ • Priorities     │ ║
                                   │   ║ └────────┬─────────┘ ║
                                   │   ║          │           ║
                                   │   ╚══════════╪═══════════╝
                                   │              │
                                   │              │ wheel_complete
                                   │              │
                        ╔══════════▼══════════════▼══════════╗
                        ║   UNIFIED_PROFILE_GENERATION       ║
                        ╠════════════════════════════════════╣
                        ║                                    ║
                        ║ Actions:                           ║
                        ║ 1. Combine Sugg + Sex profiles     ║
                        ║ 2. Apply 10% adjustment rule       ║
                        ║ 3. Generate session config         ║
                        ║    • Induction style               ║
                        ║    • Language patterns             ║
                        ║    • Voice characteristics         ║
                        ║ 4. Link to goals (from Wheel)      ║
                        ║ 5. Create knowledge graph nodes    ║
                        ║ 6. Store unified profile           ║
                        ║                                    ║
                        ╚════════════════╤═══════════════════╝
                                         │
                                         │ profile_ready
                                         │
                        ╔════════════════▼═══════════════════╗
                        ║   ASSESSMENT_COMPLETE              ║
                        ╠════════════════════════════════════╣
                        ║ • Notify session orchestrator      ║
                        ║ • Display results to user          ║
                        ║ • Ready for first session          ║
                        ╚════════════════════════════════════╝

Transitions with Guards:
- [first_time_user]: No prior assessments → Full assessment flow
- [has_sugg]: Has suggestibility → Skip to E&P if relationship goals
- [has_sugg && needs_ep]: Has sugg, relationship goals → E&P + Wheel
- [has_vr_headset]: VR available → Optional finger test
- [no_vr]: No VR → Skip finger test
- [3_of_4_traits]: 3+ core traits evaluated → Can classify sexuality
- [<3_traits]: Less than 3 traits → More data needed

State Data Persistence:
- Auto-save every 30 seconds
- Save on page navigation
- Resume from any sub-state
- Expire draft after 7 days

4.3 Multi-Agent Collaboration State Machine

┌─────────────────────────────────────────────────────────────────────┐
│              MULTI-AGENT COLLABORATION STATE MACHINE                 │
└─────────────────────────────────────────────────────────────────────┘

                        ╔═════════════════════╗
                        ║   AGENT_IDLE        ║
                        ╚═══════════╤═════════╝
                                    │
                                    │ session_request_received
                                    │ / load_user_profile()
                                    │
                        ╔═══════════▼═════════╗
                        ║  STRATEGIC_PLANNING ║
                        ╠═════════════════════╣
                        ║ Agents Active:      ║
                        ║ • SessionPlanner    ║
                        ║ • SafetyOverseer    ║
                        ╚═══════════╤═════════╝
                                    │
                                    │
              ┌─────────────────────┼─────────────────────┐
              │                     │                     │
    ╔═════════▼═════════╗ ╔════════▼═════════╗ ╔════════▼═════════╗
    ║ PLANNER_ANALYZING ║ ║ SAFETY_CHECKING  ║ ║ RAG_QUERYING     ║
    ╠═══════════════════╣ ╠══════════════════╣ ╠══════════════════╣
    ║ • Analyze profile ║ ║ • Check contra-  ║ ║ • Query graph    ║
    ║ • Identify goals  ║ ║   indications    ║ ║ • Retrieve       ║
    ║ • Prioritize      ║ ║ • Review history ║ ║   protocols      ║
    ║ • Create strategy ║ ║ • Validate safety║ ║ • Find patterns  ║
    ╚═════════╤═════════╝ ╚════════╤═════════╝ ╚════════╤═════════╝
              │                     │                     │
              │                     │                     │
              └─────────────────────┼─────────────────────┘
                                    │
                                    │ [all_checks_pass]
                                    │ / create_session_plan()
                                    │
                        ╔═══════════▼══════════════╗
                        ║  STRATEGY_APPROVED       ║
                        ╠══════════════════════════╣
                        ║ Session Plan:            ║
                        ║ • Induction type         ║
                        ║ • Deepening sequence     ║
                        ║ • Suggestion themes      ║
                        ║ • Safety protocols       ║
                        ║ • Estimated duration     ║
                        ╚═══════════╤══════════════╝
                                    │
                                    │ begin_tactical_generation
                                    │ / activate_crew()
                                    │
                        ╔═══════════▼══════════════╗
                        ║  CREW_INITIALIZATION     ║
                        ╠══════════════════════════╣
                        ║ • Load session plan      ║
                        ║ • Assign tasks to agents ║
                        ║ • Set up communication   ║
                        ╚═══════════╤══════════════╝
                                    │
                                    │ crew_ready
                                    │
                        ╔═══════════▼══════════════╗
                        ║  INDUCTION_GENERATION    ║
                        ╠══════════════════════════╣
                        ║ Agent: InductionComposer ║
                        ║                          ║
                        ║ Sub-states:              ║
                        ║ ┌──────────────────────┐ ║
                        ║ │ TOOL_CALLING         │ ║
                        ║ │ • MCP: retrieve_ind. │ ║
                        ║ │ • RAG: query vectors │ ║
                        ║ └──────────┬───────────┘ ║
                        ║            │             ║
                        ║ ┌──────────▼───────────┐ ║
                        ║ │ LLM_SYNTHESIS        │ ║
                        ║ │ • Personalize script │ ║
                        ║ │ • Apply E/P patterns │ ║
                        ║ └──────────┬───────────┘ ║
                        ║            │             ║
                        ║ ┌──────────▼───────────┐ ║
                        ║ │ SAFETY_VALIDATION    │ ║
                        ║ │ • Check harmful      │ ║
                        ║ │ • Verify structure   │ ║
                        ║ └──────────┬───────────┘ ║
                        ║            │             ║
                        ╚════════════╪═════════════╝
                                     │
                        [validation_pass] │ [validation_fail]
                                     │         │
                        ┌────────────┴─────────┴────────────┐
                        │                                    │
            ╔═══════════▼═════════╗           ╔═════════════▼══════════╗
            ║ INDUCTION_APPROVED  ║           ║ REGENERATION_REQUIRED   ║
            ╠═════════════════════╣           ╠════════════════════════╣
            ║ • Store in context  ║           ║ • Log issue             ║
            ║ • Share with crew   ║           ║ • Adjust parameters     ║
            ╚═════════╤═══════════╝           ║ • Retry generation      ║
                      │                       ╚════════════╤═══════════╝
                      │                                    │
                      │                                    │ retry
                      │                                    │
                      │              ┌─────────────────────┘
                      │              │
                      │ induction_complete
                      │
            ╔═════════▼══════════════╗
            ║ DEEPENING_GENERATION   ║
            ╠════════════════════════╣
            ║ Agent: DeepeningArchitect
            ║                        ║
            ║ Context Available:     ║
            ║ • Induction tone       ║
            ║ • User profile         ║
            ║ • Session plan         ║
            ║                        ║
            ║ [Same sub-states as    ║
            ║  Induction]            ║
            ╚════════════╤═══════════╝
                         │
                         │ deepening_complete
                         │
            ╔════════════▼═══════════╗
            ║ SUGGESTIONS_GENERATION ║
            ╠════════════════════════╣
            ║ Agent: SuggestionCrafter
            ║                        ║
            ║ Context Available:     ║
            ║ • Full session so far  ║
            ║ • User goals           ║
            ║ • E&P sexuality        ║
            ║ • Habit loops          ║
            ║ • Identity statements  ║
            ║                        ║
            ║ Additional Tools:      ║
            ║ • Graph RAG traversal  ║
            ║ • Goal decomposition   ║
            ║ • Habit loop builder   ║
            ╚════════════╤═══════════╝
                         │
                         │ suggestions_complete
                         │
            ╔════════════▼═══════════╗
            ║ EMERGENCE_GENERATION   ║
            ╠════════════════════════╣
            ║ Agent: EmergenceProtocol
            ║                        ║
            ║ • Standard count-up    ║
            ║ • Post-hypnotic sugg.  ║
            ║ • Safety checks        ║
            ╚════════════╤═══════════╝
                         │
                         │ emergence_complete
                         │
            ╔════════════▼═══════════╗
            ║   ASSEMBLY             ║
            ╠════════════════════════╣
            ║ • Combine all segments ║
            ║ • Validate coherence   ║
            ║ • Check flow           ║
            ║ • Ensure completeness  ║
            ╚════════════╤═══════════╝
                         │
                         │ [coherence_check]
                         │
            ┌────────────┴────────────┐
            │                         │
[pass]      │                         │ [fail]
            │                         │
╔═══════════▼═════════╗   ╔═══════════▼══════════╗
║ FINAL_SAFETY_REVIEW ║   ║ COHERENCE_FIX        ║
╠═════════════════════╣   ╠══════════════════════╣
║ • Review complete   ║   ║ • Identify gaps      ║
║   session           ║   ║ • Re-generate        ║
║ • Check emergence   ║   ║   problematic segment║
║ • Verify no harmful ║   ║ • Re-validate        ║
║ • Approve delivery  ║   ╚══════════╤═══════════╝
╚═════════╤═══════════╝              │
          │                          │ fixed
          │                          │
          │              ┌───────────┘
          │              │
          │ final_approval
          │
╔═════════▼═════════════════╗
║  SESSION_READY            ║
╠═══════════════════════════╣
║ • All segments generated  ║
║ • Safety approved         ║
║ • Voice synthesis queued  ║
║ • Ready for delivery      ║
╚═════════╤═════════════════╝
          │
          │ begin_delivery
          │
╔═════════▼═════════════════╗
║  MONITORING               ║
╠═══════════════════════════╣
║ • Track delivery          ║
║ • Monitor biometrics      ║
║ • Adapt if needed         ║
║ • Log all events          ║
╚═══════════╤═════════════════╝
            │
            │ session_complete
            │
╔═══════════▼═════════════════╗
║  AGENT_COMPLETE             ║
╠═════════════════════════════╣
║ • Store session data        ║
║ • Generate analytics        ║
║ • Clean up resources        ║
║ • Return to idle            ║
╚═════════════════════════════╝

Parallel States (During Generation):
┌────────────────────────────────────────┐
│ While any agent is working:            │
│                                        │
│ ╔═══════════════════════════════════╗ │
│ ║ SAFETY_OVERSEER (Always Active)   ║ │
│ ╠═══════════════════════════════════╣ │
│ ║ • Monitors all agent outputs      ║ │
│ ║ • Can halt generation at any time ║ │
│ ║ • Validates each segment          ║ │
│ ║ • Logs all decisions              ║ │
│ ╚═══════════════════════════════════╝ │
└────────────────────────────────────────┘

4.4 User Journey State Machine (Macro-Level)
┌─────────────────────────────────────────────────────────────────────┐
│                  USER JOURNEY STATE MACHINE                          │
└─────────────────────────────────────────────────────────────────────┘

                    ╔═══════════════════════╗
                    ║   NEW_VISITOR         ║
                    ╚═════════╤═════════════╝
                              │
                              │ land_on_site
                              │
                    ╔═════════▼═════════════╗
                    ║   EXPLORING           ║
                    ╠═══════════════════════╣
                    ║ • View landing page   ║
                    ║ • Read about HMI      ║
                    ║ • Watch demo video    ║
                    ║ • Check pricing       ║
                    ╚═════════╤═════════════╝
                              │
                              │ signup_initiated
                              │
                    ╔═════════▼═════════════╗
                    ║   REGISTERING         ║
                    ╠═══════════════════════╣
                    ║ • Create account      ║
                    ║ • Email verification  ║
                    ║ • Accept terms        ║
                    ╚═════════╤═════════════╝
                              │
                              │ registration_complete
                              │
                    ╔═════════▼═════════════╗
                    ║   ONBOARDING          ║
                    ╠═══════════════════════╣
                    ║ • Welcome tour        ║
                    ║ • Goal questionnaire  ║
                    ║ • Consent forms       ║
                    ║ • Platform tutorial   ║
                    ╚═════════╤═════════════╝
                              │
                              │ onboarding_complete
                              │
                    ╔═════════▼═════════════╗
                    ║   FIRST_ASSESSMENT    ║
                    ╠═══════════════════════╣
                    ║ • Suggestibility test ║
                    ║ • Wheel of Happiness  ║
                    ║ • Profile generation  ║
                    ╚═════════╤═════════════╝
                              │
                              │ profile_ready
                              │
                    ╔═════════▼═════════════╗
                    ║   FIRST_SESSION_PREP  ║
                    ╠═══════════════════════╣
                    ║ • Schedule session    ║
                    ║ • Setup reminders     ║
                    ║ • Prepare environment ║
                    ║ • Review what to      ║
                    ║   expect              ║
                    ╚═════════╤═════════════╝
                              │
                              │ session_starts
                              │
                    ╔═════════▼═════════════╗
                    ║   IN_SESSION          ║
                    ╠═══════════════════════╣
                    ║ • Active hypnosis     ║
                    ║ • Biometric tracking  ║
                    ║ • Real-time safety    ║
                    ╚═════════╤═════════════╝
                              │
                              │ session_ends
                              │
              ┌───────────────┼───────────────┐
              │               │               │
    [positive_exp]    [neutral_exp]    [negative_exp]
              │               │               │
    ╔═════════▼═══╗  ╔════════▼═════╗  ╔═════▼═════════╗
    ║   ENGAGED   ║  ║   HESITANT   ║  ║  AT_RISK      ║
    ╠═════════════╣  ╠══════════════╣  ╠═══════════════╣
    ║ • Books next║  ║ • Waits      ║  ║ • May churn   ║
    ║   session   ║  ║ • Evaluates  ║  ║ • Needs       ║
    ║ • Completes ║  ║ • Considers  ║  ║   intervention║
    ║   homework  ║  ║   continuing ║  ╚═══════╤═══════╝
    ╚═════════╤═══╝  ╚══════╤═══════╝          │
              │              │                  │
              │              │                  │ escalate_to_support
              │              │                  │
              │              │         ╔════════▼═══════════╗
              │              │         ║  SUPPORT_CONTACT   ║
              │              │         ╠════════════════════╣
              │              │         ║ • Human outreach   ║
              │              │         ║ • Address concerns ║
              │              │         ║ • Adjust plan      ║
              │              │         ╚════════╤═══════════╝
              │              │                  │
              │              │        [issue_resolved]
              │              │                  │
              │              └──────────────────┘
              │                       │
              │ continue_sessions     │
              │                       │
    ╔═════════▼═══════════════════════▼═════════════╗
    ║            ACTIVE_USER                        ║
    ╠═══════════════════════════════════════════════╣
    ║                                               ║
    ║ Recurring States:                             ║
    ║ ┌───────────────────────────────────────────┐ ║
    ║ │ SESSION_CYCLE                             │ ║
    ║ │ ┌──────────┐    ┌──────────┐            │ ║
    ║ │ │ Session  │───►│ Homework │            │ ║
    ║ │ └────┬─────┘    └────┬─────┘            │ ║
    ║ │      │               │                   │ ║
    ║ │      └───────┬───────┘                   │ ║
    ║ │              │                           │ ║
    ║ │      ┌───────▼────────┐                 │ ║
    ║ │      │ Progress Review│                 │ ║
    ║ │      └───────┬────────┘                 │ ║
    ║ │              │                           │ ║
    ║ │      ┌───────▼────────┐                 │ ║
    ║ │      │   Next Session │                 │ ║
    ║ │      └────────────────┘                 │ ║
    ║ └───────────────────────────────────────────┘ ║
    ║                                               ║
    ║ Milestones:                                   ║
    ║ • Session 3: E&P Assessment (if relationship  ║
    ║   goals)                                      ║
    ║ • Session 5: Progress evaluation              ║
    ║ • Session 10: Goal reassessment               ║
    ║                                               ║
    ╚═══════════════════════════════╤═══════════════╝
                                    │
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
           [goals_achieved]  [ongoing]      [plateau_reached]
                    │               │               │
        ╔═══════════▼═════╗         │     ╔═════════▼═══════╗
        ║   COMPLETION    ║         │     ║  REASSESSMENT   ║
        ╠═════════════════╣         │     ╠═════════════════╣
        ║ • Celebrate     ║         │     ║ • New Wheel     ║
        ║ • Final session ║         │     ║ • Adjust goals  ║
        ║ • Export data   ║         │     ║ • Refresh plan  ║
        ║ • Maintenance   ║         │     ╚═════════╤═══════╝
        ║   plan          ║         │               │
        ╚═════════╤═══════╝         │               │ new_plan_created
                  │                 │               │
                  │                 │               └──────┐
                  │                 │                      │
                  │         [continues] │                  │
                  │                 │                      │
                  │                 ▼                      │
                  │     ╔═══════════════════╗             │
                  │     ║  MAINTENANCE      ║◄────────────┘
                  │     ╠═══════════════════╣
                  │     ║ • Monthly check-in║
                  │     ║ • Booster sessions║
                  │     ║ • Community       ║
                  │     ╚═══════════════════╝
                  │
                  │ transition_to_maintenance
                  │
        ╔═════════▼═════════════════╗
        ║   GRADUATE                ║
        ╠═══════════════════════════╣
        ║ • Certificate of          ║
        ║   completion              ║
        ║ • Referral program        ║
        ║ • Alumni community        ║
        ║ • Optional continued      ║
        ║   access                  ║
        ╚═══════════════════════════╝

Exit States (User leaves platform):
┌────────────────────────────────────────┐
│                                        │
│ ╔════════════════════════════════════╗ │
│ ║  CHURNED                           ║ │
│ ╠════════════════════════════════════╣ │
│ ║ Reasons:                           ║ │
│ ║ • No improvement seen              ║ │
│ ║ • Too expensive                    ║ │
│ ║ • Uncomfortable with hypnosis      ║ │
│ ║ • Found alternative solution       ║ │
│ ║                                    ║ │
│ ║ Recovery:                          ║ │
│ ║ • Win-back campaigns               ║ │
│ ║ • Surveys for feedback             ║ │
│ ║ • Special offers                   ║ │
│ ╚════════════════════════════════════╝ │
└────────────────────────────────────────┘

4.5 Safety Monitoring State Machine
┌─────────────────────────────────────────────────────────────────────┐
│                 SAFETY MONITORING STATE MACHINE                      │
└─────────────────────────────────────────────────────────────────────┘

                        ╔═══════════════════╗
                        ║  SAFETY_INACTIVE  ║
                        ╚═════════╤═════════╝
                                  │
                                  │ session_begins
                                  │ / initialize_monitoring()
                                  │
                        ╔═════════▼═════════╗
                        ║  MONITORING_ACTIVE║
                        ╚═════════╤═════════╝
                                  │
            ┌─────────────────────┼─────────────────────┐
            │                     │                     │
    ╔═══════▼═════════╗  ╔════════▼═════════╗  ╔══════▼════════╗
    ║ BIOMETRIC_CHECK ║  ║ CONTENT_SAFETY   ║  ║ USER_RESPONSE ║
    ╠═════════════════╣  ╠══════════════════╣  ╠═══════════════╣
    ║ Every 1 second: ║  ║ Every segment:   ║  ║ Continuous:   ║
    ║ • HR            ║  ║ • Validate       ║  ║ • Verbal cues ║
    ║ • HRV           ║  ║ • No harmful     ║  ║ • Body        ║
    ║ • GSR           ║  ║   suggestions    ║  ║   language    ║
    ║ • Respiration   ║  ║ • Autonomy       ║  ║ • Engagement  ║
    ║ • Eye tracking  ║  ║   respected      ║  ║ • Response    ║
    ║                 ║  ║ • Emergence OK   ║  ║   time        ║
    ╚═════════╤═══════╝  ╚════════╤═════════╝  ╚═══════╤═══════╝
              │                   │                    │
              │                   │                    │
              └───────────────────┼────────────────────┘
                                  │
                                  │ analyze_all_inputs
                                  │
                        ╔═════════▼═════════════╗
                        ║  RISK_ASSESSMENT      ║
                        ╠═══════════════════════╣
                        ║ Calculate risk score: ║
                        ║ risk = weighted_sum(  ║
                        ║   biometric_stress,   ║
                        ║   verbal_distress,    ║
                        ║   non_responsiveness, ║
                        ║   contraindication    ║
                        ║ )                     ║
                        ╚═════════╤═════════════╝
                                  │
                  ┌───────────────┼───────────────┐
                  │               │               │
          [risk < 0.3]      [0.3 ≤ risk < 0.7]   [risk ≥ 0.7]
                  │               │               │
        ╔═════════▼═══════╗  ╔════▼═════════╗  ╔═▼═════════════╗
        ║   NORMAL        ║  ║   CAUTION    ║  ║   ALERT       ║
        ╠═════════════════╣  ╠══════════════╣  ╠═══════════════╣
        ║ • Continue      ║  ║ • Heightened ║  ║ • Immediate   ║
        ║   monitoring    ║  ║   monitoring ║  ║   action      ║
        ║ • Log metrics   ║  ║ • Prepare    ║  ║ • Intervene   ║
        ║                 ║  ║   adaptation ║  ║ • May escalate║
        ╚═════════╤═══════╝  ╚══════╤═══════╝  ╚═══════╤═══════╝
                  │                  │                  │
                  │                  │                  │
                  └──────────────────┤                  │
                                     │                  │
                           [risk_decreases]    [risk_increases]
                                     │                  │
                                     │         ╔════════▼═══════════╗
                                     │         ║  INTERVENTION      ║
                                     │         ╠════════════════════╣
                                     │         ║ Level 1: Pacing    ║
                                     │         ║ • Slow down        ║
                                     │         ║ • Add pauses       ║
                                     │         ║                    ║
                                     │         ║ Level 2: Content   ║
                                     │         ║ • Calming exercise ║
                                     │         ║ • Breathing cue    ║
                                     │         ║                    ║
                                     │         ║ Level 3: Pause     ║
                                     │         ║ • Suspend session  ║
                                     │         ║ • Assess readiness ║
                                     │         ╚════════╤═══════════╝
                                     │                  │
                                     │          [intervention_applied]
                                     │                  │
                                     │         ╔════════▼═══════════╗
                                     │         ║  POST_INTERVENTION ║
                                     │         ╠════════════════════╣
                                     │         ║ • Monitor for 60s  ║
                                     │         ║ • Assess response  ║
                                     │         ╚════════╤═══════════╝
                                     │                  │
                                     │          ┌───────┴───────┐
                                     │          │               │
                                     │    [improved]      [not_improved]
                                     │          │               │
                                     │          │      ╔════════▼════════╗
                                     │          │      ║   ESCALATION    ║
                                     │          │      ╠═════════════════╣
                                     │          │      ║ • Emergency     ║
                                     │          │      ║   emergence     ║
                                     │          │      ║ • Alert human   ║
                                     │          │      ║ • Log incident  ║
                                     │          │      ║ • Flag account  ║
                                     │          │      ╚═════════╤═══════╝
                                     │          │                │
                                     │          │                │
                                     └──────────┴────────────────┘
                                                │
                                                │ continue_monitoring
                                                │
                                     ╔══════════▼═══════════╗
                                     ║ MONITORING_ACTIVE    ║
                                     ║ (Back to main loop)  ║
                                     ╚══════════╤═══════════╝
                                                │
                                                │ session_ends
                                                │
                                     ╔══════════▼═══════════╗
                                     ║  SAFETY_COMPLETE     ║
                                     ╠══════════════════════╣
                                     ║ • Generate report    ║
                                     ║ • Store all logs     ║
                                     ║ • Calculate stats    ║
                                     ║ • Deactivate         ║
                                     ╚══════════════════════╝

Concurrent Checks (Running in Parallel):
┌────────────────────────────────────────────────┐
│ CONTRAINDICATION_MONITOR (Always Active)      │
│ ┌────────────────────────────────────────────┐ │
│ │ • Check user health history                │ │
│ │ • Monitor for exclusion criteria           │ │
│ │ • Flag if conditions emerge mid-session    │ │
│ │ • Immediate halt if critical               │ │
│ └────────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘

Escalation Triggers:
- Sustained HR > 140 bpm for > 60 seconds
- GSR > 0.9 for > 60 seconds
- No response to prompts for > 30 seconds
- Verbal distress cues detected
- User requests to stop
- Biometric anomalies (sudden spike/drop)
- Content validation failures

 Part 5: Message Flow & Communication Protocols
5.1 WebSocket Event Specifications
WebSocket Connection Architecture
┌──────────────────────────────────────────────────────────────────┐
│                    WEBSOCKET ARCHITECTURE                         │
└──────────────────────────────────────────────────────────────────┘

Client                          Server
  │                               │
  │  WSS://api.hmi.ai/ws/session  │
  ├──────────────────────────────►│
  │      Connection Request        │
  │      + Auth Token              │
  │                               │
  │◄──────────────────────────────┤
  │   Connection Established       │
  │   session_id: abc-123          │
  │                               │
  │                               │
  │  ┌─────────────────────────┐  │
  │  │  Heartbeat (every 30s)  │  │
  │  └─────────────────────────┘  │
  │                               │
  ├──────────────────────────────►│
  │  {"type": "ping"}              │
  │                               │
  │◄──────────────────────────────┤
  │  {"type": "pong"}              │
  │                               │

  5.1.1 Session Lifecycle Events
json// ============================================================================
// EVENT: session.initialized
// Direction: Server → Client
// Trigger: Session orchestrator ready
// ============================================================================
{
  "event": "session.initialized",
  "timestamp": "2025-01-15T10:30:00Z",
  "session_id": "sess_abc123",
  "data": {
    "user_id": "user_456",
    "session_number": 1,
    "profile": {
      "suggestibility": {
        "type": "emotional",
        "physical_pct": 35,
        "emotional_pct": 65
      },
      "sexuality": {
        "type": "physical",
        "physical_pct": 70,
        "emotional_pct": 30
      }
    },
    "estimated_duration_minutes": 45,
    "phases": [
      "pre_induction",
      "theory_of_mind",
      "induction",
      "deepening",
      "suggestions",
      "post_hypnotic",
      "emergence"
    ]
  }
}

// ============================================================================
// EVENT: phase.started
// Direction: Server → Client
// Trigger: New phase begins
// ============================================================================
{
  "event": "phase.started",
  "timestamp": "2025-01-15T10:32:00Z",
  "session_id": "sess_abc123",
  "data": {
    "phase": "induction",
    "phase_number": 3,
    "total_phases": 7,
    "estimated_duration_seconds": 420,
    "instructions": {
      "user": "Sit comfortably, close your eyes when ready",
      "system": "Begin biometric monitoring at high frequency"
    }
  }
}

// ============================================================================
// EVENT: segment.ready
// Direction: Server → Client
// Trigger: New script segment generated
// ============================================================================
{
  "event": "segment.ready",
  "timestamp": "2025-01-15T10:32:05Z",
  "session_id": "sess_abc123",
  "data": {
    "segment_id": "seg_xyz789",
    "phase": "induction",
    "sequence_number": 1,
    "script_text": "As you begin to settle into your chair, you might notice...",
    "audio_url": "https://cdn.hmi.ai/audio/seg_xyz789.mp3",
    "duration_seconds": 180,
    "voice_settings": {
      "voice_id": "emotional_female_warm",
      "speed": 0.85,
      "pitch": -2,
      "volume": -3
    },
    "visual_cues": null
  }
}

// ============================================================================
// EVENT: segment.started
// Direction: Client → Server
// Trigger: Audio playback begins
// ============================================================================
{
  "event": "segment.started",
  "timestamp": "2025-01-15T10:32:10Z",
  "session_id": "sess_abc123",
  "data": {
    "segment_id": "seg_xyz789",
    "client_timestamp": "2025-01-15T10:32:10.123Z",
    "playback_position": 0
  }
}

// ============================================================================
// EVENT: segment.completed
// Direction: Client → Server
// Trigger: Audio playback finishes
// ============================================================================
{
  "event": "segment.completed",
  "timestamp": "2025-01-15T10:35:10Z",
  "session_id": "sess_abc123",
  "data": {
    "segment_id": "seg_xyz789",
    "actual_duration_seconds": 182,
    "completion_status": "completed", // completed, skipped, interrupted
    "user_interaction": {
      "paused": false,
      "replay_count": 0
    }
  }
}

// ============================================================================
// EVENT: session.paused
// Direction: Bidirectional
// Trigger: User or system initiates pause
// ============================================================================
{
  "event": "session.paused",
  "timestamp": "2025-01-15T10:40:00Z",
  "session_id": "sess_abc123",
  "data": {
    "initiated_by": "user", // user, system, safety_guardian
    "reason": "user_request", // user_request, safety_concern, technical_issue
    "current_phase": "deepening",
    "current_segment_id": "seg_abc456",
    "playback_position_seconds": 45,
    "can_resume": true,
    "auto_resume_after_seconds": null
  }
}

// ============================================================================
// EVENT: session.resumed
// Direction: Client → Server
// Trigger: User resumes session
// ============================================================================
{
  "event": "session.resumed",
  "timestamp": "2025-01-15T10:42:00Z",
  "session_id": "sess_abc123",
  "data": {
    "resume_from_segment_id": "seg_abc456",
    "resume_from_position_seconds": 45
  }
}

// ============================================================================
// EVENT: session.completed
// Direction: Server → Client
// Trigger: Emergence complete
// ============================================================================
{
  "event": "session.completed",
  "timestamp": "2025-01-15T11:15:00Z",
  "session_id": "sess_abc123",
  "data": {
    "completion_status": "success", // success, partial, aborted
    "total_duration_seconds": 2700,
    "phases_completed": [
      "pre_induction",
      "theory_of_mind",
      "induction",
      "deepening",
      "suggestions",
      "post_hypnotic",
      "emergence"
    ],
    "next_steps": {
      "homework": "Complete E&P assessment",
      "next_session_recommended_date": "2025-01-22",
      "notes": "Excellent response to induction, consider deeper work next time"
    },
    "summary_url": "https://api.hmi.ai/sessions/sess_abc123/summary"
  }
}

5.1.2 Biometric Data Events
json// ============================================================================
// EVENT: biometric.reading
// Direction: Client → Server
// Trigger: Every 1 second during active session
// ============================================================================
{
  "event": "biometric.reading",
  "timestamp": "2025-01-15T10:33:45.123Z",
  "session_id": "sess_abc123",
  "data": {
    "reading_id": "bio_reading_12345",
    "heart_rate": 72,
    "heart_rate_variability": 55,
    "galvanic_skin_response": 0.42,
    "respiration_rate": 14,
    "blood_oxygen": 98,
    "device_type": "apple_watch_series_9",
    "data_quality": "high", // high, medium, low
    "eye_tracking": {
      "available": true,
      "gaze_direction": {"x": 0.1, "y": -0.2},
      "blink_rate": 12,
      "pupil_dilation": 3.2
    }
  }
}

// ============================================================================
// EVENT: biometric.alert
// Direction: Server → Client
// Trigger: Safety Guardian detects anomaly
// ============================================================================
{
  "event": "biometric.alert",
  "timestamp": "2025-01-15T10:34:00Z",
  "session_id": "sess_abc123",
  "data": {
    "alert_id": "alert_789",
    "severity": "medium", // low, medium, high, critical
    "trigger": "elevated_heart_rate",
    "details": {
      "metric": "heart_rate",
      "current_value": 115,
      "threshold": 110,
      "duration_seconds": 45,
      "trend": "increasing"
    },
    "recommended_action": "apply_calming_intervention",
    "automated_response": {
      "applied": true,
      "intervention_type": "pacing_adjustment",
      "description": "Slowing delivery pace by 15%"
    }
  }
}

// ============================================================================
// EVENT: biometric.analysis
// Direction: Server → Client
// Trigger: Every 30 seconds (aggregate analysis)
// ============================================================================
{
  "event": "biometric.analysis",
  "timestamp": "2025-01-15T10:35:00Z",
  "session_id": "sess_abc123",
  "data": {
    "time_window_seconds": 30,
    "stress_score": 0.35, // 0-1 scale
    "relaxation_score": 0.68,
    "engagement_score": 0.82,
    "hypnotic_depth_estimate": 0.55, // 0-1, based on physiological markers
    "trends": {
      "heart_rate": "decreasing",
      "hrv": "increasing",
      "gsr": "stable",
      "respiration": "slowing"
    },
    "interpretation": "User entering deeper relaxation state, good responsiveness",
    "confidence": 0.87
  }
}

5.1.3 Real-Time Adaptation Events
json// ============================================================================
// EVENT: adaptation.suggested
// Direction: Server → Client
// Trigger: RL Agent or Safety Guardian recommends change
// ============================================================================
{
  "event": "adaptation.suggested",
  "timestamp": "2025-01-15T10:36:00Z",
  "session_id": "sess_abc123",
  "data": {
    "adaptation_id": "adapt_xyz",
    "reason": "elevated_stress_detected",
    "suggestion": {
      "type": "pacing_adjustment",
      "parameters": {
        "speed_multiplier": 0.85, // slow down 15%
        "pause_duration_increase_ms": 500,
        "volume_decrease_db": -2
      },
      "apply_to": "current_segment",
      "estimated_impact": "Should reduce stress by 20-30%"
    },
    "requires_confirmation": false,
    "auto_applied": true
  }
}

// ============================================================================
// EVENT: adaptation.applied
// Direction: Server → Client
// Trigger: Adaptation takes effect
// ============================================================================
{
  "event": "adaptation.applied",
  "timestamp": "2025-01-15T10:36:05Z",
  "session_id": "sess_abc123",
  "data": {
    "adaptation_id": "adapt_xyz",
    "applied_at_segment_id": "seg_abc456",
    "applied_at_position_seconds": 67,
    "parameters_applied": {
      "speed_multiplier": 0.85,
      "pause_duration_increase_ms": 500,
      "volume_decrease_db": -2
    },
    "previous_parameters": {
      "speed_multiplier": 1.0,
      "pause_duration_increase_ms": 0,
      "volume_decrease_db": 0
    }
  }
}

// ============================================================================
// EVENT: content.regenerated
// Direction: Server → Client
// Trigger: Agent regenerates segment mid-session
// ============================================================================
{
  "event": "content.regenerated",
  "timestamp": "2025-01-15T10:37:00Z",
  "session_id": "sess_abc123",
  "data": {
    "original_segment_id": "seg_def789",
    "new_segment_id": "seg_ghi012",
    "reason": "user_state_change",
    "changes": {
      "script_text_modified": true,
      "tone_adjusted": true,
      "duration_changed": true
    },
    "original_script_preview": "You are now feeling deeply relaxed...",
    "new_script_preview": "Take a moment to notice your breathing, allowing yourself...",
    "explanation": "Shifted to more permissive language due to resistance indicators"
  }
}

5.1.4 Safety & Escalation Events
json// ============================================================================
// EVENT: safety.concern
// Direction: Server → Client
// Trigger: Safety Guardian detects issue
// ============================================================================
{
  "event": "safety.concern",
  "timestamp": "2025-01-15T10:38:00Z",
  "session_id": "sess_abc123",
  "data": {
    "concern_id": "safety_001",
    "severity": "high", // low, medium, high, critical
    "category": "physiological_distress",
    "triggers": [
      {
        "type": "sustained_high_heart_rate",
        "value": 145,
        "duration_seconds": 75
      },
      {
        "type": "elevated_gsr",
        "value": 0.92,
        "duration_seconds": 60
      }
    ],
    "automated_intervention": {
      "applied": true,
      "type": "calming_exercise",
      "description": "Inserted breathing exercise"
    },
    "requires_human_review": true,
    "recommendation": "Monitor closely, prepare emergency emergence if no improvement in 60s"
  }
}

// ============================================================================
// EVENT: safety.escalation
// Direction: Server → Client & Therapist
// Trigger: Critical safety issue requires human intervention
// ============================================================================
{
  "event": "safety.escalation",
  "timestamp": "2025-01-15T10:39:00Z",
  "session_id": "sess_abc123",
  "data": {
    "escalation_id": "esc_critical_001",
    "severity": "critical",
    "reason": "unable_to_stabilize_user",
    "timeline": [
      {
        "time": "2025-01-15T10:37:00Z",
        "event": "High stress detected",
        "action": "Applied calming intervention"
      },
      {
        "time": "2025-01-15T10:38:00Z",
        "event": "Stress persisting",
        "action": "Inserted breathing exercise"
      },
      {
        "time": "2025-01-15T10:39:00Z",
        "event": "No improvement after 120s",
        "action": "Escalating to human therapist"
      }
    ],
    "current_state": {
      "phase": "deepening",
      "segment_id": "seg_jkl345",
      "biometrics": {
        "heart_rate": 148,
        "gsr": 0.94,
        "respiration_rate": 22
      }
    },
    "immediate_action": "emergency_emergence_initiated",
    "therapist_notified": true,
    "therapist_ids": ["therapist_789"],
    "priority": "urgent"
  }
}

// ============================================================================
// EVENT: safety.resolved
// Direction: Server → Client & Therapist
// Trigger: Safety issue resolved
// ============================================================================
{
  "event": "safety.resolved",
  "timestamp": "2025-01-15T10:42:00Z",
  "session_id": "sess_abc123",
  "data": {
    "concern_id": "safety_001",
    "escalation_id": "esc_critical_001",
    "resolution": "user_stabilized",
    "final_action_taken": "completed_emergency_emergence",
    "outcome": {
      "user_status": "stable",
      "biometrics_normalized": true,
      "session_continuation": "terminated",
      "follow_up_scheduled": true
    },
    "therapist_notes": "User responded well to emergency emergence. Recommend evaluation before next session.",
    "next_steps": [
      "Schedule follow-up call with therapist",
      "Review session recording",
      "Adjust profile for future sessions"
    ]
  }
}

5.1.5 User Interaction Events
json// ============================================================================
// EVENT: user.response
// Direction: Client → Server
// Trigger: User provides feedback or interaction
// ============================================================================
{
  "event": "user.response",
  "timestamp": "2025-01-15T10:40:00Z",
  "session_id": "sess_abc123",
  "data": {
    "response_id": "resp_001",
    "response_type": "ideomotor_signal", // ideomotor_signal, verbal, button_press
    "prompt": "If you're feeling comfortable, allow your yes finger to lift",
    "response_value": "yes",
    "response_time_ms": 3200,
    "confidence": 0.85,
    "detection_method": "hand_tracking" // hand_tracking, audio_analysis, manual_input
  }
}

// ============================================================================
// EVENT: user.distress_signal
// Direction: Client → Server
// Trigger: User indicates discomfort
// ============================================================================
{
  "event": "user.distress_signal",
  "timestamp": "2025-01-15T10:41:00Z",
  "session_id": "sess_abc123",
  "data": {
    "signal_type": "verbal", // verbal, gesture, button_press
    "detected_phrase": "I need to stop",
    "confidence": 0.95,
    "context": {
      "current_phase": "suggestions",
      "current_segment_id": "seg_mno678",
      "playback_position_seconds": 120
    },
    "immediate_action": "pause_session",
    "alert_safety_guardian": true
  }
}

// ============================================================================
// EVENT: user.feedback
// Direction: Client → Server
// Trigger: End-of-session or mid-session feedback
// ============================================================================
{
  "event": "user.feedback",
  "timestamp": "2025-01-15T11:20:00Z",
  "session_id": "sess_abc123",
  "data": {
    "feedback_type": "end_of_session",
    "rating": 9, // 1-10
    "experience_quality": "excellent",
    "specific_feedback": {
      "induction_effectiveness": 9,
      "comfort_level": 8,
      "pacing_appropriateness": 9,
      "voice_quality": 10,
      "depth_achieved": 8
    },
    "comments": "Really felt the suggestions sink in. Voice was perfect.",
    "would_recommend": true,
    "areas_for_improvement": []
  }
}


5.2 REST API Endpoints
5.2.1 Authentication & User Management
yaml# ============================================================================
# AUTHENTICATION
# ============================================================================

POST /api/v1/auth/register
Description: Create new user account
Request:
  {
    "email": "user@example.com",
    "password": "SecureP@ssw0rd",
    "first_name": "John",
    "last_name": "Doe",
    "date_of_birth": "1985-06-15",
    "timezone": "America/Los_Angeles",
    "terms_accepted": true,
    "privacy_policy_accepted": true
  }
Response: 201 Created
  {
    "user_id": "user_abc123",
    "email": "user@example.com",
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_in": 3600
  }

---

POST /api/v1/auth/login
Description: Authenticate user
Request:
  {
    "email": "user@example.com",
    "password": "SecureP@ssw0rd"
  }
Response: 200 OK
  {
    "user_id": "user_abc123",
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_in": 3600,
    "profile_complete": false
  }

---

POST /api/v1/auth/refresh
Description: Refresh access token
Headers:
  Authorization: Bearer {refresh_token}
Response: 200 OK
  {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_in": 3600
  }

---

POST /api/v1/auth/logout
Description: Invalidate tokens
Headers:
  Authorization: Bearer {access_token}
Response: 204 No Content

# ============================================================================
# USER PROFILE
# ============================================================================

GET /api/v1/users/{user_id}/profile
Description: Get user profile
Headers:
  Authorization: Bearer {access_token}
Response: 200 OK
  {
    "user_id": "user_abc123",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "profile_complete": true,
    "assessments_complete": {
      "suggestibility": true,
      "sexuality": false,
      "wheel_of_happiness": true
    },
    "created_at": "2025-01-10T08:00:00Z",
    "last_login": "2025-01-15T10:00:00Z"
  }

---

PATCH /api/v1/users/{user_id}/profile
Description: Update user profile
Headers:
  Authorization: Bearer {access_token}
Request:
  {
    "timezone": "America/New_York",
    "preferences": {
      "voice_preference": "female_warm",
      "session_time_preference": "evening"
    }
  }
Response: 200 OK
  {
    "user_id": "user_abc123",
    "updated_fields": ["timezone", "preferences"],
    "updated_at": "2025-01-15T10:30:00Z"
  }

# ============================================================================
# ASSESSMENTS
# ============================================================================

POST /api/v1/assessments/suggestibility/start
Description: Initialize suggestibility assessment
Headers:
  Authorization: Bearer {access_token}
Request:
  {
    "user_id": "user_abc123",
    "assessment_type": "questionnaire" // questionnaire, finger_test, combined
  }
Response: 201 Created
  {
    "assessment_id": "assess_sugg_456",
    "assessment_type": "questionnaire",
    "total_questions": 36,
    "estimated_duration_minutes": 10,
    "questions": [
      {
        "id": "q1",
        "number": 1,
        "questionnaire": 1,
        "text": "Do you play a musical instrument?",
        "helper": {
          "why_asking": "Musical training often correlates with physical suggestibility patterns",
          "examples": [
            {
              "range": "yes",
              "example": "I play piano regularly",
              "guidance": "This indicates developed motor coordination"
            },
            {
              "range": "no",
              "example": "I never learned an instrument",
              "guidance": "This is perfectly normal and doesn't affect your results"
            }
          ]
        }
      }
      // ... remaining questions
    ]
  }

---

POST /api/v1/assessments/suggestibility/{assessment_id}/response
Description: Submit answer to question
Headers:
  Authorization: Bearer {access_token}
Request:
  {
    "question_id": "q1",
    "response": true, // yes
    "response_time_ms": 2340
  }
Response: 200 OK
  {
    "question_id": "q1",
    "recorded": true,
    "next_question_id": "q2",
    "progress": {
      "completed": 1,
      "total": 36,
      "percentage": 2.78
    }
  }

---

POST /api/v1/assessments/suggestibility/{assessment_id}/complete
Description: Finalize assessment and get results
Headers:
  Authorization: Bearer {access_token}
Response: 200 OK
  {
    "assessment_id": "assess_sugg_456",
    "results": {
      "questionnaire_1_score": 65,
      "questionnaire_2_score": 85,
      "combined_score": 150,
      "suggestibility_type": "emotional",
      "physical_percentage": 35.0,
      "emotional_percentage": 65.0,
      "confidence_score": 0.85
    },
    "interpretation": {
      "primary_type": "Emotional/Inferred Suggestibility",
      "description": "You respond best to indirect, permissive suggestions that allow your subconscious to process information naturally.",
      "session_implications": {
        "induction_style": "Inferential arm raising with allowing language",
        "language_patterns": ["misdirection", "implication", "metaphor"],
        "optimal_pacing": "slower, with pauses for processing"
      }
    },
    "next_steps": {
      "recommendation": "Complete Wheel of Happiness assessment",
      "optional": "E&P Sexuality assessment if you have relationship goals"
    }
  }

---

POST /api/v1/assessments/wheel-of-happiness
Description: Submit Wheel of Happiness ratings
Headers:
  Authorization: Bearer {access_token}
Request:
  {
    "user_id": "user_abc123",
    "ratings": {
      "health": 7,
      "family_friends": 8,
      "career": 4,
      "significant_other": 6,
      "fun_recreation": 5,
      "money": 4,
      "physical_environment": 7,
      "personal_growth": 6
    }
  }
Response: 201 Created
  {
    "wheel_id": "wheel_789",
    "average_score": 5.875,
    "bumpiness_score": 1.46,
    "interpretation": "Your wheel shows some imbalance, particularly in Career and Money areas",
    "priority_areas": [
      {
        "area": "career",
        "score": 4,
        "priority": 1,
        "recommendation": "Focus therapeutic work here first"
      },
      {
        "area": "money",
        "score": 4,
        "priority": 2,
        "recommendation": "Often tied to career satisfaction"
      },
      {
        "area": "fun_recreation",
        "score": 5,
        "priority": 3,
        "recommendation": "May improve as other areas strengthen"
      }
    ],
    "suggested_goals": [
      "Improve career confidence and networking",
      "Develop healthier money mindset",
      "Increase work-life balance"
    ]
  }

---

POST /api/v1/assessments/sexuality/start
Description: Begin E&P Sexuality assessment
Headers:
  Authorization: Bearer {access_token}
Response: 201 Created
  {
    "assessment_id": "assess_sex_012",
    "traits_to_evaluate": [
      "family_origin",
      "rejection_response",
      "body_connection",
      "relationship_patterns"
    ],
    "estimated_duration_minutes": 35,
    "current_trait": "family_origin",
    "instructions": "We'll explore four core traits. You need 3 of 4 for accurate classification."
  }

---

POST /api/v1/assessments/sexuality/{assessment_id}/family-tree
Description: Submit family tree data
Headers:
  Authorization: Bearer {access_token}
Request:
  {
    "family_members": [
      {
        "name": "Mother",
        "relationship": "mother",
        "role": "primary_caretaker",
        "sexuality_type": "emotional",
        "traits": ["cautious", "protective", "emotionally_expressive"]
      },
      {
        "name": "Father",
        "relationship": "father",
        "role": "secondary_caretaker",
        "sexuality_type": "physical",
        "traits": ["hands-on", "sports-focused", "action-oriented"]
      }
      // ... more family members
    ]
  }
Response: 200 OK
  {
    "trait_evaluation": {
      "trait_name": "family_origin",
      "sexuality_indication": "physical",
      "confidence": 0.78,
      "reasoning": "Secondary caretaker (father) exhibits strong Physical sexuality traits",
      "next_trait": "rejection_response"
    }
  }

---

POST /api/v1/assessments/sexuality/{assessment_id}/relationship-inventory
Description: Submit relationship history
Headers:
  Authorization: Bearer {access_token}
Request:
  {
    "relationships": [
      {
        "order": 1,
        "partner_name": "First Serious Relationship",
        "duration_months": 18,
        "who_pursued": "partner",
        "intensity_rating": 9,
        "vulnerability_level": 7,
        "user_rejection_response": "forward",
        "partner_rejection_response": "withdraw",
        "who_withdrew_first": "partner",
        "partner_sexuality_type": "emotional",
        "is_rebound": false
      },
      {
        "order": 2,
        "partner_name": "Second Relationship",
        "duration_months": 6,
        "who_pursued": "user",
        "intensity_rating": 6,
        "vulnerability_level": 4,
        "user_rejection_response": "forward",
        "who_withdrew_first": "user",
        "partner_sexuality_type": "physical",
        "is_rebound": true
      }
      // ... more relationships (minimum 3)
    ]
  }
Response: 200 OK
  {
    "traits_evaluated": [
      {
        "trait_name": "rejection_response",
        "sexuality_indication": "physical",
        "confidence": 0.82,
        "reasoning": "Consistent forward movement when facing rejection"
      },
      {
        "trait_name": "relationship_patterns",
        "sexuality_indication": "physical",
        "confidence": 0.75,
        "reasoning": "Pattern of pursuing Emotional partners, rebound relationship with Physical"
      }
    ],
    "traits_complete": 3,
    "can_classify": true,
    "next_step": "body_connection" // optional 4th trait
  }

---

POST /api/v1/assessments/sexuality/{assessment_id}/complete
Description: Finalize E&P assessment
Headers:
  Authorization: Bearer {access_token}
Response: 200 OK
  {
    "assessment_id": "assess_sex_012",
    "results": {
      "sexuality_type": "physical",
      "physical_percentage": 70.0,
      "emotional_percentage": 30.0,
      "confidence_score": 0.80,
      "traits_evaluated": 4,
      "core_traits": [
        {
          "trait": "family_origin",
          "indication": "physical",
          "confidence": 0.78
        },
        {
          "trait": "rejection_response",
          "indication": "physical",
          "confidence": 0.82
        },
        {
          "trait": "body_connection",
          "indication": "physical",
          "confidence": 0.71
        },
        {
          "trait": "relationship_patterns",
          "indication": "physical",
          "confidence": 0.75
        }
      ],
      "defense_mechanisms": ["intellectualization"],
      "incongruencies": [],
      "adjustment_applied": "+10% Physical due to high Emotional Suggestibility"
    },
    "interpretation": {
      "primary_type": "Physical Sexuality",
      "description": "You value connection, relationships, and acceptance. In intimate relationships, you tend to move forward when faced with rejection.",
      "therapeutic_implications": {
        "suggestion_themes": [
          "Connection and belonging",
          "Acceptance and approval",
          "Relationship harmony"
        ],
        "language_patterns": [
          "Feeling connected",
          "Being accepted",
          "Belonging to community"
        ]
      }
    }
  }

---

GET /api/v1/users/{user_id}/unified-profile
Description: Get complete personalization profile
Headers:
  Authorization: Bearer {access_token}
Response: 200 OK
  {
    "user_id": "user_abc123",
    "profile_id": "profile_def456",
    "version": 2,
    "created_at": "2025-01-10T10:00:00Z",
    "updated_at": "2025-01-15T14:00:00Z",
    "suggestibility": {
      "type": "emotional",
      "physical_pct": 35.0,
      "emotional_pct": 65.0,
      "confidence": 0.85
    },
    "sexuality": {
      "type": "physical",
      "physical_pct": 70.0,
      "emotional_pct": 30.0,
      "confidence": 0.80,
      "adjustment_applied": "+10% Physical"
    },
    "wheel_of_happiness": {
      "average_score": 5.875,
      "priority_areas": ["career", "money", "fun_recreation"]
    },
    "goals": {
      "primary": "Improve career confidence",
      "secondary": ["Better work-life balance", "Financial security"]
    },
    "session_configuration": {
      "induction_style": "emotional_inferential",
      "language_patterns": {
        "suggestibility": ["allowing", "tendency", "as you might notice"],
        "sexuality": ["connection", "belonging", "acceptance"]
      },
      "deepening_techniques": ["progressive_relaxation", "staircase", "safe_place"],
      "suggestion_framework": {
        "goal_focus": "career",
        "identity_statements": [
          "You are the type of person who connects authentically with others",
          "You naturally build professional relationships"
        ],
        "habit_loops": [
          {
            "habit": "Weekly networking",
            "reminder": "Monday morning coffee",
            "routine": "Send one LinkedIn message",
            "reward": "Feel connected and accomplished"
          }
        ]
      },
      "voice_characteristics": {
        "voice_type": "female_warm",
        "base_speed": 0.85,
        "base_pitch": -2,
        "emotional_tone": "supportive_gentle"
      }
    }
  }

# ============================================================================
# SESSIONS
# ============================================================================

POST /api/v1/sessions/create
Description: Create new hypnotherapy session
Headers:
  Authorization: Bearer {access_token}
Request:
  {
    "user_id": "user_abc123",
    "session_type": "therapeutic", // therapeutic, practice, assessment
    "scheduled_for": "2025-01-15T15:00:00Z"
  }
Response: 201 Created
  {
    "session_id": "sess_ghi789",
    "session_number": 1,
    "state": "planned",
    "estimated_duration_minutes": 45,
    "phases": [
      "pre_induction",
      "theory_of_mind",
      "induction",
      "deepening",
      "suggestions",
      "post_hypnotic",
      "emergence"
    ],
    "websocket_url": "wss://api.hmi.ai/ws/session/sess_ghi789",
    "preparation_checklist": [
      "Find quiet, comfortable space",
      "Disable notifications",
      "Ensure 60 minutes uninterrupted time",
      "Connect biometric device (optional)",
      "Have water nearby"
    ]
  }

---

POST /api/v1/sessions/{session_id}/start
Description: Begin session (activates orchestration)
Headers:
  Authorization: Bearer {access_token}
Response: 200 OK
  {
    "session_id": "sess_ghi789",
    "state": "in_progress",
    "started_at": "2025-01-15T15:00:00Z",
    "websocket_active": true,
    "biometric_monitoring_active": true,
    "first_segment_ready": true
  }

---

POST /api/v1/sessions/{session_id}/pause
Description: Pause active session
Headers:
  Authorization: Bearer {access_token}
Request:
  {
    "reason": "user_request",
    "current_position": {
      "segment_id": "seg_jkl012",
      "playback_seconds": 45
    }
  }
Response: 200 OK
  {
    "session_id": "sess_ghi789",
    "state": "paused",
    "paused_at": "2025-01-15T15:20:00Z",
    "resume_available": true,
    "resume_from": {
      "segment_id": "seg_jkl012",
      "playback_seconds": 45
    }
  }

---

POST /api/v1/sessions/{session_id}/resume
Description: Resume paused session
Headers:
  Authorization: Bearer {access_token}
Response: 200 OK
  {
    "session_id": "sess_ghi789",
    "state": "in_progress",
    "resumed_at": "2025-01-15T15:25:00Z",
    "resuming_from": {
      "segment_id": "seg_jkl012",
      "playback_seconds": 45
    }
  }

---

POST /api/v1/sessions/{session_id}/complete
Description: Mark session as complete
Headers:
  Authorization: Bearer {access_token}
Request:
  {
    "completion_status": "success", // success, partial, aborted
    "user_feedback": {
      "rating": 9,
      "comments": "Very effective, felt deeply relaxed"
    }
  }
Response: 200 OK
  {
    "session_id": "sess_ghi789",
    "state": "completed",
    "completed_at": "2025-01-15T15:45:00Z",
    "total_duration_seconds": 2700,
    "summary": {
      "phases_completed": 7,
      "segments_delivered": 12,
      "adaptations_applied": 3,
      "average_stress_score": 0.32,
      "hypnotic_depth_achieved": 0.68
    },
    "next_session": {
      "recommended_date": "2025-01-22T15:00:00Z",
      "focus_areas": ["Deepen career confidence work", "Introduce habit formation"],
      "homework": "Practice daily affirmations, complete networking task"
    }
  }

---

GET /api/v1/sessions/{session_id}
Description: Get session details
Headers:
  Authorization: Bearer {access_token}
Response: 200 OK
  {
    "session_id": "sess_ghi789",
    "user_id": "user_abc123",
    "session_number": 1,
    "state": "completed",
    "scheduled_at": "2025-01-15T15:00:00Z",
    "started_at": "2025-01-15T15:00:00Z",
    "completed_at": "2025-01-15T15:45:00Z",
    "total_duration_seconds": 2700,
    "phases_completed": ["pre_induction", "theory_of_mind", "induction", "deepening", "suggestions", "post_hypnotic", "emergence"],
    "segments": [
      {
        "segment_id": "seg_001",
        "phase": "pre_induction",
        "duration_seconds": 180,
        "script_preview": "Welcome to your first session..."
      }
      // ... more segments
    ],
    "biometric_summary": {
      "average_heart_rate": 68,
      "average_hrv": 62,
      "stress_score": 0.32,
      "relaxation_score": 0.78
    },
    "adaptations_applied": 3,
    "safety_events": [],
    "user_feedback": {
      "rating": 9,
      "comments": "Very effective, felt deeply relaxed"
    }
  }

---

GET /api/v1/users/{user_id}/sessions
Description: List user's sessions
Headers:
  Authorization: Bearer {access_token}
Query Parameters:
  ?limit=20&offset=0&state=completed
Response: 200 OK
  {
    "total": 5,
    "sessions": [
      {
        "session_id": "sess_ghi789",
        "session_number": 1,
        "state": "completed",
        "started_at": "2025-01-15T15:00:00Z",
        "completed_at": "2025-01-15T15:45:00Z",
        "rating": 9,
        "primary_goal": "Career confidence"
      },
      {
        "session_id": "sess_mno234",
        "session_number": 2,
        "state": "scheduled",
        "scheduled_for": "2025-01-22T15:00:00Z",
        "primary_goal": "Career confidence"
      }
      // ... more sessions
    ]
  }

---

GET /api/v1/sessions/{session_id}/transcript
Description: Get session transcript with timestamps
Headers:
  Authorization: Bearer {access_token}
Response: 200 OK
  {
    "session_id": "sess_ghi789",
    "transcript": [
      {
        "timestamp": "00:00:00",
        "phase": "pre_induction",
        "speaker": "therapist",
        "text": "Welcome to your first hypnotherapy session..."
      },
      {
        "timestamp": "00:03:15",
        "phase": "induction",
        "speaker": "therapist",
        "text": "As you begin to settle into your chair..."
      },
      {
        "timestamp": "00:15:30",
        "phase": "deepening",
        "speaker": "therapist",
        "text": "And with each breath, you can go deeper..."
      }
      // ... full transcript
    ],
    "download_url": "https://api.hmi.ai/sessions/sess_ghi789/transcript.pdf"
  }

---

GET /api/v1/sessions/{session_id}/analytics
Description: Get detailed session analytics
Headers:
  Authorization: Bearer {access_token}
Response: 200 OK
  {
    "session_id": "sess_ghi789",
    "analytics": {
      "biometric_timeline": [
        {
          "timestamp": "00:00:00",
          "heart_rate": 75,
          "hrv": 50,
          "gsr": 0.45,
          "stress_score": 0.42
        },
        {
          "timestamp": "00:01:00",
          "heart_rate": 73,
          "hrv": 52,
          "gsr": 0.42,
          "stress_score": 0.38
        }
        // ... timeline data
      ],
      "phase_effectiveness": [
        {
          "phase": "induction",
          "effectiveness_score": 0.85,
          "average_stress_reduction": 0.25,
          "user_responsiveness": 0.78
        }
        // ... per-phase analysis
      ],
      "adaptations": [
        {
          "timestamp": "00:10:30",
          "reason": "elevated_stress",
          "adaptation_applied": "pacing_slowdown",
          "effectiveness": 0.72
        }
        // ... adaptations
      ],
      "hypnotic_depth_curve": [
        {"time": "00:00:00", "depth": 0.0},
        {"time": "00:05:00", "depth": 0.3},
        {"time": "00:10:00", "depth": 0.55},
        {"time": "00:15:00", "depth": 0.68}
        // ... depth progression
      ]
    }
  }

5.3 Agent-to-Agent Message Protocols
5.3.1 AutoGen Strategic Layer Messages
python# ============================================================================
# SESSION PLANNER ↔ SAFETY OVERSEER
# ============================================================================

# Message 1: SessionPlanner requests safety approval
{
    "from": "SessionPlanner",
    "to": "SafetyOverseer",
    "message_type": "safety_review_request",
    "timestamp": "2025-01-15T10:30:00Z",
    "content": {
        "session_plan": {
            "user_id": "user_abc123",
            "session_number": 1,
            "profile_summary": {
                "suggestibility": "emotional",
                "sexuality": "physical",
                "primary_goal": "career_confidence"
            },
            "proposed_protocol": {
                "induction": "emotional_arm_raising",
                "deepening": ["progressive_relaxation", "staircase"],
                "suggestions": ["career_confidence", "networking_comfort", "professional_identity"],
                "estimated_duration_minutes": 45
            }
        },
        "risk_assessment_needed": true
    }
}

# Message 2: SafetyOverseer response
{
    "from": "SafetyOverseer",
    "to": "SessionPlanner",
    "message_type": "safety_review_response",
    "timestamp": "2025-01-15T10:30:05Z",
    "content": {
        "approval_status": "approved",
        "risk_score": 0.15, # low risk
        "checks_performed": [
            "contraindication_scan",
            "protocol_validation",
            "user_history_review"
        ],
        "findings": {
            "contraindications": [],
            "warnings": [],
            "recommendations": [
                "Monitor closely during first induction",
                "User has no prior hypnosis experience - add extra pre-talk"
            ]
        },
        "monitoring_requirements": {
            "biometric_frequency": "1_second",
            "intervention_thresholds": {
                "stress_score": 0.85,
                "heart_rate": 120,
                "sustained_duration_seconds": 60
            }
        }
    }
}

# Message 3: SessionPlanner to SafetyOverseer (mid-session update)
{
    "from": "SessionPlanner",
    "to": "SafetyOverseer",
    "message_type": "strategy_adjustment",
    "timestamp": "2025-01-15T10:45:00Z",
    "content": {
        "reason": "user_responding_very_well",
        "current_phase": "deepening",
        "proposed_change": {
            "original_plan": "Standard progressive relaxation",
            "new_plan": "Add challenge suggestions to deepen further",
            "rationale": "User showing exceptional responsiveness (depth 0.75), can safely introduce challenges"
        },
        "requires_approval": true
    }
}

# Message 4: SafetyOverseer approval
{
    "from": "SafetyOverseer",
    "to": "SessionPlanner",
    "message_type": "strategy_adjustment_response",
    "timestamp": "2025-01-15T10:45:02Z",
    "content": {
        "approval_status": "approved",
        "conditions": [
            "Continue biometric monitoring",
            "Be prepared to lighten if any resistance"
        ]
    }
}

# ============================================================================
# SESSION PLANNER → TACTICAL CREW (CrewAI)
# ============================================================================

# Message: SessionPlanner delegates to tactical crew
{
    "from": "SessionPlanner",
    "to": "TacticalCrew",
    "message_type": "generation_task",
    "timestamp": "2025-01-15T10:30:10Z",
    "content": {
        "task_id": "task_gen_001",
        "task_type": "full_session_generation",
        "session_plan": {
            "user_profile": {
                "suggestibility": {
                    "type": "emotional",
                    "physical_pct": 35,
                    "emotional_pct": 65
                },
                "sexuality": {
                    "type": "physical",
                    "physical_pct": 70,
                    "emotional_pct": 30
                },
                "goals": ["career_confidence", "networking_comfort"]
            },
            "protocol": {
                "induction_style": "emotional_inferential",
                "deepening_sequence": ["progressive_relaxation", "staircase"],
                "suggestion_themes": ["connection", "confidence", "belonging"]
            }
        },
        "constraints": {
            "max_duration_seconds": 2700,
            "language_patterns": {
                "suggestibility": ["allowing", "tendency", "might notice"],
                "sexuality": ["connection", "belonging", "acceptance"]
            },
            "safety_requirements": [
                "include_emergence_procedure",
                "no_harmful_suggestions",
                "maintain_autonomy"
            ]
        },
        "deadline": "2025-01-15T10:32:00Z"
    }
}

5.3.2 CrewAI Tactical Layer Messages
python# ============================================================================
# CREW MANAGER → INDIVIDUAL AGENTS
# ============================================================================

# Message 1: CrewManager assigns task to InductionComposer
{
    "from": "CrewManager",
    "to": "InductionComposer",
    "message_type": "task_assignment",
    "timestamp": "2025-01-15T10:30:15Z",
    "content": {
        "task_id": "induction_001",
        "priority": "high",
        "context": {
            "user_profile": {
                "suggestibility": "emotional",
                "first_session": true
            },
            "session_plan": {
                "induction_type": "emotional_arm_raising",
                "duration_target_seconds": 420
            }
        },
        "available_tools": [
            "mcp_retrieve_induction",
            "rag_vector_search",
            "llm_synthesis"
        ],
        "success_criteria": [
            "Uses inferential language patterns",
            "Duration 6-8 minutes",
            "Includes arm raising test",
            "Sets up post-hypnotic suggestion",
            "Passes safety validation"
        ]
    }
}

# Message 2: InductionComposer tool call (internal)
{
    "from": "InductionComposer",
    "to": "MCPServer",
    "message_type": "tool_call",
    "timestamp": "2025-01-15T10:30:20Z",
    "content": {
        "tool_name": "retrieve_induction",
        "parameters": {
            "suggestibility_type": "emotional",
            "session_number": 1,
            "include_arm_raising": true
        }
    }
}

# Message 3: MCP Server response
{
    "from": "MCPServer",
    "to": "InductionComposer",
    "message_type": "tool_response",
    "timestamp": "2025-01-15T10:30:21Z",
    "content": {
        "tool_name": "retrieve_induction",
        "result": {
            "script_name": "Emotional Arm Raising Induction - Session 1",
            "script_text": "[Base HMI script text...]",
            "metadata": {
                "suggestibility": "emotional",
                "session_number": 1,
                "duration_seconds": 400,
                "language_patterns": ["inferential", "allowing", "misdirection"]
            }
        }
    }
}

# Message 4: InductionComposer to LLM (synthesis)
{
    "from": "InductionComposer",
    "to": "CustomHypnosisLLM",
    "message_type": "synthesis_request",
    "timestamp": "2025-01-15T10:30:25Z",
    "content": {
        "system_prompt": "You are an HMI-certified induction composer. Create personalized hypnotic inductions using inferential language.",
        "user_prompt": "Create an emotional/inferential arm raising induction for a first-time client with emotional suggestibility and physical sexuality. Primary goal: career confidence. Base script provided. Personalize for a 35-year-old professional seeking better networking skills.",
        "base_script": "[Base HMI script]",
        "personalization_data": {
            "age": 35,
            "profession": "software engineer",
            "goal": "career confidence via networking",
            "interests": ["technology", "hiking", "music"]
        },
        "constraints": {
            "language_patterns": ["allowing", "tendency", "might notice", "as you begin to"],
            "avoid": ["direct commands", "must", "will", "you are"],
            "duration_target": 420
        }
    }
}

# Message 5: LLM response
{
    "from": "CustomHypnosisLLM",
    "to": "InductionComposer",
    "message_type": "synthesis_response",
    "timestamp": "2025-01-15T10:30:40Z",
    "content": {
        "personalized_script": "[Full personalized induction script...]",
        "metadata": {
            "word_count": 520,
            "estimated_duration_seconds": 415,
            "language_patterns_used": ["allowing", "tendency", "might notice"],
            "personalization_elements": ["career context", "networking scenarios", "technology metaphors"]
        }
    }
}

# Message 6: InductionComposer to SafetyOverseer (validation)
{
    "from": "InductionComposer",
    "to": "SafetyOverseer",
    "message_type": "content_validation_request",
    "timestamp": "2025-01-15T10:30:45Z",
    "content": {
        "content_type": "induction_script",
        "script_text": "[Full personalized induction script...]",
        "metadata": {
            "user_id": "user_abc123",
            "session_number": 1,
            "phase": "induction"
        }
    }
}

# Message 7: SafetyOverseer validation response
{
    "from": "SafetyOverseer",
    "to": "InductionComposer",
    "message_type": "content_validation_response",
    "timestamp": "2025-01-15T10:30:47Z",
    "content": {
        "validation_status": "approved",
        "checks_performed": [
            "harmful_content_scan",
            "autonomy_respect_check",
            "emergence_procedure_present"
        ],
        "issues_found": [],
        "risk_score": 0.05
    }
}

# Message 8: InductionComposer to CrewManager (completion)
{
    "from": "InductionComposer",
    "to": "CrewManager",
    "message_type": "task_completion",
    "timestamp": "2025-01-15T10:30:50Z",
    "content": {
        "task_id": "induction_001",
        "status": "completed",
        "output": {
            "segment_type": "induction",
            "script_text": "[Full personalized induction script...]",
            "duration_seconds": 415,
            "voice_settings": {
                "voice_id": "female_warm",
                "speed": 0.85,
                "pitch": -2
            },
            "metadata": {
                "language_patterns": ["inferential", "allowing"],
                "personalization_applied": true,
                "safety_approved": true
            }
        }
    }
}

# ============================================================================
# AGENT COLLABORATION (Sequential Process)
# ============================================================================

# Message 9: CrewManager to DeepeningArchitect (next agent)
{
    "from": "CrewManager",
    "to": "DeepeningArchitect",
    "message_type": "task_assignment",
    "timestamp": "2025-01-15T10:30:55Z",
    "content": {
        "task_id": "deepening_001",
        "context": {
            "previous_segment": {
                "type": "induction",
                "duration": 415,
                "depth_achieved_estimate": 0.55,
                "tone": "gentle_inferential"
            },
            "user_profile": {
                "suggestibility": "emotional",
                "responsiveness": "high"
            }
        },
        "task": "Generate deepening sequence to take user from depth 0.55 to 0.75",
        "available_tools": ["mcp_retrieve_deepening", "rag_vector_search", "llm_synthesis"],
        "success_criteria": [
            "Smooth transition from induction",
            "Progressive deepening to target depth",
            "Duration 8-10 minutes",
            "Passes safety validation"
        ]
    }
}

# Message 10: Agent-to-Agent direct communication (memory sharing)
{
    "from": "DeepeningArchitect",
    "to": "InductionComposer",
    "message_type": "context_request",
    "timestamp": "2025-01-15T10:31:00Z",
    "content": {
        "request_type": "induction_details",
        "needed_info": [
            "final_suggestions_given",
            "arm_position_at_end",
            "pace_of_conclusion"
        ]
    }
}

# Message 11: InductionComposer response
{
    "from": "InductionComposer",
    "to": "DeepeningArchitect",
    "message_type": "context_response",
    "timestamp": "2025-01-15T10:31:01Z",
    "content": {
        "induction_details": {
            "final_suggestions": "Hand resting comfortably on lap, feeling heavy and relaxed",
            "arm_position": "resting_on_lap",
            "conclusion_pace": "slow_with_long_pauses",
            "last_phrase": "...and you can go even deeper now..."
        }
    }
}

# ============================================================================
# CREW COMPLETION
# ============================================================================

# Message 12: CrewManager to SessionPlanner (all agents done)
{
    "from": "CrewManager",
    "to": "SessionPlanner",
    "message_type": "generation_complete",
    "timestamp": "2025-01-15T10:35:00Z",
    "content": {
        "task_id": "task_gen_001",
        "status": "completed",
        "session_components": {
            "induction": {
                "segment_id": "seg_ind_001",
                "duration_seconds": 415,
                "status": "ready"
            },
            "deepening": {
                "segment_id": "seg_deep_001",
                "duration_seconds": 540,
                "status": "ready"
            },
            "suggestions": {
                "segment_id": "seg_sugg_001",
                "duration_seconds": 720,
                "status": "ready"
            },
            "post_hypnotic": {
                "segment_id": "seg_phs_001",
                "duration_seconds": 180,
                "status": "ready"
            },
            "emergence": {
                "segment_id": "seg_emerg_001",
                "duration_seconds": 120,
                "status": "ready"
            }
        },
        "total_duration_seconds": 1975,
        "quality_metrics": {
            "coherence_score": 0.92,
            "personalization_score": 0.88,
            "safety_approval": true
        }
    }
}

5.3.3 MCP (Model Context Protocol) Server Calls
json// ============================================================================
// MCP PROTOCOL STRUCTURE (JSON-RPC 2.0)
// ============================================================================

// Request format
{
  "jsonrpc": "2.0",
  "id": "req_12345",
  "method": "tools/call",
  "params": {
    "name": "retrieve_induction",
    "arguments": {
      "suggestibility_type": "emotional",
      "session_number": 1
    }
  }
}

// Response format
{
  "jsonrpc": "2.0",
  "id": "req_12345",
  "result": {
    "content": [
      {
        "type": "text",
        "text": "[Script content...]"
      }
    ],
    "metadata": {
      "script_id": "hmi_emotional_arm_1",
      "duration_seconds": 400
    }
  }
}

// ============================================================================
// MCP SERVER: HMI Practicum Scripts
// ============================================================================

// Tool 1: retrieve_induction
{
  "jsonrpc": "2.0",
  "id": "req_001",
  "method": "tools/call",
  "params": {
    "name": "retrieve_induction",
    "arguments": {
      "suggestibility_type": "emotional",
      "session_number": 1,
      "include_arm_raising": true,
      "include_phs": true
    }
  }
}

// Response
{
  "jsonrpc": "2.0",
  "id": "req_001",
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Emotional/Inferred Arm Raising Induction\n\n[Full HMI script with inferential language patterns...]"
      }
    ],
    "metadata": {
      "script_id": "hmi_practicum_01_emotional",
      "script_name": "Emotional Arm Raising Induction",
      "suggestibility": "emotional",
      "session_number": 1,
      "duration_seconds": 400,
      "language_patterns": ["inferential", "allowing", "misdirection"],
      "includes_arm_raising": true,
      "includes_phs": true,
      "source": "HMI Practicum Manual"
    }
  }
}

// Tool 2: retrieve_deepening
{
  "jsonrpc": "2.0",
  "id": "req_002",
  "method": "tools/call",
  "params": {
    "name": "retrieve_deepening",
    "arguments": {
      "technique": "progressive_relaxation",
      "target_depth": 0.75,
      "current_depth": 0.55
    }
  }
}

// Tool 3: retrieve_suggestion
{
  "jsonrpc": "2.0",
  "id": "req_003",
  "method": "tools/call",
  "params": {
    "name": "retrieve_suggestion",
    "arguments": {
      "goal_category": "career",
      "sexuality_type": "physical",
      "specific_focus": "networking_confidence",
      "include_habit_loops": true
    }
  }
}

// ============================================================================
// MCP SERVER: Clinical Guidelines
// ============================================================================

// Tool 1: check_contraindications
{
  "jsonrpc": "2.0",
  "id": "req_004",
  "method": "tools/call",
  "params": {
    "name": "check_contraindications",
    "arguments": {
      "user_id": "user_abc123",
      "session_type": "therapeutic",
      "user_conditions": ["anxiety", "past_trauma"]
    }
  }
}

// Response
{
  "jsonrpc": "2.0",
  "id": "req_004",
  "result": {
    "content": [
      {
        "type": "text",
        "text": "No absolute contraindications found. Relative contraindications require monitoring."
      }
    ],
    "contraindications": [],
    "warnings": [
      {
        "condition": "past_trauma",
        "severity": "medium",
        "recommendation": "Avoid deep regression work in early sessions. Focus on resource building.",
        "monitoring_required": true
      }
    ],
    "cleared_for_session": true
  }
}

// Tool 2: get_safety_protocol
{
  "jsonrpc": "2.0",
  "id": "req_005",
  "method": "tools/call",
  "params": {
    "name": "get_safety_protocol",
    "arguments": {
      "protocol_type": "emergency_emergence",
      "severity": "high"
    }
  }
}

// Tool 3: validate_suggestion
{
  "jsonrpc": "2.0",
  "id": "req_006",
  "method": "tools/call",
  "params": {
    "name": "validate_suggestion",
    "arguments": {
      "suggestion_text": "You find it easy and natural to connect with others professionally...",
      "user_id": "user_abc123",
      "goal": "career_confidence"
    }
  }
}

// Response
{
  "jsonrpc": "2.0",
  "id": "req_006",
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Suggestion validated. No harmful content detected. Respects user autonomy."
      }
    ],
    "validation_status": "approved",
    "checks_passed": [
      "no_harmful_content",
      "respects_autonomy",
      "realistic_expectations",
      "aligned_with_goals"
    ],
    "risk_score": 0.05,
    "recommendations": []
  }
}

// ============================================================================
// MCP SERVER: Safety Protocols
// ============================================================================

// Tool 1: escalate_to_human
{
  "jsonrpc": "2.0",
  "id": "req_007",
  "method": "tools/call",
  "params": {
    "name": "escalate_to_human",
    "arguments": {
      "session_id": "sess_abc123",
      "reason": "sustained_high_stress",
      "severity": "critical",
      "biometric_data": {
        "heart_rate": 148,
        "gsr": 0.94,
        "duration_seconds": 120
      },
      "preferred_therapist": null
    }
  }
}

// Response
{
  "jsonrpc": "2.0",
  "id": "req_007",
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Escalation successful. Therapist notified and available in 30 seconds."
      }
    ],
    "escalation_id": "esc_critical_001",
    "therapist_assigned": {
      "therapist_id": "therapist_789",
      "name": "Dr. Sarah Johnson",
      "eta_seconds": 30,
      "notification_sent": true
    },
    "emergency_procedures_active": true,
    "session_paused": true
  }
}

// Tool 2: emergency_emergence
{
  "jsonrpc": "2.0",
  "id": "req_008",
  "method": "tools/call",
  "params": {
    "name": "emergency_emergence",
    "arguments": {
      "session_id": "sess_abc123",
      "current_phase": "deepening",
      "user_state": "distressed"
    }
  }
}

// Response
{
  "jsonrpc": "2.0",
  "id": "req_008",
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Rapid emergence procedure: 'We're going to bring you back up now. On the count of 5...'"
      }
    ],
    "procedure_type": "rapid_emergence",
    "script_segments": [
      {
        "order": 1,
        "text": "We're going to bring you back up now",
        "duration_seconds": 2
      },
      {
        "order": 2,
        "text": "On the count of 5, you'll be wide awake and alert",
        "duration_seconds": 3
      },
      {
        "order": 3,
        "text": "1... 2... 3... 4... 5... Eyes open, wide awake",
        "duration_seconds": 5
      }
    ],
    "total_duration_seconds": 10,
    "post_emergence_monitoring_required": true
  }
}

 Part 6: Personalization Matrix - All 16 E&P Combinations
6.1 Personalization Matrix Overview
┌─────────────────────────────────────────────────────────────────────────┐
│                    E&P PERSONALIZATION MATRIX                            │
│                    (Suggestibility × Sexuality)                          │
└─────────────────────────────────────────────────────────────────────────┘

                        SEXUALITY TYPE
                ┌──────────┬──────────┬──────────┬──────────┐
                │ Physical │ Emotional│ Balanced │ Unclear  │
                │  (P-Sex) │  (E-Sex) │ (B-Sex)  │ (U-Sex)  │
┌───────────────┼──────────┼──────────┼──────────┼──────────┤
│ Physical      │    P1    │    P2    │    P3    │    P4    │
│ Suggestibility│  (P-P)   │  (P-E)   │  (P-B)   │  (P-U)   │
│ (P-Sugg)      │          │          │          │          │
├───────────────┼──────────┼──────────┼──────────┼──────────┤
│ Emotional     │    E1    │    E2    │    E3    │    E4    │
│ Suggestibility│  (E-P)   │  (E-E)   │  (E-B)   │  (E-U)   │
│ (E-Sugg)      │          │          │          │          │
├───────────────┼──────────┼──────────┼──────────┼──────────┤
│ Balanced      │    B1    │    B2    │    B3    │    B4    │
│ Suggestibility│  (B-P)   │  (B-E)   │  (B-B)   │  (B-U)   │
│ (B-Sugg)      │          │          │          │          │
├───────────────┼──────────┼──────────┼──────────┼──────────┤
│ Unclear       │    U1    │    U2    │    U3    │    U4    │
│ Suggestibility│  (U-P)   │  (U-E)   │  (U-B)   │  (U-U)   │
│ (U-Sugg)      │          │          │          │          │
└───────────────┴──────────┴──────────┴──────────┴──────────┘

Key:
P-Sugg = Physical/Literal Suggestibility (responds to direct commands)
E-Sugg = Emotional/Inferred Suggestibility (responds to indirect suggestions)
B-Sugg = Balanced Suggestibility (responds to both equally)
U-Sugg = Unclear Suggestibility (requires further assessment)

P-Sex = Physical Sexuality (values connection, relationships, acceptance)
E-Sex = Emotional Sexuality (values control, security, achievement)
B-Sex = Balanced Sexuality (values both connection and autonomy)
U-Sex = Unclear Sexuality (requires E&P assessment or default protocols)

6.2 Detailed Profiles for Each Combination
Profile P1: Physical Suggestibility + Physical Sexuality (P-P)
yamlCOMBINATION: P1 (P-P)
Prevalence: ~20% of population
Nickname: "The Direct Connector"

CORE CHARACTERISTICS:
  Suggestibility:
    - Responds to direct, literal commands
    - Prefers concrete, explicit instructions
    - Thinks in physical terms
    - Fast processing speed
  
  Sexuality:
    - Values connection and relationships
    - Seeks acceptance and belonging
    - Moves forward when facing rejection
    - Emotional rewards drive behavior

INDUCTION PROTOCOL:
  Style: Physical/Literal Arm Raising
  Approach: Direct commands with connection-focused framing
  
  Language Patterns:
    - "Your arm WILL rise"
    - "You ARE becoming more connected"
    - "You FEEL the warmth of belonging"
    - Commands wrapped in relationship context
  
  Example Opening:
    "As I count from 5 to 1, your arm will rise up, and as it rises, 
    you'll feel a growing sense of connection to yourself and others. 
    5... your arm begins to rise now... 4... feeling more connected... 
    3... your arm rising higher... 2... belonging and acceptance flowing 
    through you... 1... arm fully raised, feeling completely connected."

DEEPENING TECHNIQUES:
  Primary: Progressive Physical Relaxation
  Secondary: Body-Scan with Connection Themes
  
  Approach:
    - Direct body-focused relaxation commands
    - Link physical relaxation to emotional connection
    - Use concrete imagery (warm embrace, gentle touch)

THERAPEUTIC SUGGESTIONS:
  Framework: Direct Identity Statements + Connection Themes
  
  Core Themes:
    - "You ARE a person who connects easily with others"
    - "You BELONG in professional/social environments"
    - "Others naturally ACCEPT and appreciate you"
    - "You feel COMFORTABLE reaching out and building relationships"
  
  Habit Formation:
    - Direct action commands: "You WILL network weekly"
    - Connection-based rewards: "You feel BELONGING when you connect"
    - Social accountability built in
  
  Identity Shift Language:
    - "You ARE the type of person who builds authentic connections"
    - "Being accepted and valued IS your natural state"
    - "You BELONG in rooms where opportunities exist"

VOICE CHARACTERISTICS:
  Tone: Warm, direct, confident
  Pace: Moderate to fast (matches their processing speed)
  Pitch: Neutral to slightly warm
  Volume: Clear and present
  Emotional Quality: Friendly, accepting, inviting

SESSION PACING:
  Induction: 6-8 minutes (efficient, direct)
  Deepening: 8-10 minutes
  Suggestions: 15-20 minutes (thorough, direct)
  Total: 40-50 minutes

COMMON GOALS:
  1. Career advancement through networking
  2. Building authentic friendships
  3. Finding romantic partnership
  4. Public speaking confidence
  5. Team leadership skills

CHALLENGES & SOLUTIONS:
  Challenge: May feel commands are "pushy" if not framed with warmth
  Solution: Always contextualize direct commands within connection themes
  
  Challenge: Can become anxious if isolated during process
  Solution: Emphasize therapist presence, use "we" language
  
  Challenge: May resist if they don't feel accepted by therapist
  Solution: Build strong rapport in pre-talk, validate their experiences

CONTRAINDICATIONS:
  - Avoid isolation imagery
  - Don't emphasize being alone or self-sufficient
  - Minimize competitive "beat others" language

SAMPLE SUGGESTION SCRIPT:
  "You ARE a natural connector. When you walk into a room, you FEEL 
  comfortable and BELONG there. Others sense your genuine warmth and 
  WANT to connect with you. You FIND it easy to start conversations, 
  to share your authentic self, and to build meaningful relationships. 
  Each day, you ACT on opportunities to connect - a smile, a kind word, 
  a genuine question. And as you DO this, you FEEL the reward of 
  belonging, of being valued, of being part of something larger than 
  yourself. You ARE a person who builds bridges between people, and 
  this IS who you naturally are."

10% ADJUSTMENT RULE:
  If P-Sugg ≥ 60% AND E-Sex ≥ 40%:
    → Increase P-Sex by 10% in suggestion themes
    → Emphasize connection even more strongly
    → Use phrases like "You BELONG" more frequently

Profile P2: Physical Suggestibility + Emotional Sexuality (P-E)
yamlCOMBINATION: P2 (P-E)
Prevalence: ~15% of population
Nickname: "The Controlled Achiever"

CORE CHARACTERISTICS:
  Suggestibility:
    - Responds to direct, literal commands
    - Prefers concrete, explicit instructions
    - Thinks in physical terms
  
  Sexuality:
    - Values control and autonomy
    - Seeks security and achievement
    - Withdraws when facing rejection
    - Tangible results drive behavior

INDUCTION PROTOCOL:
  Style: Physical/Literal Arm Raising
  Approach: Direct commands with control-focused framing
  
  Language Patterns:
    - "Your arm WILL rise - you are IN CONTROL"
    - "You CHOOSE to go deeper"
    - "You MAINTAIN your awareness while relaxing"
    - Commands that emphasize user's agency
  
  Example Opening:
    "As I count from 5 to 1, you'll CHOOSE to allow your arm to rise. 
    You remain completely IN CONTROL throughout this process. 5... you 
    DECIDE to lift your arm now... 4... you MAINTAIN full awareness... 
    3... you CONTROL the pace of your relaxation... 2... you ACHIEVE 
    the perfect state for change... 1... arm fully raised, you are 
    IN COMMAND of this experience."

DEEPENING TECHNIQUES:
  Primary: Fractionation (Control-Based)
  Secondary: Countdown with Milestone Achievements
  
  Approach:
    - User directs their own deepening
    - Emphasize mastery and control at each level
    - Use achievement-oriented milestones
    - "You've REACHED level 5... you've ACHIEVED deeper relaxation"

THERAPEUTIC SUGGESTIONS:
  Framework: Direct Achievement Commands + Security Themes
  
  Core Themes:
    - "You ARE in control of your career trajectory"
    - "You ACHIEVE your goals with precision and skill"
    - "You MAINTAIN security while taking calculated risks"
    - "Success IS inevitable when you execute your plans"
  
  Habit Formation:
    - Direct action commands: "You WILL complete tasks systematically"
    - Achievement-based rewards: "You feel ACCOMPLISHED when you finish"
    - Self-accountability and tracking built in
  
  Identity Shift Language:
    - "You ARE the type of person who executes flawlessly"
    - "Being in control and secure IS your natural state"
    - "You MASTER challenges through discipline and skill"

VOICE CHARACTERISTICS:
  Tone: Confident, authoritative, respectful
  Pace: Moderate to brisk (efficient)
  Pitch: Neutral to slightly lower (grounded)
  Volume: Clear and strong
  Emotional Quality: Professional, competent, trustworthy

SESSION PACING:
  Induction: 5-7 minutes (efficient)
  Deepening: 8-10 minutes (structured)
  Suggestions: 15-20 minutes (results-oriented)
  Total: 35-45 minutes (respects their time)

COMMON GOALS:
  1. Career advancement through skill mastery
  2. Financial security and wealth building
  3. Peak performance (athletics, business)
  4. Habit optimization (productivity, health)
  5. Overcoming specific fears/phobias

CHALLENGES & SOLUTIONS:
  Challenge: May resist if they feel "loss of control"
  Solution: Constantly reinforce their agency and choice
  
  Challenge: Can be skeptical of "woo-woo" language
  Solution: Use concrete, results-oriented language
  
  Challenge: May withdraw if suggestions feel unrealistic
  Solution: Focus on actionable, achievable goals

CONTRAINDICATIONS:
  - Avoid dependency language ("need others")
  - Don't emphasize vulnerability or emotional openness
  - Minimize relationship-focused suggestions unless specifically requested

SAMPLE SUGGESTION SCRIPT:
  "You ARE in complete control of your professional growth. You POSSESS 
  the skills and discipline to ACHIEVE any goal you set. Each morning, 
  you WAKE with clarity about your priorities. You EXECUTE your plan 
  with precision. You MAINTAIN focus despite distractions. And as you 
  ACCOMPLISH each milestone, you feel deep satisfaction - the reward 
  of mastery and competence. You ARE building the secure, successful 
  future you envision. Your path is clear. Your execution is flawless. 
  Your success is inevitable. This IS who you are."

10% ADJUSTMENT RULE:
  If P-Sugg ≥ 60% AND P-Sex ≥ 40%:
    → Increase E-Sex control themes by 10%
    → Emphasize security and achievement even more
    → Use phrases like "You CONTROL" more frequently

Profile E1: Emotional Suggestibility + Physical Sexuality (E-P)
yamlCOMBINATION: E1 (E-P)
Prevalence: ~25% of population (most common combination)
Nickname: "The Gentle Connector"

CORE CHARACTERISTICS:
  Suggestibility:
    - Responds to indirect, inferential suggestions
    - Prefers allowing, permissive language
    - Processes information slowly
    - Subconscious integration
  
  Sexuality:
    - Values connection and relationships
    - Seeks acceptance and belonging
    - Moves forward when facing rejection
    - Emotional rewards drive behavior

INDUCTION PROTOCOL:
  Style: Emotional/Inferred Arm Raising
  Approach: Indirect suggestions with connection-focused framing
  
  Language Patterns:
    - "You might begin to notice a tendency for your arm to feel lighter"
    - "As you allow yourself to feel more connected..."
    - "There's a natural inclination to experience belonging"
    - Permissive language wrapped in relationship context
  
  Example Opening:
    "As we begin, you might start to notice how comfortable it feels 
    to simply allow yourself to be here, in this moment. And as you 
    settle in, there may be a growing awareness of connection - to 
    yourself, to this process, to the possibilities opening before you. 
    Your arm might begin to feel lighter, as if it has a tendency to 
    float upward. You don't have to make it happen; you can simply 
    allow it to unfold naturally. And as it does, you might notice 
    a deepening sense of belonging, of being exactly where you're 
    meant to be..."

DEEPENING TECHNIQUES:
  Primary: Safe Place / Sanctuary Visualization
  Secondary: Gradual Staircase with Relationship Imagery
  
  Approach:
    - Create emotionally safe spaces filled with warmth
    - Use sensory-rich descriptions
    - Emphasize gentle, gradual descent
    - Include imagery of supportive presence

THERAPEUTIC SUGGESTIONS:
  Framework: Inferential Identity Statements + Connection Themes
  
  Core Themes:
    - "You're beginning to discover you're the kind of person who..."
    - "There's a natural tendency to feel accepted wherever you go"
    - "You might notice you're increasingly comfortable connecting"
    - "Others are drawn to your authentic, warm presence"
  
  Habit Formation:
    - Inferential action suggestions: "You may find yourself naturally..."
    - Connection-based rewards: "Belonging feels natural when you..."
    - Gentle accountability through self-discovery
  
  Identity Shift Language:
    - "You're discovering you're someone who builds meaningful bonds"
    - "Feeling accepted and valued becomes increasingly natural"
    - "There's a growing awareness that you truly belong"

VOICE CHARACTERISTICS:
  Tone: Warm, gentle, nurturing
  Pace: Slow with long pauses (allows processing)
  Pitch: Soft, slightly higher (soothing)
  Volume: Moderate to quiet
  Emotional Quality: Accepting, compassionate, present

SESSION PACING:
  Induction: 8-12 minutes (allows slow processing)
  Deepening: 12-15 minutes (gradual, gentle)
  Suggestions: 20-25 minutes (thorough, layered)
  Total: 50-60 minutes (unhurried)

COMMON GOALS:
  1. Building authentic friendships
  2. Overcoming social anxiety
  3. Finding romantic partnership
  4. Career networking (with focus on genuine connection)
  5. Self-acceptance and self-love
  6. Healing relationship wounds

CHALLENGES & SOLUTIONS:
  Challenge: May feel rushed if pacing is too fast
  Solution: Allow ample pauses, slow down delivery significantly
  
  Challenge: Direct commands can create resistance
  Solution: Always use permissive, allowing language
  
  Challenge: May need more sessions to achieve depth
  Solution: Set expectation that growth unfolds gradually

CONTRAINDICATIONS:
  - Avoid direct commands or "must/should" language
  - Don't rush the process or set strict timelines
  - Minimize achievement-focused language unless balanced with connection

SAMPLE SUGGESTION SCRIPT:
  "You might begin to notice something interesting happening. There's 
  a growing awareness that you're the kind of person others naturally 
  feel drawn to. Not because you're trying to be anyone other than 
  yourself, but precisely because you're allowing your authentic self 
  to shine through. You may find, in the days and weeks ahead, that 
  conversations flow more easily. That smiles come more naturally. 
  That there's a gentle confidence emerging - not loud or forceful, 
  but quiet and genuine. You belong in the spaces you occupy. You're 
  valued for exactly who you are. And as you allow this truth to 
  settle into your awareness, you might discover that connection 
  isn't something you have to chase. It's something that unfolds 
  naturally when you give yourself permission to be seen."

10% ADJUSTMENT RULE:
  If E-Sugg ≥ 60% AND E-Sex ≥ 40%:
    → Increase P-Sex connection themes by 10%
    → Emphasize belonging and acceptance even more
    → Use relationship-focused language more frequently

Profile E2: Emotional Suggestibility + Emotional Sexuality (E-E)
yamlCOMBINATION: E2 (E-E)
Prevalence: ~15% of population
Nickname: "The Strategic Contemplator"

CORE CHARACTERISTICS:
  Suggestibility:
    - Responds to indirect, inferential suggestions
    - Prefers allowing, permissive language
    - Processes information slowly
  
  Sexuality:
    - Values control and autonomy
    - Seeks security and achievement
    - Withdraws when facing rejection
    - Tangible results drive behavior

INDUCTION PROTOCOL:
  Style: Emotional/Inferred Arm Raising
  Approach: Indirect suggestions with autonomy-focused framing
  
  Language Patterns:
    - "You might discover you're naturally maintaining control"
    - "There's a tendency to experience mastery unfolding"
    - "You may notice you're choosing to allow deeper relaxation"
    - Permissive language that respects autonomy
  
  Example Opening:
    "As you settle in, you might become aware that you're in complete 
    control of this experience. You're choosing to be here, choosing 
    to explore what's possible. Your arm might develop a tendency to 
    feel lighter, and as it does, you may notice you're maintaining 
    full awareness while allowing relaxation to deepen. You're 
    orchestrating this process. You're the master of your own mind. 
    And there's something deeply satisfying about this realization - 
    that you can achieve profound states while remaining completely 
    in command."

DEEPENING TECHNIQUES:
  Primary: Self-Directed Visualization Journey
  Secondary: Progressive Achievement of Deeper States
  
  Approach:
    - User visualizes themselves mastering each level
    - Emphasize internal locus of control
    - Use achievement milestones
    - Frame as personal skill development

THERAPEUTIC SUGGESTIONS:
  Framework: Inferential Achievement Statements + Security Themes
  
  Core Themes:
    - "You're discovering you possess natural abilities to achieve..."
    - "There's a growing awareness of your competence and skill"
    - "You may find you're increasingly in command of your path"
    - "Security and success unfold naturally from your choices"
  
  Habit Formation:
    - Inferential action: "You may discover you're naturally..."
    - Achievement rewards: "Mastery feels satisfying as you..."
    - Self-directed accountability
  
  Identity Shift Language:
    - "You're uncovering you're someone who executes with precision"
    - "Being in control and competent becomes increasingly natural"
    - "There's a deepening recognition of your inherent capability"

VOICE CHARACTERISTICS:
  Tone: Respectful, intelligent, sophisticated
  Pace: Slow to moderate with strategic pauses
  Pitch: Neutral to slightly lower (grounded authority)
  Volume: Moderate (present but not imposing)
  Emotional Quality: Competent, trustworthy, empowering

SESSION PACING:
  Induction: 8-10 minutes (thoughtful)
  Deepening: 10-12 minutes (self-directed)
  Suggestions: 20-25 minutes (strategic, layered)
  Total: 45-55 minutes

COMMON GOALS:
  1. Executive presence and leadership
  2. Financial independence and wealth mastery
  3. Strategic career advancement
  4. Breaking through performance plateaus
  5. Developing inner discipline
  6. Mastering anxiety or stress

CHALLENGES & SOLUTIONS:
  Challenge: Can be highly analytical, resistant to "letting go"
  Solution: Frame hypnosis as skill mastery, emphasize control
  
  Challenge: May withdraw if pushed too hard
  Solution: Always offer choice, use "may/might/could" language
  
  Challenge: Needs to see logical pathway to goals
  Solution: Connect suggestions to clear cause-effect chains

CONTRAINDICATIONS:
  - Avoid dependency or neediness language
  - Don't use direct commands
  - Minimize emotional vulnerability themes unless specifically requested

SAMPLE SUGGESTION SCRIPT:
  "You might begin to notice something powerful emerging. There's a 
  growing recognition that you possess the strategic thinking and 
  discipline to achieve whatever you set your mind to. You may find, 
  in the coming days, that decisions come with greater clarity. That 
  priorities align themselves naturally. That distractions lose their 
  power over you. You're developing a quiet mastery - not through 
  force, but through alignment. Your subconscious mind is organizing 
  itself around your goals, creating pathways where obstacles once 
  stood. You're becoming increasingly aware of your own capability, 
  your own power to shape your reality. And as this awareness deepens, 
  you may discover that success isn't something you chase - it's 
  something you architect, one strategic choice at a time."

10% ADJUSTMENT RULE:
  If E-Sugg ≥ 60% AND P-Sex ≥ 40%:
    → Increase E-Sex autonomy themes by 10%
    → Emphasize control and security even more
    → Use mastery-focused language more frequently

Profile P3: Physical Suggestibility + Balanced Sexuality (P-B)
yamlCOMBINATION: P3 (P-B)
Prevalence: ~10% of population
Nickname: "The Versatile Executor"

CORE CHARACTERISTICS:
  Suggestibility:
    - Responds to direct, literal commands
    - Prefers concrete, explicit instructions
  
  Sexuality:
    - Values both connection AND autonomy equally
    - Seeks balance between relationships and independence
    - Flexible response to rejection
    - Both emotional and tangible rewards matter

INDUCTION PROTOCOL:
  Style: Physical/Literal Arm Raising (Hybrid Framing)
  Approach: Direct commands that honor both connection and control
  
  Language Patterns:
    - "Your arm WILL rise as you CHOOSE"
    - "You ARE connected while maintaining your individuality"
    - "You BELONG and you ARE in control"
    - Balanced commands
  
  Example Opening:
    "As I count from 5 to 1, your arm will rise. You're choosing to 
    participate fully, and as you do, you'll notice you're both 
    connected to this process AND in complete control of your 
    experience. 5... your arm begins to rise... you're present and 
    engaged... 4... rising higher... you're part of something while 
    remaining yourself... 3... continuing upward... connected and 
    autonomous... 2... almost there... secure in your power and open 
    to possibility... 1... fully raised, perfectly balanced."

DEEPENING TECHNIQUES:
  Primary: Dual-Focus Visualization (Self & Others)
  Secondary: Alternating Between Connection and Mastery Imagery
  
  Approach:
    - Balance relationship and achievement imagery
    - Emphasize wholeness and integration
    - Use both warm and confident tones

THERAPEUTIC SUGGESTIONS:
  Framework: Direct Statements with Dual Themes
  
  Core Themes:
    - "You ARE capable AND connected"
    - "You ACHIEVE your goals while maintaining relationships"
    - "You BELONG in your power"
    - "Success includes meaningful connections"
  
  Habit Formation:
    - Direct actions: "You WILL do X" balanced with connection rewards
    - Both achievement AND relationship benefits emphasized
  
  Identity Shift Language:
    - "You ARE someone who excels independently AND collaboratively"
    - "Being whole means integrating all parts of yourself"

VOICE CHARACTERISTICS:
  Tone: Warm yet authoritative
  Pace: Moderate
  Pitch: Neutral
  Emotional Quality: Balanced, integrative

SESSION PACING:
  Induction: 6-8 minutes
  Deepening: 10-12 minutes
  Suggestions: 18-22 minutes
  Total: 40-50 minutes

COMMON GOALS:
  1. Work-life balance
  2. Leadership with emotional intelligence
  3. Building successful business with strong culture
  4. Personal development across all life areas
  5. Integrated wellness (mind, body, relationships)

SAMPLE SUGGESTION SCRIPT:
  "You ARE a complete person. You excel in your career AND nurture 
  meaningful relationships. You ACHIEVE ambitious goals while 
  maintaining balance. You're powerful AND compassionate. Independent 
  AND connected. You don't have to choose between success and love, 
  between autonomy and belonging. You HAVE both. You ARE both. This 
  integration IS your strength."

Profile E3: Emotional Suggestibility + Balanced Sexuality (E-B)
yamlCOMBINATION: E3 (E-B)
Prevalence: ~8% of population
Nickname: "The Harmonious Integrator"

CORE CHARACTERISTICS:
  Suggestibility:
    - Responds to indirect, inferential suggestions
    - Prefers allowing, permissive language
  
  Sexuality:
    - Values both connection AND autonomy equally
    - Seeks balance between relationships and independence

INDUCTION PROTOCOL:
  Style: Emotional/Inferred Arm Raising (Hybrid Framing)
  Approach: Indirect suggestions honoring both connection and control
  
  Language Patterns:
    - "You might notice a tendency to feel both connected and independent"
    - "There's a natural balance emerging"
    - "You may discover you're whole and integrated"
  
  Example Opening:
    "As you settle in, you might become aware of something interesting. 
    There's a way to be fully present with yourself while also feeling 
    connected to something larger. You don't have to choose. Your arm 
    might develop a tendency to feel lighter, and as it does, you may 
    notice you're experiencing both mastery and openness. Both strength 
    and gentleness. Both autonomy and belonging. All at once. This 
    wholeness is your natural state."

DEEPENING TECHNIQUES:
  Primary: Integrated Self Visualization
  Secondary: Balancing Inner Masculine & Feminine Energies
  
  Approach:
    - Emphasize integration and wholeness
    - Use yin-yang, balance metaphors
    - Honor all aspects of self

THERAPEUTIC SUGGESTIONS:
  Framework: Inferential Integration Statements
  
  Core Themes:
    - "You're discovering you can be both powerful and vulnerable"
    - "There's a growing awareness that all parts of you belong"
    - "You may notice you're naturally balancing achievement and connection"

VOICE CHARACTERISTICS:
  Tone: Warm, wise, balanced
  Pace: Slow to moderate
  Pitch: Neutral, harmonious
  Emotional Quality: Integrated, whole, peaceful

SESSION PACING:
  Induction: 10-12 minutes
  Deepening: 12-15 minutes
  Suggestions: 20-25 minutes
  Total: 50-55 minutes

COMMON GOALS:
  1. Life integration and wholeness
  2. Authentic leadership
  3. Conscious relationships
  4. Personal growth across all dimensions
  5. Spiritual development with practical grounding

SAMPLE SUGGESTION SCRIPT:
  "You might begin to notice something profound. There's no part of you 
  that needs to be excluded or hidden. The part that achieves and the 
  part that connects - they work together. The part that's strong and 
  the part that's gentle - they're both you. You're discovering that 
  wholeness means integration, not perfection. And as this awareness 
  deepens, you may find that life becomes less about choosing between 
  competing values and more about honoring the fullness of who you are."

Profiles P4, E4, B1-B4, U1-U4: Summary Table
yaml# Due to space constraints, here's a condensed reference for remaining profiles

PROFILE P4 (Physical Sugg + Unclear Sex):
  Approach: Use Physical induction, neutral suggestions until E&P assessed
  Focus: Concrete actions, both connection and achievement themes
  Duration: 40-45 minutes

PROFILE E4 (Emotional Sugg + Unclear Sex):
  Approach: Use Emotional induction, neutral suggestions until E&P assessed
  Focus: Inferential language, both connection and achievement themes
  Duration: 50-55 minutes

PROFILE B1 (Balanced Sugg + Physical Sex):
  Approach: Hybrid induction (both direct and indirect), connection focus
  Language: Mix of commands and permissive suggestions
  Themes: Connection, belonging, acceptance
  Duration: 45-50 minutes

PROFILE B2 (Balanced Sugg + Emotional Sex):
  Approach: Hybrid induction (both direct and indirect), control focus
  Language: Mix of commands and permissive suggestions
  Themes: Mastery, achievement, security
  Duration: 45-50 minutes

PROFILE B3 (Balanced Sugg + Balanced Sex):
  Approach: Hybrid induction, integrated themes
  Language: Flexible, responsive to user
  Themes: Integration, wholeness, balance
  Duration: 45-50 minutes
  Note: Most flexible profile, easiest to work with

PROFILE B4 (Balanced Sugg + Unclear Sex):
  Approach: Hybrid induction, neutral themes until E&P assessed
  Language: Balanced, adaptable
  Duration: 45-50 minutes

PROFILE U1 (Unclear Sugg + Physical Sex):
  Approach: Start inferential, adapt based on response, connection focus
  Initial Session: Assessment-focused, conservative protocol
  Duration: 40-50 minutes
  Note: Re-assess suggestibility after 1-2 sessions

PROFILE U2 (Unclear Sugg + Emotional Sex):
  Approach: Start inferential, adapt based on response, control focus
  Initial Session: Assessment-focused, conservative protocol
  Duration: 40-50 minutes
  Note: Re-assess suggestibility after 1-2 sessions

PROFILE U3 (Unclear Sugg + Balanced Sex):
  Approach: Start inferential, adapt, integrated themes
  Initial Session: Broad assessment
  Duration: 45-50 minutes

PROFILE U4 (Unclear Sugg + Unclear Sex):
  Approach: Conservative inferential protocol, neutral themes
  Initial Session: Full assessment focus, minimal therapeutic work
  Duration: 30-40 minutes
  Note: Defer deep therapeutic work until both assessments complete
  Recommendation: Complete all assessments before first full session

6.3 Language Pattern Library by Type
Physical Suggestibility Language Patterns
yamlCOMMAND PATTERNS (Physical):
  Power Words:
    - WILL (definitive)
    - ARE / IS (state of being)
    - DO / DOES (action)
    - CAN (capability)
    - NOW (immediacy)
  
  Sentence Structures:
    - "Your [body part] WILL [action]"
    - "You ARE [identity statement]"
    - "You DO [behavior] automatically"
    - "This IS happening now"
    - "You CAN feel [sensation]"
  
  Examples:
    - "Your eyelids ARE becoming heavy NOW"
    - "You WILL go deeper with each breath"
    - "Your body IS relaxing completely"
    - "You DO this naturally and easily"
    - "Relaxation flows through you NOW"
  
  Timing:
    - Immediate expectation
    - Present tense dominant
    - Fast pacing acceptable
  
  Avoid:
    - Might, maybe, perhaps (too weak)
    - Could, would (too hypothetical)
    - Overly complex sentences

Emotional Suggestibility Language Patterns
yamlPERMISSIVE PATTERNS (Emotional):
  Softening Words:
    - MIGHT / MAY (possibility)
    - COULD / CAN (potential)
    - PERHAPS (gentle suggestion)
    - TENDENCY TO (natural inclination)
    - BEGIN TO / START TO (gradual)
    - ALLOW / PERMIT (permission)
    - DISCOVER / NOTICE (awareness)
  
  Sentence Structures:
    - "You might begin to notice..."
    - "There's a tendency for..."
    - "You may discover..."
    - "As you allow yourself to..."
    - "Perhaps you're becoming aware..."
    - "It could be that..."
  
  Examples:
    - "Your eyelids might begin to feel heavier"
    - "There's a natural tendency for relaxation to deepen"
    - "You may discover you're going deeper"
    - "As you allow your body to relax..."
    - "Perhaps you're noticing a growing sense of calm"
  
  Timing:
    - Gradual unfolding
    - Future or progressive tense
    - Slow pacing essential
    - Long pauses for integration
  
  Avoid:
    - Direct commands (creates resistance)
    - "Must" or "should" (pressure)
    - Rushed pacing
    - Demanding language

Physical Sexuality Language Patterns
yamlCONNECTION THEMES (Physical Sexuality):
  Core Concepts:
    - Connection & Disconnection
    - Belonging & Exclusion
    - Acceptance & Rejection
    - Relationships & Isolation
    - Warmth & Coldness
    - Together & Alone
  
  Positive Framing:
    - "You feel connected to..."
    - "You belong in..."
    - "Others naturally accept you"
    - "You're part of something meaningful"
    - "Warmth surrounds you"
    - "You're valued and appreciated"
  
  Identity Statements:
    - "You are someone who builds authentic connections"
    - "Being accepted is your natural state"
    - "You belong in rooms where opportunities exist"
    - "Others are drawn to your genuine warmth"
  
  Motivation Through:
    - Feeling loved, valued, accepted
    - Being part of a community
    - Building meaningful relationships
    - Social validation and approval
  
  Habit Rewards:
    - "You feel deeply satisfied when you connect"
    - "Belonging fills you up"
    - "Each interaction reminds you that you matter"
  
  Avoid:
    - Isolation imagery
    - "You don't need anyone" statements
    - Emphasizing self-sufficiency over connection
    - Competitive "beat others" language

Emotional Sexuality Language Patterns
yamlCONTROL THEMES (Emotional Sexuality):
  Core Concepts:
    - Control & Chaos
    - Security & Vulnerability
    - Achievement & Failure
    - Mastery & Incompetence
    - Order & Disorder
    - Independence & Dependency
  
  Positive Framing:
    - "You are in control of..."
    - "You maintain security while..."
    - "You achieve your goals through..."
    - "You master challenges by..."
    - "Your life has order and structure"
    - "You are independently capable"
  
  Identity Statements:
    - "You are someone who executes with precision"
    - "Being in control is your natural state"
    - "You achieve what you set out to accomplish"
    - "Mastery and competence define you"
  
  Motivation Through:
    - Sense of achievement and progress
    - Tangible results and metrics
    - Security and stability
    - Personal power and autonomy
  
  Habit Rewards:
    - "You feel accomplished when you complete tasks"
    - "Mastery brings deep satisfaction"
    - "Each success reinforces your capability"
  
  Avoid:
    - Dependency language ("you need others")
    - Vulnerability without empowerment
    - Loss of control imagery
    - Relationship obligations

6.4 Goal-Specific Adaptations by E&P Type
Career Success Goals
yamlCAREER SUCCESS - By E&P Type:

P-P (Physical Sugg + Physical Sex):
  Focus: Direct commands + Networking/Connection
  Suggestions:
    - "You ARE confident in professional settings"
    - "You CONNECT authentically with colleagues"
    - "Opportunities FLOW to you through relationships"
  Habit: Weekly networking with connection-based reward
  Identity: "I am a natural relationship builder in my field"

P-E (Physical Sugg + Emotional Sex):
  Focus: Direct commands + Achievement/Mastery
  Suggestions:
    - "You EXECUTE your career plan with precision"
    - "You ARE in control of your professional trajectory"
    - "Success IS inevitable through your disciplined actions"
  Habit: Daily skill development with achievement reward
  Identity: "I am a master of my craft who executes flawlessly"

E-P (Emotional Sugg + Physical Sex):
  Focus: Inferential + Networking/Connection
  Suggestions:
    - "You might notice you're naturally connecting at work"
    - "There's a tendency for others to value your contributions"
    - "You may discover opportunities unfold through relationships"
  Habit: Gentle networking with belonging reward
  Identity: "I'm discovering I'm someone people want to work with"

E-E (Emotional Sugg + Emotional Sex):
  Focus: Inferential + Achievement/Mastery
  Suggestions:
    - "You're beginning to recognize your strategic capabilities"
    - "There's a growing awareness of your competence"
    - "You may find you're naturally achieving your goals"
  Habit: Self-directed skill building with mastery reward
  Identity: "I'm uncovering I'm someone who masters challenges"

B-B (Balanced Sugg + Balanced Sex):
  Focus: Hybrid + Integration
  Suggestions:
    - "You excel professionally while maintaining relationships"
    - "Success includes both achievement and connection"
    - "You're whole - capable and connected"
  Habit: Balanced networking + skill development
  Identity: "I am a leader who achieves through authentic connection"

Relationship Goals
yamlRELATIONSHIP GOALS - By E&P Type:

P-P (Physical Sugg + Physical Sex):
  Focus: Direct commands + Deep Connection
  Suggestions:
    - "You ARE open to authentic love"
    - "You DESERVE a partner who values you"
    - "Connection flows naturally when you're yourself"
  Work: Attachment patterns, vulnerability, forward movement

P-E (Physical Sugg + Emotional Sex):
  Focus: Direct commands + Healthy Boundaries
  Suggestions:
    - "You MAINTAIN your autonomy in relationships"
    - "You CHOOSE partners who respect your independence"
    - "Security and connection CAN coexist"
  Work: Withdrawal patterns, balancing independence and intimacy

E-P (Emotional Sugg + Physical Sex):
  Focus: Inferential + Deep Connection
  Suggestions:
    - "You might discover you're worthy of deep love"
    - "There's a tendency for the right people to find you"
    - "You may notice you're becoming more comfortable with intimacy"
  Work: Self-worth, fear of rejection, forward movement

E-E (Emotional Sugg + Emotional Sex):
  Focus: Inferential + Healthy Boundaries
  Suggestions:
    - "You're recognizing you can be close while maintaining yourself"
    - "There's a growing awareness that vulnerability is strength"
    - "You may find you're naturally balancing independence and love"
  Work: Withdrawal patterns, trust, control release

B-P (Balanced Sugg + Physical Sex):
  Focus: Hybrid + Integrated Intimacy
  Suggestions:
    - "You create relationships where both partners are valued"
    - "You're whole - you don't need completion, you choose partnership"
  Work: Interdependence, maintaining self while connecting

B-E (Balanced Sugg + Emotional Sex):
  Focus: Hybrid + Interdependence
  Suggestions:
    - "You build relationships that honor both autonomy and connection"
    - "You're secure enough to be vulnerable"
  Work: Balancing control with intimacy

Health & Wellness Goals
yamlHEALTH & WELLNESS - By E&P Type:

P-P (Physical Sugg + Physical Sex):
  Focus: Direct commands + Social Support
  Suggestions:
    - "You EXERCISE regularly with friends"
    - "You ARE healthy and energized"
    - "Your workout community supports your success"
  Habit: Group fitness, social accountability

P-E (Physical Sugg + Emotional Sex):
  Focus: Direct commands + Personal Mastery
  Suggestions:
    - "You CONTROL your health through disciplined actions"
    - "You ACHIEVE your fitness goals systematically"
    - "Your body IS a testament to your commitment"
  Habit: Solo training, metrics tracking, PR achievements

E-P (Emotional Sugg + Physical Sex):
  Focus: Inferential + Social Support
  Suggestions:
    - "You might notice you're naturally drawn to movement"
    - "There's a tendency to enjoy fitness with others"
    - "You may discover wellness feels better when shared"
  Habit: Gentle group activities, walking with friends

E-E (Emotional Sugg + Emotional Sex):
  Focus: Inferential + Personal Mastery
  Suggestions:
    - "You're discovering you have natural discipline"
    - "There's a growing awareness of your body's capabilities"
    - "You may find you're naturally optimizing your health"
  Habit: Self-directed wellness practice, meditation, yoga

B-B (Balanced Sugg + Balanced Sex):
  Focus: Hybrid + Holistic Wellness
  Suggestions:
    - "You nurture your body, mind, and relationships"
    - "Wellness is your natural state"
    - "You honor all aspects of health"
  Habit: Varied activities balancing solo and social
```

---

## 6.5 Adaptation Decision Tree
```
┌─────────────────────────────────────────────────────────────────┐
│              E&P PERSONALIZATION DECISION TREE                   │
└─────────────────────────────────────────────────────────────────┘

START: User Profile Loaded
│
├─ STEP 1: Determine Suggestibility Type
│  │
│  ├─ [Physical ≥ 60%] → Use Physical Induction Protocol
│  │                    → Direct, literal language
│  │                    → Faster pacing
│  │
│  ├─ [Emotional ≥ 60%] → Use Emotional Induction Protocol
│  │                     → Inferential, permissive language
│  │                     → Slower pacing, long pauses
│  │
│  ├─ [Balanced 40-60%] → Use Hybrid Induction Protocol
│  │                     → Mix direct and indirect
│  │                     → Moderate pacing
│  │
│  └─ [Unclear] → Default to Emotional Protocol (safest)
│                → Observe response, adapt in real-time
│
├─ STEP 2: Determine Sexuality Type
│  │
│  ├─ [Physical ≥ 60%] → Connection-Focused Suggestions
│  │                    → Themes: Belonging, acceptance, relationships
│  │                    → Rewards: Social, emotional
│  │
│  ├─ [Emotional ≥ 60%] → Achievement-Focused Suggestions
│  │                     → Themes: Control, mastery, security
│  │                     → Rewards: Tangible, autonomous
│  │
│  ├─ [Balanced 40-60%] → Integrated Suggestions
│  │                     → Themes: Both connection AND achievement
│  │                     → Rewards: Holistic
│  │
│  └─ [Unclear] → Neutral Protocol
│                → General growth themes
│                → Recommend E&P assessment
│
├─ STEP 3: Apply 10% Adjustment Rule
│  │
│  ├─ [Physical Sugg ≥ 60% AND Emotional Sex ≥ 40%]
│  │   → Add 10% Physical Sexuality themes
│  │   → Increase connection language
│  │
│  ├─ [Emotional Sugg ≥ 60% AND Physical Sex ≥ 40%]
│  │   → Add 10% Emotional Sexuality themes
│  │   → Increase control/mastery language
│  │
│  └─ [No adjustment needed] → Proceed with base profile
│
├─ STEP 4: Map Goal to Sexuality Type
│  │
│  ├─ [Goal: Relationship/Social] → Emphasize connection (P-Sex) or vulnerability (E-Sex)
│  ├─ [Goal: Career/Financial] → Emphasize networking (P-Sex) or mastery (E-Sex)
│  ├─ [Goal: Health/Wellness] → Emphasize group (P-Sex) or solo (E-Sex)
│  └─ [Goal: Personal Growth] → Integrated approach
│
├─ STEP 5: Configure Voice & Pacing
│  │
│  ├─ [P-Sugg] → Confident tone, moderate-fast pace
│  ├─ [E-Sugg] → Gentle tone, slow pace with pauses
│  └─ [Balanced] → Warm authority, moderate pace
│
├─ STEP 6: Select Deepening Techniques
│  │
│  ├─ [P-Sugg + P-Sex] → Progressive relaxation with social imagery
│  ├─ [P-Sugg + E-Sex] → Fractionation with achievement milestones
│  ├─ [E-Sugg + P-Sex] → Safe place with relational warmth
│  ├─ [E-Sugg + E-Sex] → Self-directed journey with mastery themes
│  └─ [Balanced] → Integrated approach
│
└─ STEP 7: Build Habit Loops
   │
   ├─ [P-Sex] → Social rewards, connection-based motivation
   ├─ [E-Sex] → Achievement rewards, self-directed motivation
   └─ [B-Sex] → Both types of rewards

OUTPUT: Complete Personalized Session Configuration

6.6 Real-Time Adaptation Guidelines
yamlDURING SESSION - DYNAMIC ADAPTATION:

Monitor User Responses:
  Physical Signs:
    - Arm raising speed and smoothness
    - Eye movements (REM, stillness)
    - Muscle tension/relaxation
    - Breathing pattern
    
  Verbal Responses:
    - Tone of voice
    - Word choice
    - Response latency
    
  Biometric Data:
    - Heart rate variability
    - Galvanic skin response
    - Stress indicators

Adaptation Triggers:

  IF user shows resistance (tension, slow response):
    AND profile is Physical Sugg:
      → Soften language slightly, add more "you can" phrases
    AND profile is Emotional Sugg:
      → Slow down more, add longer pauses
    
  IF user shows exceptional responsiveness:
    AND profile is Physical Sugg:
      → Can deepen faster, use stronger commands
    AND profile is Emotional Sugg:
      → Can introduce challenge suggestions
    
  IF user shows stress/anxiety:
    AND profile is Physical Sex:
      → Emphasize safety, connection, "you're not alone"
    AND profile is Emotional Sex:
      → Emphasize control, "you're in charge," mastery
    
  IF user shows rapid depth achievement:
    → Proceed to suggestions phase earlier than planned
    → Can do more advanced therapeutic work
    
  IF user plateaus at shallow depth:
    → Extend deepening phase
    → Use additional techniques
    → Consider switching induction style (physical → emotional or vice versa)

Cross-Type Adaptations:

  Physical Sugg showing emotional responsiveness:
    → Begin blending inferential language
    → Note for future: May be more balanced than assessed
    
  Emotional Sugg showing physical responsiveness:
    → Can add more direct suggestions
    → Note for future: May be more balanced than assessed
    
  Physical Sex showing autonomy needs:
    → Add control themes alongside connection
    → May have E-Sex secondary traits
    
  Emotional Sex showing connection needs:
    → Add belonging themes alongside mastery
    → May have P-Sex secondary traits

Session-to-Session Refinement:

  After Session 1:
    - Review actual vs predicted responsiveness
    - Adjust suggestibility classification if needed
    - Note which language patterns worked best
    
  After Session 2-3:
    - Refine sexuality classification
    - Identify dominant themes that resonate
    - Customize voice/pacing further
    
  After Session 5:
    - User profile becomes highly tuned
    - Can do more advanced work
    - Can take creative risks with protocols

6.7 Clinical Notes & Best Practices
yamlGENERAL PRINCIPLES:

1. When In Doubt, Use Emotional/Inferential Protocol:
   - Safest default
   - Creates less resistance
   - Can always add directness later
   - Cannot easily remove directness once given

2. Sexuality Type Matters More for Suggestions:
   - Suggestibility affects HOW you deliver
   - Sexuality affects WHAT you deliver
   - Both are equally important

3. First Session is Exploratory:
   - Assessments may not capture full picture
   - Observe actual responses
   - Be willing to adapt mid-session
   - Take notes for future refinement

4. User Self-Report vs Observed Behavior:
   - Trust observed behavior over questionnaire
   - People don't always know their patterns
   - Real responses during hypnosis reveal truth

5. Cultural Considerations:
   - Some cultures value collective (may skew P-Sex)
   - Some cultures value independence (may skew E-Sex)
   - Adjust for cultural context when interpreting

6. Trauma-Informed Adaptations:
   - Past trauma may create need for more control
   - Even P-Sex users may need E-Sex themes around safety
   - Always honor resistance as protective mechanism

CONTRAINDICATIONS BY TYPE:

P-P (Physical Sugg + Physical Sex):
  Avoid:
    - Isolation or "you're alone" imagery
    - Rejections scenarios
    - Emphasis on self-sufficiency over connection
  
  Caution:
    - Can feel abandoned if therapist presence not emphasized
    - May need more warmth in voice than other types

P-E (Physical Sugg + Emotional Sex):
  Avoid:
    - Loss of control scenarios
    - Dependency language
    - Relationship obligations
  
  Caution:
    - Can resist if suggestions feel unrealistic
    - Needs logical pathway to goals

E-P (Emotional Sugg + Physical Sex):
  Avoid:
    - Direct commands (creates resistance)
    - Rushing the process
    - Isolation themes
  
  Caution:
    - Needs more time to process
    - May need multiple sessions to achieve depth

E-E (Emotional Sugg + Emotional Sex):
  Avoid:
    - Direct commands
    - Pushing vulnerability too fast
    - Dependency language
  
  Caution:
    - Highly analytical, may struggle to "let go"
    - Frame hypnosis as skill mastery to reduce resistance

ETHICAL CONSIDERATIONS:

1. Never Exploit Sexuality Type:
   - P-Sex's need for connection ≠ dependency on therapist
   - E-Sex's need for control ≠ encouraging isolation
   - Use knowledge to empower, not manipulate

2. Respect Boundaries:
   - Some may not want relationship-focused work
   - Some may not want achievement pressure
   - Always ask about goals first

3. Avoid Stereotyping:
   - E&P are patterns, not rigid boxes
   - People are complex and multifaceted
   - Hold classifications lightly

4. Informed Consent:
   - Explain E&P framework to clients
   - Let them know how it informs personalization
   - Allow them to disagree with assessments

This completes Part 6: Personalization Matrix!
Summary of what we've covered:

✅ Part 1: System Architecture (C4 models, component architecture)
✅ Part 2: Data Models & Schemas (Pydantic, PostgreSQL, Neo4j)
✅ Part 3: Sequence Diagrams (First session, real-time adaptation, multi-agent, safety escalation)
✅ Part 4: State Machines (Session orchestration, assessment flow, agent collaboration, user journey, safety monitoring)
✅ Part 5: Message Flow & Communication Protocols (WebSocket events, REST APIs, Agent messages, MCP calls)
✅ Part 6: Personalization Matrix (All 16 E&P combinations, language patterns, goal adaptations, decision trees)

Would you like me to:

Create implementation code snippets for key components?
Generate test cases for each E&P combination?
Build a deployment architecture diagram?
Design a monitoring & observability strategy?
Create user documentation for therapists using the system?

Let me know what you'd like to tackle next! 

Complete Frontend Architecture: Epics, Stories & Tasks

📋 Frontend Epic Summary
EPIC 4: Core Assessment & Interactive UI (Web)
EPIC 5: Immersive XR Experience (WebXR)
EPIC 6: Therapist Dashboard & Analytics
EPIC 7: Session Delivery & Real-Time Experience
EPIC 8: Advanced Features & Optimization

🎪 EPIC 4: Core Assessment & Interactive UI (Web)
Business Value: Enable users to complete assessments and access core platform features via web browsers
Timeline: Sprints 3-5 (6 weeks)
Priority: P0 (Critical Path - Foundation for all web features)
Team: 3 Frontend Engineers, 1 UX Designer

📖 Story 4.1: React Application Foundation with FastAPI Integration
Story:
"As a platform architect, I want a robust React application shell with full FastAPI integration, state management, and routing, so that all frontend features can be built on a solid, scalable foundation."
Priority: P0 (Must Have - Sprint 3, Week 1)
Story Points: 13
Dependencies: Backend API endpoints ready
Acceptance Criteria:

✅ React 18+ with TypeScript and Vite bundler configured
✅ TailwindCSS 3+ integrated with custom HMI design tokens
✅ FastAPI client SDK with interceptors, auth, error handling
✅ WebSocket service with auto-reconnect and message queueing
✅ Zustand state management with persistence
✅ React Router v6+ with protected routes and lazy loading
✅ Authentication flow (login, signup, token refresh, logout)
✅ Error boundaries at app and route levels
✅ Loading states and skeleton screens
✅ PWA configuration with offline support
✅ Accessibility: WCAG 2.1 AA compliance foundation
✅ Performance: Lighthouse score 90+ (desktop), 80+ (mobile)
✅ Environment configuration (.env handling for dev/staging/prod)
✅ Hot module replacement (HMR) working in development


🔧 Tasks for Story 4.1:
Task 4.1.1: Project Initialization & Build Setup

Assigned To: Frontend Lead
Estimated Hours: 6h
Deliverables:

bash# Initialize project
npm create vite@latest hmi-hypnotherapy-web -- --template react-ts

# Install core dependencies
npm install react@18 react-dom@18 react-router-dom@6
npm install @tanstack/react-query zustand
npm install axios
npm install tailwindcss postcss autoprefixer
npm install -D typescript @types/react @types/react-dom

# Initialize Tailwind
npx tailwindcss init -p
```

**File Structure**:
```
src/
├── app/
│   ├── App.tsx
│   ├── Router.tsx
│   └── providers/
│       ├── AuthProvider.tsx
│       ├── QueryProvider.tsx
│       └── ThemeProvider.tsx
├── features/
│   ├── auth/
│   ├── assessment/
│   ├── session/
│   └── profile/
├── shared/
│   ├── components/
│   ├── hooks/
│   ├── utils/
│   └── types/
├── config/
│   ├── api.config.ts
│   ├── routes.config.ts
│   └── env.config.ts
└── styles/
    ├── globals.css
    └── tokens.css
Task 4.1.2: TailwindCSS Configuration with HMI Design Tokens

Assigned To: Frontend Team + UX Designer
Estimated Hours: 8h
Deliverables:

typescript// tailwind.config.js
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        // HMI Brand Colors
        primary: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
        },
        // Therapy-specific colors
        calm: {
          50: '#f0fdf4',
          100: '#dcfce7',
          500: '#22c55e',
        },
        focus: {
          50: '#fef3c7',
          500: '#f59e0b',
        },
        depth: {
          50: '#f5f3ff',
          500: '#8b5cf6',
          700: '#6d28d9',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        display: ['Montserrat', 'sans-serif'],
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
      },
      animation: {
        'fade-in': 'fadeIn 0.3s ease-in',
        'slide-up': 'slideUp 0.4s ease-out',
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}
Task 4.1.3: FastAPI Client SDK

Assigned To: Frontend Team
Estimated Hours: 10h
Deliverables:

typescript// src/shared/api/client.ts
import axios, { AxiosInstance, AxiosRequestConfig } from 'axios';
import { getAuthToken, refreshAuthToken, clearAuth } from '@/features/auth/auth.store';

class APIClient {
  private client: AxiosInstance;
  private isRefreshing = false;
  private failedQueue: Array<{
    resolve: (value?: any) => void;
    reject: (reason?: any) => void;
  }> = [];

  constructor() {
    this.client = axios.create({
      baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api/v1',
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.setupInterceptors();
  }

  private setupInterceptors() {
    // Request interceptor - Add auth token
    this.client.interceptors.request.use(
      (config) => {
        const token = getAuthToken();
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Response interceptor - Handle errors and token refresh
    this.client.interceptors.response.use(
      (response) => response,
      async (error) => {
        const originalRequest = error.config;

        // If 401 and not already retrying
        if (error.response?.status === 401 && !originalRequest._retry) {
          if (this.isRefreshing) {
            // Queue request while refresh is happening
            return new Promise((resolve, reject) => {
              this.failedQueue.push({ resolve, reject });
            })
              .then((token) => {
                originalRequest.headers.Authorization = `Bearer ${token}`;
                return this.client(originalRequest);
              })
              .catch((err) => Promise.reject(err));
          }

          originalRequest._retry = true;
          this.isRefreshing = true;

          try {
            const newToken = await refreshAuthToken();
            this.isRefreshing = false;
            this.processQueue(null, newToken);
            originalRequest.headers.Authorization = `Bearer ${newToken}`;
            return this.client(originalRequest);
          } catch (refreshError) {
            this.isRefreshing = false;
            this.processQueue(refreshError, null);
            clearAuth();
            window.location.href = '/login';
            return Promise.reject(refreshError);
          }
        }

        return Promise.reject(error);
      }
    );
  }

  private processQueue(error: any, token: string | null = null) {
    this.failedQueue.forEach((prom) => {
      if (error) {
        prom.reject(error);
      } else {
        prom.resolve(token);
      }
    });
    this.failedQueue = [];
  }

  // API Methods
  async get<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.get<T>(url, config);
    return response.data;
  }

  async post<T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.post<T>(url, data, config);
    return response.data;
  }

  async put<T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.put<T>(url, data, config);
    return response.data;
  }

  async patch<T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.patch<T>(url, data, config);
    return response.data;
  }

  async delete<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.delete<T>(url, config);
    return response.data;
  }
}

export const apiClient = new APIClient();

// Type-safe API endpoints
export const endpoints = {
  auth: {
    login: '/auth/login',
    register: '/auth/register',
    refresh: '/auth/refresh',
    logout: '/auth/logout',
  },
  users: {
    profile: (userId: string) => `/users/${userId}/profile`,
    unifiedProfile: (userId: string) => `/users/${userId}/unified-profile`,
  },
  assessments: {
    suggestibility: {
      start: '/assessments/suggestibility/start',
      response: (assessmentId: string) => `/assessments/suggestibility/${assessmentId}/response`,
      complete: (assessmentId: string) => `/assessments/suggestibility/${assessmentId}/complete`,
    },
    sexuality: {
      start: '/assessments/sexuality/start',
      familyTree: (assessmentId: string) => `/assessments/sexuality/${assessmentId}/family-tree`,
      relationships: (assessmentId: string) => `/assessments/sexuality/${assessmentId}/relationship-inventory`,
      complete: (assessmentId: string) => `/assessments/sexuality/${assessmentId}/complete`,
    },
    wheelOfHappiness: '/assessments/wheel-of-happiness',
  },
  sessions: {
    create: '/sessions/create',
    start: (sessionId: string) => `/sessions/${sessionId}/start`,
    get: (sessionId: string) => `/sessions/${sessionId}`,
    complete: (sessionId: string) => `/sessions/${sessionId}/complete`,
    list: (userId: string) => `/users/${userId}/sessions`,
  },
} as const;
Task 4.1.4: WebSocket Service

Assigned To: Frontend Team
Estimated Hours: 8h
Deliverables:

typescript// src/shared/services/websocket.service.ts
import { useEffect, useRef, useCallback } from 'react';
import { create } from 'zustand';

type WebSocketMessage = {
  event: string;
  timestamp: string;
  session_id?: string;
  data: any;
};

type WebSocketState = {
  isConnected: boolean;
  lastMessage: WebSocketMessage | null;
  error: Error | null;
  connect: (url: string) => void;
  disconnect: () => void;
  sendMessage: (message: any) => void;
};

export const useWebSocketStore = create<WebSocketState>((set, get) => ({
  isConnected: false,
  lastMessage: null,
  error: null,
  connect: (url: string) => {
    // Implementation in Task 4.1.4
  },
  disconnect: () => {
    // Implementation in Task 4.1.4
  },
  sendMessage: (message: any) => {
    // Implementation in Task 4.1.4
  },
}));

export class WebSocketService {
  private ws: WebSocket | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private reconnectDelay = 1000;
  private messageQueue: any[] = [];
  private heartbeatInterval: NodeJS.Timeout | null = null;

  constructor(private url: string) {}

  connect(onMessage: (message: WebSocketMessage) => void) {
    try {
      this.ws = new WebSocket(this.url);

      this.ws.onopen = () => {
        console.log('WebSocket connected');
        this.reconnectAttempts = 0;
        this.startHeartbeat();
        this.flushMessageQueue();
      };

      this.ws.onmessage = (event) => {
        try {
          const message = JSON.parse(event.data);
          onMessage(message);
        } catch (error) {
          console.error('Failed to parse WebSocket message:', error);
        }
      };

      this.ws.onerror = (error) => {
        console.error('WebSocket error:', error);
      };

      this.ws.onclose = () => {
        console.log('WebSocket disconnected');
        this.stopHeartbeat();
        this.attemptReconnect(onMessage);
      };
    } catch (error) {
      console.error('Failed to create WebSocket:', error);
    }
  }

  private startHeartbeat() {
    this.heartbeatInterval = setInterval(() => {
      if (this.ws?.readyState === WebSocket.OPEN) {
        this.send({ type: 'ping' });
      }
    }, 30000); // 30 seconds
  }

  private stopHeartbeat() {
    if (this.heartbeatInterval) {
      clearInterval(this.heartbeatInterval);
      this.heartbeatInterval = null;
    }
  }

  private attemptReconnect(onMessage: (message: WebSocketMessage) => void) {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      const delay = this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1);
      console.log(`Reconnecting in ${delay}ms (attempt ${this.reconnectAttempts}/${this.maxReconnectAttempts})`);
      setTimeout(() => this.connect(onMessage), delay);
    } else {
      console.error('Max reconnection attempts reached');
    }
  }

  send(message: any) {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(message));
    } else {
      // Queue message for later
      this.messageQueue.push(message);
    }
  }

  private flushMessageQueue() {
    while (this.messageQueue.length > 0) {
      const message = this.messageQueue.shift();
      this.send(message);
    }
  }

  disconnect() {
    this.stopHeartbeat();
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
  }
}

// React Hook for WebSocket
export function useWebSocket(url: string, onMessage: (message: WebSocketMessage) => void) {
  const wsRef = useRef<WebSocketService | null>(null);

  useEffect(() => {
    wsRef.current = new WebSocketService(url);
    wsRef.current.connect(onMessage);

    return () => {
      wsRef.current?.disconnect();
    };
  }, [url]);

  const sendMessage = useCallback((message: any) => {
    wsRef.current?.send(message);
  }, []);

  return { sendMessage };
}
Task 4.1.5: State Management with Zustand

Assigned To: Frontend Team
Estimated Hours: 8h
Deliverables:

typescript// src/features/auth/auth.store.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

type User = {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: string;
};

type AuthState = {
  user: User | null;
  accessToken: string | null;
  refreshToken: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
  
  // Actions
  setAuth: (user: User, accessToken: string, refreshToken: string) => void;
  clearAuth: () => void;
  setUser: (user: User) => void;
  setLoading: (isLoading: boolean) => void;
  setError: (error: string | null) => void;
};

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      accessToken: null,
      refreshToken: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,

      setAuth: (user, accessToken, refreshToken) => 
        set({ 
          user, 
          accessToken, 
          refreshToken, 
          isAuthenticated: true,
          error: null 
        }),

      clearAuth: () => 
        set({ 
          user: null, 
          accessToken: null, 
          refreshToken: null, 
          isAuthenticated: false 
        }),

      setUser: (user) => set({ user }),
      setLoading: (isLoading) => set({ isLoading }),
      setError: (error) => set({ error }),
    }),
    {
      name: 'hmi-auth-storage',
      partialize: (state) => ({
        accessToken: state.accessToken,
        refreshToken: state.refreshToken,
        user: state.user,
      }),
    }
  )
);

// Utility functions for use in API client
export const getAuthToken = () => useAuthStore.getState().accessToken;
export const refreshAuthToken = async () => {
  // Call refresh endpoint, update tokens
  // Implementation details...
};
export const clearAuth = () => useAuthStore.getState().clearAuth();
typescript// src/features/session/session.store.ts
import { create } from 'zustand';

type SessionPhase = 'intake' | 'pre_induction' | 'induction' | 'deepening' | 'suggestions' | 'emergence';
type SessionState = 'idle' | 'planned' | 'in_progress' | 'paused' | 'completed';

type SessionStore = {
  sessionId: string | null;
  state: SessionState;
  currentPhase: SessionPhase | null;
  isConnected: boolean;
  
  // Actions
  initializeSession: (sessionId: string) => void;
  updateState: (state: SessionState) => void;
  updatePhase: (phase: SessionPhase) => void;
  setConnected: (isConnected: boolean) => void;
  reset: () => void;
};

export const useSessionStore = create<SessionStore>((set) => ({
  sessionId: null,
  state: 'idle',
  currentPhase: null,
  isConnected: false,

  initializeSession: (sessionId) => set({ sessionId, state: 'planned' }),
  updateState: (state) => set({ state }),
  updatePhase: (phase) => set({ currentPhase: phase }),
  setConnected: (isConnected) => set({ isConnected }),
  reset: () => set({ 
    sessionId: null, 
    state: 'idle', 
    currentPhase: null, 
    isConnected: false 
  }),
}));
Task 4.1.6: Routing Configuration

Assigned To: Frontend Team
Estimated Hours: 6h
Deliverables:

typescript// src/app/Router.tsx
import { lazy, Suspense } from 'react';
import { createBrowserRouter, RouterProvider, Navigate } from 'react-router-dom';
import { useAuthStore } from '@/features/auth/auth.store';
import { LoadingSpinner } from '@/shared/components/LoadingSpinner';

// Lazy load routes for code splitting
const LandingPage = lazy(() => import('@/features/landing/LandingPage'));
const LoginPage = lazy(() => import('@/features/auth/LoginPage'));
const SignupPage = lazy(() => import('@/features/auth/SignupPage'));
const DashboardLayout = lazy(() => import('@/features/dashboard/DashboardLayout'));
const DashboardHome = lazy(() => import('@/features/dashboard/DashboardHome'));
const AssessmentFlow = lazy(() => import('@/features/assessment/AssessmentFlow'));
const SessionView = lazy(() => import('@/features/session/SessionView'));
const ProfilePage = lazy(() => import('@/features/profile/ProfilePage'));
const SessionHistory = lazy(() => import('@/features/session/SessionHistory'));

// Protected Route wrapper
function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated);
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  return <>{children}</>;
}

// Public Route wrapper (redirects to dashboard if already authenticated)
function PublicRoute({ children }: { children: React.ReactNode }) {
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated);
  
  if (isAuthenticated) {
    return <Navigate to="/dashboard" replace />;
  }
  
  return <>{children}</>;
}

const router = createBrowserRouter([
  {
    path: '/',
    element: <LandingPage />,
  },
  {
    path: '/login',
    element: (
      <PublicRoute>
        <LoginPage />
      </PublicRoute>
    ),
  },
  {
    path: '/signup',
    element: (
      <PublicRoute>
        <SignupPage />
      </PublicRoute>
    ),
  },
  {
    path: '/dashboard',
    element: (
      <ProtectedRoute>
        <DashboardLayout />
      </ProtectedRoute>
    ),
    children: [
      {
        index: true,
        element: <DashboardHome />,
      },
      {
        path: 'assessment',
        element: <AssessmentFlow />,
      },
      {
        path: 'session/:sessionId',
        element: <SessionView />,
      },
      {
        path: 'history',
        element: <SessionHistory />,
      },
      {
        path: 'profile',
        element: <ProfilePage />,
      },
    ],
  },
  {
    path: '*',
    element: <Navigate to="/" replace />,
  },
]);

export function AppRouter() {
  return (
    <Suspense fallback={<LoadingSpinner fullScreen />}>
      <RouterProvider router={router} />
    </Suspense>
  );
}
Task 4.1.7: Authentication Flow Implementation

Assigned To: Full Stack Team
Estimated Hours: 12h
Deliverables: Login, Signup, Token Refresh, Logout components and hooks

Task 4.1.8: Error Boundaries & Loading States

Assigned To: Frontend Team
Estimated Hours: 6h
Deliverables:

typescript// src/shared/components/ErrorBoundary.tsx
import { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
    // Send to error tracking service (Sentry, etc.)
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div className="flex min-h-screen items-center justify-center bg-gray-50">
          <div className="rounded-lg bg-white p-8 shadow-lg">
            <h2 className="mb-4 text-2xl font-bold text-red-600">
              Something went wrong
            </h2>
            <p className="mb-4 text-gray-600">
              {this.state.error?.message || 'An unexpected error occurred'}
            </p>
            <button
              onClick={() => window.location.reload()}
              className="rounded bg-primary-600 px-4 py-2 text-white hover:bg-primary-700"
            >
              Reload Page
            </button>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}
Task 4.1.9: PWA Configuration

Assigned To: Frontend Team
Estimated Hours: 8h
Deliverables: Service worker, manifest.json, offline support

Task 4.1.10: Accessibility Foundation

Assigned To: Frontend Team + Accessibility Specialist
Estimated Hours: 12h
Deliverables: Focus management, ARIA labels, keyboard navigation patterns

Task 4.1.11: Performance Optimization

Assigned To: Frontend Team
Estimated Hours: 8h
Deliverables: Code splitting, image optimization, Lighthouse audit passing


📖 Story 4.2: Interactive Questionnaire System with Helper Panels
Story:
"As a user completing an assessment, I want an engaging, intuitive questionnaire interface with contextual help and examples, so that I understand each question and can provide accurate responses without confusion."
Priority: P0 (Must Have - Sprint 3, Week 2-3)
Story Points: 21
Dependencies: Story 4.1 (React foundation)
Acceptance Criteria:

✅ Displays one question at a time with smooth transitions (300ms fade)
✅ Supports 4 input types: scale slider (0-10), Likert chips, multiple choice, free text
✅ Helper Panel with "?" button showing:

"Why I'm being asked this" explanation
3 example answers (low/medium/high intensity)
Gentle guidance text


✅ Progress indicator (X of Y questions, percentage bar)
✅ Navigation: Next, Back, Skip buttons with appropriate states
✅ Auto-save progress every 30 seconds and on navigation
✅ Validation with friendly inline error messages
✅ Keyboard navigation (Tab, Enter, Arrow keys)
✅ Screen reader announcements for state changes
✅ Mobile-optimized touch targets (44px minimum)
✅ Responsive design (320px mobile to 4K desktop)
✅ Average completion time per question: 30-45 seconds (via analytics)


🔧 Tasks for Story 4.2:
Task 4.2.1: Generate Question JSON Schema with GenAI

Assigned To: Backend + Frontend Team
Estimated Hours: 4h
GenAI Prompt: Use Prompt 3 from document

typescript// Prompt to use:
/*
Design a JSON schema for a therapeutic questionnaire item that will be rendered in a VR/WebXR experience.
Each item must support:
– id, category, question_text, time_frame_hint
– input_type (scale, multiple_choice, free_text)
– For scale: min, max, labels, default
– For multiple_choice: list of options with labels
– helper:
  • why_asking: one sentence
  • examples: list of 3 entries
    – each with range_or_option, example_answer, guidance_text

Output:
The JSON Schema (informal is fine)

3 concrete question objects:
– Q1: "Right now, how high is your anxiety?" (0–10 scale)
– Q2: "In the last week, how often have you had trouble sleeping?" (5-option multiple choice)
– Q3: "What's one situation that has been especially stressful lately?" (free text with helper examples).
*/
Deliverable:
typescript// src/shared/types/question.types.ts
export type InputType = 'scale' | 'multiple_choice' | 'likert' | 'free_text';

export type HelperExample = {
  range_or_option: string;
  example_answer: string;
  guidance_text: string;
};

export type HelperPanel = {
  why_asking: string;
  examples: HelperExample[];
};

export type Question = {
  id: string;
  category: string;
  question_text: string;
  time_frame_hint?: string;
  input_type: InputType;
  
  // For scale
  scale_min?: number;
  scale_max?: number;
  scale_labels?: Record<number, string>;
  scale_default?: number;
  
  // For multiple choice / Likert
  options?: string[];
  
  // Helper text
  helper?: HelperPanel;
  
  // Metadata
  required: boolean;
  weight: number;
};

// Example question objects (generated by GenAI):
export const exampleQuestions: Question[] = [
  {
    id: 'q1_anxiety_current',
    category: 'suggestibility',
    question_text: 'Right now, how high is your anxiety?',
    time_frame_hint: 'Right now',
    input_type: 'scale',
    scale_min: 0,
    scale_max: 10,
    scale_labels: {
      0: 'No anxiety',
      5: 'Moderate',
      10: 'Extreme anxiety',
    },
    scale_default: 5,
    helper: {
      why_asking: 'This helps us understand your current emotional state and tailor the session appropriately.',
      examples: [
        {
          range_or_option: '0-3',
          example_answer: 'I feel calm and relaxed',
          guidance_text: 'Low anxiety means you\'re feeling relatively at ease. This is a great state for hypnotherapy.',
        },
        {
          range_or_option: '4-7',
          example_answer: 'I notice some tension but I\'m managing',
          guidance_text: 'Moderate anxiety is very common. We\'ll work together to help you feel more at ease.',
        },
        {
          range_or_option: '8-10',
          example_answer: 'I feel overwhelmed and very tense',
          guidance_text: 'High anxiety is challenging. We\'ll start with calming techniques before deeper work.',
        },
      ],
    },
    required: true,
    weight: 5,
  },
  // Q2 and Q3...
];
Task 4.2.2: Design Figma Components

Assigned To: UX Designer
Estimated Hours: 12h
GenAI Prompt: Use Prompt 2 from document
Deliverables:

Question Card component (all variants)
Helper Panel component
Input components (slider, chips, radio, textarea)
Progress indicator
Navigation buttons
Color tokens and spacing system



Task 4.2.3: Build QuestionCard Component

Assigned To: Frontend Team
Estimated Hours: 16h
Deliverables:

typescript// src/features/assessment/components/QuestionCard.tsx
import { useState } from 'react';
import { Question } from '@/shared/types/question.types';
import { ScaleInput } from './inputs/ScaleInput';
import { LikertInput } from './inputs/LikertInput';
import { MultipleChoiceInput } from './inputs/MultipleChoiceInput';
import { FreeTextInput } from './inputs/FreeTextInput';
import { HelperPanel } from './HelperPanel';
import { HelpCircle } from 'lucide-react';

type QuestionCardProps = {
  question: Question;
  value: any;
  onChange: (value: any) => void;
  onNext: () => void;
  onBack: () => void;
  onSkip: () => void;
  canGoBack: boolean;
  canSkip: boolean;
  progress: { current: number; total: number };
};

export function QuestionCard({
  question,
  value,
  onChange,
  onNext,
  onBack,
  onSkip,
  canGoBack,
  canSkip,
  progress,
}: QuestionCardProps) {
  const [showHelper, setShowHelper] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleNext = () => {
    if (question.required && !value) {
      setError('This question is required');
      return;
    }
    setError(null);
    onNext();
  };

  const renderInput = () => {
    switch (question.input_type) {
      case 'scale':
        return (
          <ScaleInput
            min={question.scale_min!}
            max={question.scale_max!}
            labels={question.scale_labels}
            value={value}
            onChange={onChange}
          />
        );
      case 'likert':
        return (
          <LikertInput
            options={question.options!}
            value={value}
            onChange={onChange}
          />
        );
      case 'multiple_choice':
        return (
          <MultipleChoiceInput
            options={question.options!}
            value={value}
            onChange={onChange}
          />
        );
      case 'free_text':
        return (
          <FreeTextInput
            value={value}
            onChange={onChange}
            placeholder="Type your answer here..."
          />
        );
      default:
        return null;
    }
  };

  return (
    <div className="relative mx-auto max-w-3xl animate-fade-in">
      {/* Progress Bar */}
      <div className="mb-8">
        <div className="mb-2 flex items-center justify-between text-sm text-gray-600">
          <span>Question {progress.current} of {progress.total}</span>
          <span>{Math.round((progress.current / progress.total) * 100)}%</span>
        </div>
        <div className="h-2 w-full overflow-hidden rounded-full bg-gray-200">
          <div
            className="h-full bg-primary-500 transition-all duration-300 ease-out"
            style={{ width: `${(progress.current / progress.total) * 100}%` }}
          />
        </div>
      </div>

      {/* Question Card */}
      <div className="rounded-2xl bg-white p-8 shadow-lg">
        {/* Header */}
        <div className="mb-6">
          <div className="mb-2 flex items-start justify-between">
            <h2 className="text-2xl font-semibold text-gray-900">
              {question.question_text}
            </h2>
            {question.helper && (
              <button
                onClick={() => setShowHelper(!showHelper)}
                className="ml-4 rounded-full p-2 text-gray-400 hover:bg-gray-100 hover:text-primary-600 transition-colors"
                aria-label="Show help"
              >
                <HelpCircle className="h-6 w-6" />
              </button>
            )}
          </div>
          {question.time_frame_hint && (
            <p className="text-sm text-gray-500">{question.time_frame_hint}</p>
          )}
        </div>

        {/* Input */}
        <div className="mb-6">{renderInput()}</div>

        {/* Error Message */}
        {error && (
          <div className="mb-4 rounded-lg bg-red-50 p-3 text-sm text-red-600">
            {error}
          </div>
        )}

        {/* Navigation */}
        <div className="flex items-center justify-between gap-4">
          <button
            onClick={onBack}
            disabled={!canGoBack}
            className="rounded-lg px-6 py-3 font-medium text-gray-600 hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            Back
          </button>
          <div className="flex gap-3">
            {canSkip && (
              <button
                onClick={onSkip}
                className="rounded-lg px-6 py-3 font-medium text-gray-600 hover:bg-gray-100 transition-colors"
              >
                Skip
              </button>
            )}
            <button
              onClick={handleNext}
              className="rounded-lg bg-primary-600 px-8 py-3 font-medium text-white hover:bg-primary-700 transition-colors"
            >
              Next
            </button>
          </div>
        </div>
      </div>

      {/* Helper Panel */}
      {showHelper && question.helper && (
        <HelperPanel
          helper={question.helper}
          onClose={() => setShowHelper(false)}
        />
      )}
    </div>
  );
}
Task 4.2.4: Build HelperPanel Component

Assigned To: Frontend Team
Estimated Hours: 8h

typescript// src/features/assessment/components/HelperPanel.tsx
import { HelperPanel as HelperPanelType } from '@/shared/types/question.types';
import { X, Lightbulb } from 'lucide-react';

type HelperPanelProps = {
  helper: HelperPanelType;
  onClose: () => void;
};

export function HelperPanel({ helper, onClose }: HelperPanelProps) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 p-4 animate-fade-in">
      <div className="max-w-2xl max-h-[90vh] overflow-y-auto rounded-2xl bg-white p-8 shadow-2xl animate-slide-up">
        {/* Header */}
        <div className="mb-6 flex items-start justify-between">
          <div className="flex items-center gap-3">
            <div className="rounded-full bg-primary-100 p-2">
              <Lightbulb className="h-6 w-6 text-primary-600" />
            </div>
            <h3 className="text-xl font-semibold text-gray-900">
              Understanding this question
            </h3>
          </div>
          <button
            onClick={onClose}
            className="rounded-full p-2 text-gray-400 hover:bg-gray-100 hover:text-gray-600 transition-colors"
            aria-label="Close help"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Why Asking */}
        <div className="mb-6">
          <h4 className="mb-2 text-sm font-medium uppercase tracking-wide text-gray-500">
            Why we're asking
          </h4>
          <p className="text-gray-700">{helper.why_asking}</p>
        </div>

        {/* Examples */}
        <div>
          <h4 className="mb-4 text-sm font-medium uppercase tracking-wide text-gray-500">
            Example responses
          </h4>
          <div className="space-y-4">
            {helper.examples.map((example, index) => (
              <div
                key={index}
                className="rounded-lg border border-gray-200 bg-gray-50 p-4"
              >
                <div className="mb-2 flex items-center justify-between">
                  <span className="text-sm font-medium text-primary-600">
                    {example.range_or_option}
                  </span>
                  <span className="text-xs text-gray-500">
                    Example {index + 1}
                  </span>
                </div>
                <p className="mb-2 text-gray-900 italic">
                  "{example.example_answer}"
                </p>
                <p className="text-sm text-gray-600">
                  {example.guidance_text}
                </p>
              </div>
            ))}
          </div>
        </div>

        {/* Close Button */}
        <div className="mt-6 flex justify-end">
          <button
            onClick={onClose}
            className="rounded-lg bg-primary-600 px-6 py-3 font-medium text-white hover:bg-primary-700 transition-colors"
          >
            Got it
          </button>
        </div>
      </div>
    </div>
  );
}
Task 4.2.5: Build Input Components

Assigned To: Frontend Team
Estimated Hours: 20h
Deliverables:

ScaleInput (0-10 slider with labels and live value)
LikertInput (5-option chips with visual states)
MultipleChoiceInput (radio buttons with descriptions)
FreeTextInput (textarea with character count)



Task 4.2.6: Implement Auto-Save

Assigned To: Frontend Team
Estimated Hours: 6h

typescript// src/features/assessment/hooks/useAutoSave.ts
import { useEffect, useRef } from 'react';
import { useDebouncedCallback } from 'use-debounce';

export function useAutoSave(
  data: any,
  saveFunction: (data: any) => Promise<void>,
  delay = 30000 // 30 seconds
) {
  const previousData = useRef(data);

  const debouncedSave = useDebouncedCallback(
    async (dataToSave: any) => {
      try {
        await saveFunction(dataToSave);
        console.log('Auto-saved successfully');
      } catch (error) {
        console.error('Auto-save failed:', error);
      }
    },
    delay
  );

  useEffect(() => {
    // Only save if data has actually changed
    if (JSON.stringify(data) !== JSON.stringify(previousData.current)) {
      debouncedSave(data);
      previousData.current = data;
    }
  }, [data, debouncedSave]);

  // Save immediately on unmount
  useEffect(() => {
    return () => {
      if (JSON.stringify(data) !== JSON.stringify(previousData.current)) {
        saveFunction(data);
      }
    };
  }, [data, saveFunction]);
}
Task 4.2.7: Add Validation & Error States

Assigned To: Frontend Team
Estimated Hours: 6h

Task 4.2.8: Implement Accessibility

Assigned To: Frontend Team + Accessibility Specialist
Estimated Hours: 10h
Deliverables:

Keyboard navigation (Tab, Enter, Arrow keys)
ARIA labels and live regions
Focus management
Screen reader testing



Task 4.2.9: Mobile Touch Optimization

Assigned To: Frontend Team
Estimated Hours: 8h
Deliverables:

Touch-friendly targets (44px minimum)
Swipe gestures for navigation
Haptic feedback (if supported)



Task 4.2.10: User Testing & Iteration

Assigned To: UX Researcher + Frontend Team
Estimated Hours: 16h
Deliverables:

20 user tests
Comprehension testing
Iteration based on feedback
Analytics implementation




Due to length constraints, let me provide a condensed version of the remaining stories with key details:

📖 Story 4.3: Wheel of Happiness Interactive Component
Priority: P0 | Story Points: 13 | Sprint: 3, Week 4
Key Tasks:

Design interactive SVG wheel (8 segments)
Implement click/drag rating interaction
Add color coding (red 1-4, yellow 5-7, green 8-10)
Calculate bumpiness score and suggest priorities
Build animations (fill effect, smooth transitions)
Add keyboard accessibility
Integrate with backend API


📖 Story 4.4: Family Tree & Relationship Inventory UI
Priority: P1 | Story Points: 21 | Sprint: 4
Key Tasks:

Build drag-and-drop family tree builder
Implement relationship inventory form (multi-step)
Create visual relationship timeline
Add trait selection UI for family members
Build pursuit dynamics selector
Implement data validation
Integrate with E&P assessment API


📖 Story 4.5: GenAI Question Bank Generator (Admin Tool)
Priority: P2 | Story Points: 13 | Sprint: 5
Key Tasks:

Build admin interface for question generation
Integrate Custom Hypnosis LLM
Implement Prompt 6 template from document
Build content review interface
Add language validation (Flesch-Kincaid)
Implement safety content filter
Add version control and audit logging


Would you like me to continue with:

EPIC 5: Immersive XR Experience (WebXR with React Three Fiber)
EPIC 6: Therapist Dashboard (Recharts visualizations, real-time updates)
EPIC 7: Session Delivery Experience (Audio player, biometric display, real-time adaptation)

Let me know which epic to detail next! 🚀RetryJSEpic 5Architected comprehensive WebXR experience framework with immersive interactions.The user wants me to detail EPIC 5: Immersive XR Experience (WebXR with React Three Fiber). Based on the document provided and the comprehensive architecture we've built, I need to create detailed stories and tasks for building the WebXR immersive experience.
Key components from the document:

React Three Fiber + @react-three/xr for 3D/XR scene
Calming virtual environments
Floating question cards in 3D
Hand controllers, hand tracking, and gaze interaction
Helper panels in 3D space
Performance targets (72fps Quest 2, 90fps Quest 3)
Accessibility settings
GenAI prompts for scene design

I should create stories for:

WebXR infrastructure setup
3D environment creation
3D question card system
Interaction methods (controllers, hand tracking, gaze)
3D helper panels
Performance optimization
Accessibility features
Fallback to 2D UI

Let me structure this comprehensively with detailed tasks, code examples, and technical specifications.🥽 EPIC 5: Immersive XR Experience (WebXR)
Business Value: Provide premium immersive assessment and session experience in VR/AR, differentiating from competitors and improving engagement
Timeline: Sprints 4-6 (6 weeks)
Priority: P1 (Should Have - Premium feature)
Team: 2 Frontend Engineers (XR specialists), 1 3D Artist, 1 UX Designer

Epic Overview
┌─────────────────────────────────────────────────────────────────┐
│               WEBXR IMMERSIVE EXPERIENCE STACK                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  VR/AR Devices                                                   │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐               │
│  │ Meta Quest │  │ Vision Pro │  │   Desktop  │               │
│  │  2, 3, Pro │  │            │  │ VR (PCVR)  │               │
│  └──────┬─────┘  └──────┬─────┘  └──────┬─────┘               │
│         │                │                │                      │
│         └────────────────┴────────────────┘                      │
│                          │                                       │
│                  WebXR API (Browser)                             │
│                          │                                       │
│         ┌────────────────┴────────────────┐                     │
│         │                                  │                     │
│  ┌──────▼───────┐              ┌──────────▼────────┐           │
│  │ @react-three │              │  @react-three/xr  │           │
│  │    /fiber    │              │                   │           │
│  │ (Three.js)   │              │  - VR session     │           │
│  └──────┬───────┘              │  - Controllers    │           │
│         │                      │  - Hand tracking  │           │
│         │                      │  - Gaze input     │           │
│         │                      └──────────┬────────┘           │
│         │                                 │                     │
│    ┌────▼─────────────────────────────────▼────┐              │
│    │      React Components (3D Space)          │              │
│    │  - Calming Environments                   │              │
│    │  - Floating Question Cards                │              │
│    │  - 3D Helper Panels                       │              │
│    │  - Progress Visualization                 │              │
│    │  - Biometric Display                      │              │
│    └───────────────────┬───────────────────────┘              │
│                        │                                       │
│                        │                                       │
│         ┌──────────────┴──────────────┐                       │
│         │                              │                       │
│  ┌──────▼──────┐              ┌───────▼──────┐               │
│  │  FastAPI    │              │  WebSocket   │               │
│  │  REST API   │              │  (Real-time) │               │
│  └─────────────┘              └──────────────┘               │
│                                                                │
└────────────────────────────────────────────────────────────────┘

📖 Story 5.1: WebXR Infrastructure & React Three Fiber Setup
Story:
"As an XR engineer, I want a fully configured React Three Fiber + WebXR development environment with device detection, session management, and fallback handling, so that we can build immersive experiences that work across all WebXR-compatible devices."
Priority: P0 (Must Have - Sprint 4, Week 1)
Story Points: 13
Dependencies: Story 4.1 (React foundation)
Acceptance Criteria:

✅ @react-three/fiber and @react-three/xr installed and configured
✅ WebXR device detection (Quest, Vision Pro, PCVR, mobile AR)
✅ VR session initialization with error handling
✅ Controller input system working
✅ Hand tracking integration (Quest, Vision Pro)
✅ Gaze-based input system (accessibility)
✅ Performance monitoring (FPS counter, frame time)
✅ Fallback to 2D UI if WebXR not supported
✅ Session state management (entering/exiting VR)
✅ Basic lighting and rendering pipeline
✅ Hot reload working in development
✅ Works on Quest 2 (72fps), Quest 3 (90fps), Vision Pro (100fps)


🔧 Tasks for Story 5.1:
Task 5.1.1: Install and Configure Dependencies

Assigned To: XR Engineer
Estimated Hours: 4h
Deliverables:

bash# Install core XR dependencies
npm install three@0.160.0
npm install @react-three/fiber@8.15.0
npm install @react-three/drei@9.92.0
npm install @react-three/xr@6.2.0

# Install additional utilities
npm install zustand immer
npm install -D @types/three

# Optional performance tools
npm install r3f-perf
npm install stats.js
json// tsconfig.json - Add Three.js types
{
  "compilerOptions": {
    "types": ["vite/client", "three"]
  }
}
Task 5.1.2: Create XR App Shell

Assigned To: XR Engineer
Estimated Hours: 8h
Deliverables:

typescript// src/features/xr/XRApp.tsx
import { Canvas } from '@react-three/fiber';
import { VRButton, ARButton, XR, Controllers, Hands } from '@react-three/xr';
import { useXRStore } from './stores/xr.store';
import { XRScene } from './components/XRScene';
import { XRDeviceDetector } from './components/XRDeviceDetector';
import { PerformanceMonitor } from './components/PerformanceMonitor';
import { Suspense } from 'react';
import { LoadingEnvironment } from './components/LoadingEnvironment';

export function XRApp() {
  const { isXRSupported, deviceType } = useXRStore();

  if (!isXRSupported) {
    return <FallbackTo2DUI />;
  }

  return (
    <div className="relative h-screen w-screen bg-black">
      {/* XR Session Buttons */}
      <div className="absolute top-4 left-4 z-10 flex gap-4">
        <VRButton
          mode="immersive-vr"
          sessionInit={{
            requiredFeatures: ['hand-tracking', 'local-floor'],
            optionalFeatures: ['bounded-floor', 'layers'],
          }}
        />
        {deviceType === 'vision_pro' && (
          <ARButton
            mode="immersive-ar"
            sessionInit={{
              requiredFeatures: ['hand-tracking'],
            }}
          />
        )}
      </div>

      {/* Performance Stats (dev only) */}
      {import.meta.env.DEV && <PerformanceMonitor />}

      {/* React Three Fiber Canvas */}
      <Canvas
        camera={{
          position: [0, 1.6, 0], // Average eye height
          fov: 75,
        }}
        gl={{
          antialias: true,
          alpha: false,
          powerPreference: 'high-performance',
        }}
      >
        <XR>
          <Suspense fallback={<LoadingEnvironment />}>
            {/* Controllers and Hand Tracking */}
            <Controllers />
            <Hands />

            {/* Main XR Scene */}
            <XRScene />
          </Suspense>
        </XR>
      </Canvas>

      {/* Device Detector (invisible, sets store state) */}
      <XRDeviceDetector />
    </div>
  );
}

function FallbackTo2DUI() {
  return (
    <div className="flex h-screen items-center justify-center bg-gray-900 text-white">
      <div className="max-w-md text-center">
        <h2 className="mb-4 text-2xl font-bold">WebXR Not Supported</h2>
        <p className="mb-6 text-gray-300">
          Your device or browser doesn't support WebXR. 
          Redirecting to standard web experience...
        </p>
        <button
          onClick={() => window.location.href = '/dashboard/assessment'}
          className="rounded-lg bg-primary-600 px-6 py-3 font-medium hover:bg-primary-700"
        >
          Continue with Web Version
        </button>
      </div>
    </div>
  );
}
Task 5.1.3: XR State Management

Assigned To: XR Engineer
Estimated Hours: 6h
Deliverables:

typescript// src/features/xr/stores/xr.store.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

export type DeviceType = 'quest_2' | 'quest_3' | 'quest_pro' | 'vision_pro' | 'pcvr' | 'unknown';
export type InteractionMode = 'controllers' | 'hands' | 'gaze';

type XRState = {
  // Device detection
  isXRSupported: boolean;
  deviceType: DeviceType;
  targetFrameRate: number;
  
  // Session state
  isSessionActive: boolean;
  sessionMode: 'immersive-vr' | 'immersive-ar' | null;
  
  // Interaction
  interactionMode: InteractionMode;
  dominantHand: 'left' | 'right';
  
  // Performance
  currentFPS: number;
  averageFrameTime: number;
  
  // Settings
  settings: {
    comfort: {
      snapTurning: boolean;
      vignetteOnMovement: boolean;
      teleportOnly: boolean;
    };
    accessibility: {
      fontSize: number; // 1.0 = default, 1.5 = 150%
      highContrast: boolean;
      reducedMotion: boolean;
    };
  };
  
  // Actions
  setDeviceType: (type: DeviceType) => void;
  setSessionActive: (active: boolean) => void;
  setInteractionMode: (mode: InteractionMode) => void;
  updatePerformance: (fps: number, frameTime: number) => void;
  updateSettings: (settings: Partial<XRState['settings']>) => void;
};

export const useXRStore = create<XRState>()(
  immer((set) => ({
    // Initial state
    isXRSupported: false,
    deviceType: 'unknown',
    targetFrameRate: 72,
    isSessionActive: false,
    sessionMode: null,
    interactionMode: 'controllers',
    dominantHand: 'right',
    currentFPS: 0,
    averageFrameTime: 0,
    
    settings: {
      comfort: {
        snapTurning: true,
        vignetteOnMovement: true,
        teleportOnly: false,
      },
      accessibility: {
        fontSize: 1.0,
        highContrast: false,
        reducedMotion: false,
      },
    },

    // Actions
    setDeviceType: (type) => set((state) => {
      state.deviceType = type;
      state.isXRSupported = true;
      
      // Set target frame rate based on device
      switch (type) {
        case 'quest_2':
          state.targetFrameRate = 72;
          break;
        case 'quest_3':
        case 'quest_pro':
          state.targetFrameRate = 90;
          break;
        case 'vision_pro':
          state.targetFrameRate = 100;
          break;
        case 'pcvr':
          state.targetFrameRate = 120;
          break;
      }
    }),

    setSessionActive: (active) => set((state) => {
      state.isSessionActive = active;
    }),

    setInteractionMode: (mode) => set((state) => {
      state.interactionMode = mode;
    }),

    updatePerformance: (fps, frameTime) => set((state) => {
      state.currentFPS = fps;
      state.averageFrameTime = frameTime;
    }),

    updateSettings: (newSettings) => set((state) => {
      state.settings = { ...state.settings, ...newSettings };
    }),
  }))
);
Task 5.1.4: Device Detection Component

Assigned To: XR Engineer
Estimated Hours: 6h
Deliverables:

typescript// src/features/xr/components/XRDeviceDetector.tsx
import { useEffect } from 'react';
import { useXRStore } from '../stores/xr.store';

export function XRDeviceDetector() {
  const setDeviceType = useXRStore((state) => state.setDeviceType);

  useEffect(() => {
    detectDevice();
  }, []);

  async function detectDevice() {
    // Check if WebXR is supported
    if (!('xr' in navigator)) {
      console.log('WebXR not supported');
      return;
    }

    try {
      const supported = await (navigator as any).xr?.isSessionSupported('immersive-vr');
      if (!supported) {
        console.log('Immersive VR not supported');
        return;
      }

      // Detect specific device
      const userAgent = navigator.userAgent.toLowerCase();
      
      if (userAgent.includes('quest 3')) {
        setDeviceType('quest_3');
      } else if (userAgent.includes('quest 2')) {
        setDeviceType('quest_2');
      } else if (userAgent.includes('quest pro')) {
        setDeviceType('quest_pro');
      } else if (userAgent.includes('apple vision')) {
        setDeviceType('vision_pro');
      } else {
        // Generic PCVR or unknown
        setDeviceType('pcvr');
      }

      console.log('XR device detected and configured');
    } catch (error) {
      console.error('Error detecting XR device:', error);
    }
  }

  return null; // This component doesn't render anything
}
Task 5.1.5: Performance Monitoring

Assigned To: XR Engineer
Estimated Hours: 4h
Deliverables:

typescript// src/features/xr/components/PerformanceMonitor.tsx
import { useFrame } from '@react-three/fiber';
import { useRef, useEffect } from 'react';
import { useXRStore } from '../stores/xr.store';
import Stats from 'stats.js';

export function PerformanceMonitor() {
  const statsRef = useRef<Stats | null>(null);
  const updatePerformance = useXRStore((state) => state.updatePerformance);
  const frameTimesRef = useRef<number[]>([]);

  useEffect(() => {
    // Create Stats.js instance
    const stats = new Stats();
    stats.showPanel(0); // 0: fps, 1: ms, 2: mb
    stats.dom.style.position = 'absolute';
    stats.dom.style.top = '80px';
    stats.dom.style.left = '10px';
    document.body.appendChild(stats.dom);
    statsRef.current = stats;

    return () => {
      if (stats.dom.parentElement) {
        document.body.removeChild(stats.dom);
      }
    };
  }, []);

  useFrame((state, delta) => {
    if (statsRef.current) {
      statsRef.current.begin();
    }

    // Track frame times
    const frameTime = delta * 1000; // Convert to ms
    frameTimesRef.current.push(frameTime);
    
    // Keep only last 60 frames
    if (frameTimesRef.current.length > 60) {
      frameTimesRef.current.shift();
    }

    // Calculate average
    const avgFrameTime = frameTimesRef.current.reduce((a, b) => a + b, 0) / frameTimesRef.current.length;
    const fps = 1000 / avgFrameTime;

    // Update store every 30 frames
    if (frameTimesRef.current.length % 30 === 0) {
      updatePerformance(fps, avgFrameTime);
    }

    if (statsRef.current) {
      statsRef.current.end();
    }
  });

  return null;
}
Task 5.1.6: Controller Input System

Assigned To: XR Engineer
Estimated Hours: 8h
Deliverables:

typescript// src/features/xr/hooks/useControllerInput.ts
import { useXR, useController } from '@react-three/xr';
import { useEffect, useRef } from 'react';

export type ControllerButton = 
  | 'trigger'
  | 'squeeze'
  | 'thumbstick'
  | 'a_button'
  | 'b_button'
  | 'x_button'
  | 'y_button';

type ControllerInputCallback = {
  onButtonPress?: (button: ControllerButton, hand: 'left' | 'right') => void;
  onButtonRelease?: (button: ControllerButton, hand: 'left' | 'right') => void;
  onThumbstickMove?: (x: number, y: number, hand: 'left' | 'right') => void;
};

export function useControllerInput(callbacks: ControllerInputCallback) {
  const leftController = useController('left');
  const rightController = useController('right');
  const previousStateRef = useRef<Map<string, boolean>>(new Map());

  useEffect(() => {
    if (!leftController && !rightController) return;

    const checkController = (controller: any, hand: 'left' | 'right') => {
      if (!controller?.inputSource?.gamepad) return;

      const gamepad = controller.inputSource.gamepad;
      const buttons = gamepad.buttons;
      const axes = gamepad.axes;

      // Button mapping (Quest controllers)
      const buttonMap: Record<number, ControllerButton> = {
        0: 'trigger',
        1: 'squeeze',
        3: hand === 'left' ? 'x_button' : 'a_button',
        4: hand === 'left' ? 'y_button' : 'b_button',
      };

      // Check buttons
      buttons.forEach((button: GamepadButton, index: number) => {
        const buttonName = buttonMap[index];
        if (!buttonName) return;

        const key = `${hand}-${buttonName}`;
        const wasPressed = previousStateRef.current.get(key);
        const isPressed = button.pressed;

        if (isPressed && !wasPressed) {
          callbacks.onButtonPress?.(buttonName, hand);
        } else if (!isPressed && wasPressed) {
          callbacks.onButtonRelease?.(buttonName, hand);
        }

        previousStateRef.current.set(key, isPressed);
      });

      // Check thumbstick
      if (axes.length >= 4 && callbacks.onThumbstickMove) {
        const xAxis = hand === 'left' ? axes[2] : axes[0];
        const yAxis = hand === 'left' ? axes[3] : axes[1];
        
        // Only trigger if movement is significant (dead zone)
        if (Math.abs(xAxis) > 0.1 || Math.abs(yAxis) > 0.1) {
          callbacks.onThumbstickMove(xAxis, yAxis, hand);
        }
      }
    };

    const interval = setInterval(() => {
      if (leftController) checkController(leftController, 'left');
      if (rightController) checkController(rightController, 'right');
    }, 16); // ~60Hz

    return () => clearInterval(interval);
  }, [leftController, rightController, callbacks]);
}
Task 5.1.7: Hand Tracking Integration

Assigned To: XR Engineer
Estimated Hours: 8h
Deliverables:

typescript// src/features/xr/hooks/useHandTracking.ts
import { useXR } from '@react-three/xr';
import { useFrame } from '@react-three/fiber';
import { useRef } from 'react';
import * as THREE from 'three';

export type HandJoint = 'wrist' | 'thumb-tip' | 'index-finger-tip' | 'pinch-position';

type HandTrackingCallback = {
  onPinch?: (hand: 'left' | 'right', position: THREE.Vector3) => void;
  onPoint?: (hand: 'left' | 'right', direction: THREE.Vector3) => void;
};

export function useHandTracking(callbacks: HandTrackingCallback) {
  const { session } = useXR();
  const previousPinchState = useRef<{ left: boolean; right: boolean }>({
    left: false,
    right: false,
  });

  useFrame(() => {
    if (!session || !callbacks) return;

    // Get hand tracking data
    const frame = session.requestAnimationFrame ? (session as any).frame : null;
    if (!frame) return;

    ['left', 'right'].forEach((handedness) => {
      const hand = handedness as 'left' | 'right';
      
      // Get input source for this hand
      const inputSource = session.inputSources.find(
        (source: any) => source.handedness === handedness && source.hand
      );

      if (!inputSource?.hand) return;

      try {
        // Get joints
        const indexTip = inputSource.hand.get('index-finger-tip');
        const thumbTip = inputSource.hand.get('thumb-tip');
        const indexProximal = inputSource.hand.get('index-finger-metacarpal');

        if (!indexTip || !thumbTip || !indexProximal) return;

        // Calculate pinch distance
        const indexPos = new THREE.Vector3().fromArray(indexTip.transform.position as any);
        const thumbPos = new THREE.Vector3().fromArray(thumbTip.transform.position as any);
        const distance = indexPos.distanceTo(thumbPos);

        // Detect pinch (threshold ~2cm)
        const isPinching = distance < 0.02;
        const wasPinching = previousPinchState.current[hand];

        if (isPinching && !wasPinching) {
          // Pinch started
          const pinchPos = new THREE.Vector3()
            .addVectors(indexPos, thumbPos)
            .multiplyScalar(0.5);
          callbacks.onPinch?.(hand, pinchPos);
        }

        previousPinchState.current[hand] = isPinching;

        // Pointing direction
        if (callbacks.onPoint) {
          const proximalPos = new THREE.Vector3().fromArray(indexProximal.transform.position as any);
          const pointDirection = new THREE.Vector3()
            .subVectors(indexPos, proximalPos)
            .normalize();
          callbacks.onPoint(hand, pointDirection);
        }
      } catch (error) {
        console.error('Hand tracking error:', error);
      }
    });
  });
}
Task 5.1.8: Gaze-Based Input System

Assigned To: XR Engineer
Estimated Hours: 6h
Deliverables:

typescript// src/features/xr/hooks/useGazeInput.ts
import { useFrame, useThree } from '@react-three/fiber';
import { useRef, useCallback } from 'react';
import * as THREE from 'three';

type GazeInputCallback = {
  onGazeEnter?: (object: THREE.Object3D) => void;
  onGazeExit?: (object: THREE.Object3D) => void;
  onGazeDwell?: (object: THREE.Object3D, duration: number) => void;
};

export function useGazeInput(
  callbacks: GazeInputCallback,
  dwellTimeMs: number = 1500
) {
  const { camera, scene } = useThree();
  const raycaster = useRef(new THREE.Raycaster());
  const gazedObject = useRef<THREE.Object3D | null>(null);
  const gazeDuration = useRef(0);

  useFrame((state, delta) => {
    // Cast ray from camera forward
    raycaster.current.setFromCamera(new THREE.Vector2(0, 0), camera);
    
    // Find intersections with interactive objects
    const intersects = raycaster.current.intersectObjects(
      scene.children.filter((obj) => (obj.userData as any).interactive),
      true
    );

    const currentTarget = intersects.length > 0 ? intersects[0].object : null;

    // Check if target changed
    if (currentTarget !== gazedObject.current) {
      // Exit previous target
      if (gazedObject.current) {
        callbacks.onGazeExit?.(gazedObject.current);
      }

      // Enter new target
      gazedObject.current = currentTarget;
      gazeDuration.current = 0;

      if (currentTarget) {
        callbacks.onGazeEnter?.(currentTarget);
      }
    }

    // Track dwell time
    if (currentTarget) {
      gazeDuration.current += delta * 1000; // Convert to ms

      if (gazeDuration.current >= dwellTimeMs) {
        callbacks.onGazeDwell?.(currentTarget, gazeDuration.current);
        gazeDuration.current = 0; // Reset to prevent repeated triggers
      }
    }
  });

  const resetGaze = useCallback(() => {
    if (gazedObject.current) {
      callbacks.onGazeExit?.(gazedObject.current);
    }
    gazedObject.current = null;
    gazeDuration.current = 0;
  }, [callbacks]);

  return { resetGaze };
}
```

---

## 📖 Story 5.2: Calming Virtual Environments

**Story**:
*"As a user in VR, I want to be immersed in a beautiful, calming environment that reduces anxiety and promotes relaxation, so that I feel safe and comfortable during my assessment or therapy session."*

**Priority**: P0 (Must Have - Sprint 4, Week 2)
**Story Points**: 13
**Dependencies**: Story 5.1 (XR infrastructure)

### **Acceptance Criteria**:
1. ✅ Three environment options available: Soft-Lit Room, Nature Scene, Floating Platform
2. ✅ Procedurally generated sky with time-of-day variations
3. ✅ Ambient lighting appropriate for each environment
4. ✅ Subtle ambient animations (swaying trees, particle effects)
5. ✅ Spatial audio (nature sounds, gentle music)
6. ✅ Optimized for target frame rates (72fps+ Quest 2)
7. ✅ User can switch environments from settings menu
8. ✅ Environment presets tied to session phase (calming for induction, neutral for assessment)
9. ✅ LOD (Level of Detail) system for performance
10. ✅ User testing shows 85%+ prefer VR environments over 2D

---

### 🔧 **Tasks for Story 5.2**:

#### **Task 5.2.1: Design XR Scenes with GenAI**
- **Assigned To**: XR Engineer + UX Designer
- **Estimated Hours**: 8h
- **GenAI Prompt**: Use **Prompt 1** from document
```
Prompt to use:

You are an expert XR interaction designer working with Unity, Unreal, and WebXR.
Design an animated, real-time VR/WebXR scene for a therapeutic questionnaire between client and therapist.
Constraints:
– The client wears a headset and sits in a calming virtual space (e.g., soft-lit room, nature scene).
– Questions appear as floating cards arranged in an arc around the client.
– Each question has:
  • main question text
  • response UI (Likert scale, sliders, choice chips, text input)
  • a "?" helper panel that, when focused, shows example answers and gentle guidance.
– The therapist UI is a separate panel (2D screen or mirrored desktop) showing live responses and summarized indicators (mood, tension, etc.).
– Animations: panels ease in/out, highlight on gaze or controller hover, subtle particle effects for breathing or calmness.

Describe:
– The environment and lighting
– How the questionnaire steps progress (one question at a time vs cluster)
– How the user selects answers (hand controllers, gaze, pinch, pointer)
– How the helper guidance is revealed and dismissed
– Any accessibility considerations (font size, contrast, motion settings)

Output in bullet points and include 1 concrete example question with specific response options and helper text for each option band.
Deliverable: Scene design document with specifications for 3 environments
Task 5.2.2: Soft-Lit Room Environment

Assigned To: 3D Artist + XR Engineer
Estimated Hours: 16h
Deliverables:

typescript// src/features/xr/environments/SoftLitRoom.tsx
import { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import { 
  Environment, 
  Sky, 
  ContactShadows,
  SpotLight
} from '@react-three/drei';
import * as THREE from 'three';

export function SoftLitRoom() {
  const lightRef = useRef<THREE.SpotLight>(null);

  useFrame((state) => {
    if (lightRef.current) {
      // Gentle light pulsing for calming effect
      const time = state.clock.elapsedTime;
      lightRef.current.intensity = 0.8 + Math.sin(time * 0.5) * 0.1;
    }
  });

  return (
    <>
      {/* Skybox */}
      <Sky
        distance={450000}
        sunPosition={[0, 1, 0]}
        inclination={0.6}
        azimuth={0.25}
      />

      {/* Environment lighting */}
      <Environment preset="sunset" />

      {/* Ambient light */}
      <ambientLight intensity={0.4} color="#fff5e6" />

      {/* Main spot light (warm) */}
      <SpotLight
        ref={lightRef}
        position={[0, 5, 0]}
        angle={0.6}
        penumbra={1}
        intensity={0.8}
        color="#ffe4b5"
        castShadow
      />

      {/* Fill lights */}
      <pointLight position={[-5, 3, -5]} intensity={0.3} color="#ffd7a8" />
      <pointLight position={[5, 3, -5]} intensity={0.3} color="#ffd7a8" />

      {/* Floor */}
      <mesh
        rotation={[-Math.PI / 2, 0, 0]}
        position={[0, 0, 0]}
        receiveShadow
      >
        <planeGeometry args={[20, 20]} />
        <meshStandardMaterial
          color="#d4c8b8"
          roughness={0.8}
          metalness={0.2}
        />
      </mesh>

      {/* Soft shadows */}
      <ContactShadows
        position={[0, 0.01, 0]}
        opacity={0.4}
        scale={10}
        blur={2}
        far={4}
      />

      {/* Decorative elements */}
      <FloatingParticles />
    </>
  );
}

function FloatingParticles() {
  const particlesRef = useRef<THREE.Points>(null);
  const count = 100;

  // Generate random positions for particles
  const positions = new Float32Array(count * 3);
  for (let i = 0; i < count; i++) {
    positions[i * 3] = (Math.random() - 0.5) * 10;
    positions[i * 3 + 1] = Math.random() * 5;
    positions[i * 3 + 2] = (Math.random() - 0.5) * 10;
  }

  useFrame((state) => {
    if (particlesRef.current) {
      const time = state.clock.elapsedTime;
      particlesRef.current.rotation.y = time * 0.05;
      
      // Gentle up/down floating
      const positions = particlesRef.current.geometry.attributes.position.array as Float32Array;
      for (let i = 0; i < count; i++) {
        positions[i * 3 + 1] += Math.sin(time + i) * 0.001;
      }
      particlesRef.current.geometry.attributes.position.needsUpdate = true;
    }
  });

  return (
    <points ref={particlesRef}>
      <bufferGeometry>
        <bufferAttribute
          attach="attributes-position"
          count={count}
          array={positions}
          itemSize={3}
        />
      </bufferGeometry>
      <pointsMaterial
        size={0.02}
        color="#ffffff"
        transparent
        opacity={0.6}
        sizeAttenuation
      />
    </points>
  );
}
Task 5.2.3: Nature Scene Environment

Assigned To: 3D Artist + XR Engineer
Estimated Hours: 20h
Deliverables: Forest clearing with trees, grass, sky, ambient sounds

Task 5.2.4: Floating Platform Environment

Assigned To: 3D Artist + XR Engineer
Estimated Hours: 16h
Deliverables: Minimalist platform floating in serene sky with clouds

Task 5.2.5: Environment Selector UI

Assigned To: XR Engineer
Estimated Hours: 6h
Deliverables:

typescript// src/features/xr/components/EnvironmentSelector.tsx
import { useXRStore } from '../stores/xr.store';
import { SoftLitRoom } from '../environments/SoftLitRoom';
import { NatureScene } from '../environments/NatureScene';
import { FloatingPlatform } from '../environments/FloatingPlatform';

export type EnvironmentType = 'soft_room' | 'nature' | 'floating_platform';

export function EnvironmentSelector({ type }: { type: EnvironmentType }) {
  switch (type) {
    case 'soft_room':
      return <SoftLitRoom />;
    case 'nature':
      return <NatureScene />;
    case 'floating_platform':
      return <FloatingPlatform />;
    default:
      return <SoftLitRoom />;
  }
}
Task 5.2.6: Spatial Audio System

Assigned To: XR Engineer
Estimated Hours: 8h
Deliverables: Ambient sounds with 3D positioning

Task 5.2.7: LOD Optimization

Assigned To: XR Engineer
Estimated Hours: 8h
Deliverables: Level-of-detail system to maintain target FPS


📖 Story 5.3: 3D Floating Question Cards
Story:
"As a user in VR, I want to see questions displayed as beautiful 3D floating cards that I can interact with naturally using my hands or controllers, so that the assessment feels intuitive and immersive."
Priority: P0 (Must Have - Sprint 5, Week 1-2)
Story Points: 21
Dependencies: Stories 5.1 (XR infrastructure), 5.2 (Environments)
Acceptance Criteria:

✅ Question cards float in an arc 1.5-2m in front of user
✅ One active card at a time, others slightly dimmed/scaled
✅ Smooth transitions between questions (800ms ease-in-out)
✅ Cards have depth and 3D presence (not flat billboards)
✅ Interactive elements respond to controller ray, hand pointing, or gaze
✅ Visual feedback on hover (highlight, scale, glow)
✅ Support for all input types: slider, chips, radio, text (via virtual keyboard)
✅ Progress visualization as glowing orbs forming a circle
✅ Accessible font sizes (configurable 1.0x to 1.5x)
✅ High contrast mode available
✅ Performance: Renders at target FPS with all cards loaded
✅ User testing shows 80%+ prefer 3D cards over 2D overlay


🔧 Tasks for Story 5.3:
Due to length constraints, here's a condensed task list:
Task 5.3.1: Build 3D Question Card Component (16h)

Create card geometry with rounded corners and depth
Add question text using troika-three-text (3D text rendering)
Implement card material with glass-morphism effect
Add animations (fade in, scale, position transitions)

Task 5.3.2: Build 3D Input Components (24h)

3D Slider with draggable handle
3D Button chips (Likert scale)
3D Radio buttons with hover states
Virtual keyboard integration for text input

Task 5.3.3: Implement Interaction System (16h)

Ray casting from controllers
Hand pinch gesture detection
Gaze cursor with dwell selection
Visual feedback system (highlight, glow, particles)

Task 5.3.4: Build Progress Visualization (8h)

Glowing orbs arranged in circle
Fill animation as questions completed
Percentage display in center

Task 5.3.5: Add Accessibility Options (10h)

Font size adjustment (1.0x to 1.5x)
High contrast mode
Reduced motion mode
Settings panel in VR

Task 5.3.6: Performance Optimization (12h)

Instanced rendering for repeated elements
Occlusion culling
Texture atlasing
Draw call reduction


📖 Story 5.4: 3D Helper Panels
Story:
"As a user in VR needing clarification, I want to activate a 3D helper panel that appears beside the question with examples and guidance, so that I understand what's being asked without breaking immersion."
Priority: P1 (Should Have - Sprint 5, Week 2)
Story Points: 13
Dependencies: Story 5.3 (Question cards)
Acceptance Criteria:

✅ Helper panel slides in from the side (500ms animation)
✅ Contains same content as 2D version (why asking, 3 examples, guidance)
✅ Readable text with proper contrast
✅ Activated by gazing at "?" button for 1 second, or clicking/pinching it
✅ Dismissed by clicking close button or looking away for 3 seconds
✅ Doesn't block main question card
✅ Works with all interaction modes (controllers, hands, gaze)


 For Desktop Testing (Optional):
Install the WebXR Emulator Extension:

Chrome: https://chromewebstore.google.com/detail/webxr-api-emulator/mjddjgeghkdijejnciaefnkjmkafnnje
Firefox: https://addons.mozilla.org/en-US/firefox/addon/webxr-api-emulator/

This lets you simulate VR on desktop for testing.



📖 Story 5.5: XR Session Delivery Experience
Story:
"As a user in VR during a hypnotherapy session, I want the therapeutic suggestions to appear as floating text with spatial audio and calming visuals, so that I experience deep immersion and focus."
Priority: P1 (Should Have - Sprint 6)
Story Points: 21
Dependencies: Stories 5.1-5.4
Key Features:

Script text appears as gentle 3D text that fades in/out
Spatial audio for therapist voice (positioned naturally)
Breathing guidance visualizations (expanding/contracting sphere)
Biometric display (optional, non-intrusive)
Emergency exit button always accessible


📖 Story 5.6: Graceful Fallback & Cross-Device Testing
Story:
"As a product manager, I want the XR experience to gracefully fallback to 2D UI when WebXR isn't available, and to be tested across all target devices, so that we ensure broad compatibility."
Priority: P0 (Must Have - Sprint 6)
Story Points: 13
Testing Targets:

Quest 2 (72fps)
Quest 3 / Quest Pro (90fps)
Vision Pro (100fps)
Desktop VR (SteamVR, 120fps)
Mobile AR (ARCore/ARKit, 60fps)
Desktop browser (fallback to 2D)
Mobile browser (fallback to 2D)


📊 Epic 5 Summary
StoryPriorityStory PointsSprintKey Deliverables5.1 XR InfrastructureP013Sprint 4, Week 1React Three Fiber setup, device detection, input systems5.2 Calming EnvironmentsP013Sprint 4, Week 23 environments, spatial audio, LOD optimization5.3 3D Question CardsP021Sprint 5, Week 1-2Floating cards, 3D inputs, interaction system5.4 3D Helper PanelsP113Sprint 5, Week 2Side panel, animations, interaction modes5.5 XR Session DeliveryP121Sprint 6Session experience, spatial audio, biometrics5.6 Fallback & TestingP013Sprint 6Cross-device testing, fallback UI, QA
Total Story Points: 94
Estimated Duration: 3 sprints (6 weeks)
Team Required: 2 XR engineers, 1 3D artist, 1 UX designer

Would you like me to continue with:

EPIC 6: Therapist Dashboard & Analytics (Recharts visualizations, real-time WebSocket updates)
EPIC 7: Session Delivery & Real-Time Experience (Audio player, biometric displays, adaptive controls)
Generate code examples for any of the XR stories above

 My Recommendation
Start with Epic 9 (Audio) → Epic 7 (AI Guidance) → Epic 6 (Biofeedback)
Reasoning:

Audio first - Quick enhancement to existing VR experience
AI second - Leverage your GenAI expertise for therapeutic content
Biofeedback third - Hardware integration complexity

####### COMEBACK HERE!!! Go back and regenerate Epic 4 & 5 with ACTUAL COMPLETE CODE

Every React component fully implemented
Every TypeScript file complete
Every config file ready
Step-by-step "copy this, run that" instructions

###################

We need sophisticated, advanced cutting-edge GenAI platform, clinical and commercial product ready platform. , NOT A SIMPLE ONE. Adding some design details ..... I want AutoGen, CrewAI, Knowledge GRAPH RAG, MCP, Custom LLM, Vector store, FHIR, IoT, Unity/Unreal/Nvidia ACR and Omniverse...and Evolution:
→ Add RAG with your HMI knowledge base (Epic 9 work)
→ WebXR integration for Meta Quest 3
→ TTS with ElevenLabs
→ Real-time biometric adaptation
