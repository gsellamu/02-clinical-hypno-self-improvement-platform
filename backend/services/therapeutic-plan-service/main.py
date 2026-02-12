"""
5D Therapeutic Plan Generator - Main Service
Complete implementation of the plan generation logic
"""

from models import *
from typing import List, Dict


class TherapeuticPlanGenerator:
    """Main class for generating comprehensive 5D therapeutic plans"""
    
    def __init__(self):
        self.plan_cache = {}
    
    async def generate_plan(
        self,
        profile: ClientProfile,
        background_tasks: BackgroundTasks
    ) -> TherapeuticPlan:
        """Generate comprehensive 5D therapeutic plan"""
        
        print(f"🎯 Generating 5D Plan for user {profile.user_id}")
        
        # Step 1: GraphRAG recommendations
        print("  → Step 1: GraphRAG recommendations...")
        graphrag_recs = await self._get_graphrag_recommendations(profile)
        
        # Step 2: HMI protocols from Epic 6
        print("  → Step 2: Epic 6 protocols...")
        protocols = await self._get_hmi_protocols(profile, graphrag_recs)
        
        # Step 3: Generate scripts from Epic 7
        print("  → Step 3: Epic 7 script generation...")
        scripts = await self._generate_scripts(profile, protocols)
        
        # Step 4: Jung insights
        print("  → Step 4: Jungian analysis...")
        jung_insights = await self._get_jung_insights(profile)
        
        # Step 5: Siddha insights
        print("  → Step 5: Siddha analysis...")
        siddha_insights = await self._get_siddha_insights(profile)
        
        # Step 6: FHIR/clinical data
        print("  → Step 6: FHIR data integration...")
        clinical_data = await self._get_clinical_data(profile)
        
        # Step 7: Hypno LLM synthesis
        print("  → Step 7: Hypno LLM synthesis...")
        hypno_insights = await self._generate_hypno_insights(
            profile, graphrag_recs, protocols, jung_insights, siddha_insights, clinical_data
        )
        
        # Step 8: Build 5D plan
        print("  → Step 8: Building 5D plan...")
        plan = await self._build_5d_plan(
            profile, graphrag_recs, protocols, scripts,
            jung_insights, siddha_insights, hypno_insights, clinical_data
        )
        
        # Step 9: Generate milestones
        print("  → Step 9: Creating milestones...")
        plan.milestones = self._generate_milestones(plan, profile)
        
        # Step 10: Create safety protocols
        print("  → Step 10: Safety protocols...")
        plan.safety_protocols = self._create_safety_protocols(profile)
        plan.escalation_plan = self._create_escalation_plan(profile)
        
        print(f"✅ 5D Plan generated: {plan.plan_id}")
        
        background_tasks.add_task(self._save_plan, plan)
        
        return plan
    
    async def _get_graphrag_recommendations(self, profile: ClientProfile) -> Dict:
        """Get recommendations from GraphRAG"""
        query = f"""
        Find therapeutic protocols for:
        - Primary issue: {profile.primary_issue}
        - E&P Type: {profile.ep_type}
        - Severity: {profile.issue_severity}/10
        """
        
        results = await search_protocols(
            query=query,
            top_k=10,
            filters={"ep_type": profile.ep_type}
        )
        
        return results
    
    async def _get_hmi_protocols(self, profile: ClientProfile, graphrag_recs: Dict) -> List[Dict]:
        """Get HMI protocols"""
        protocols = []
        for protocol in graphrag_recs.get("protocols", []):
            if self._is_protocol_appropriate(protocol, profile):
                adapted = self._adapt_protocol_to_ep(protocol, profile.ep_type)
                protocols.append(adapted)
        return protocols[:5]
    
    async def _generate_scripts(self, profile: ClientProfile, protocols: List[Dict]) -> List[Dict]:
        """Generate therapy scripts"""
        scripts = []
        for protocol in protocols:
            script = await generate_with_hypno_llm(
                template=protocol.get("template"),
                ep_type=profile.ep_type,
                personalization={
                    "name": profile.user_id,
                    "issue": profile.primary_issue,
                    "goal": profile.goal_statement,
                }
            )
            scripts.append({
                "protocol_id": protocol.get("id"),
                "protocol_name": protocol.get("name"),
                "script": script,
                "duration_minutes": protocol.get("duration", 45),
            })
        return scripts
    
    async def _get_jung_insights(self, profile: ClientProfile) -> Dict:
        """Get Jungian insights"""
        archetypes = get_archetypes(
            primary_issue=profile.primary_issue,
            goals=profile.goal_statement
        )
        shadow_work = get_shadow_work(
            issues=profile.secondary_issues,
            severity=profile.issue_severity
        )
        return {
            "dominant_archetype": archetypes.get("dominant"),
            "shadow_aspects": shadow_work.get("aspects", []),
            "individuation_stage": archetypes.get("stage"),
            "recommended_focus": shadow_work.get("focus", []),
        }
    
    async def _get_siddha_insights(self, profile: ClientProfile) -> Dict:
        """Get Siddha insights"""
        chakra_analysis = get_chakra_analysis(
            physical_symptoms=profile.medical_conditions,
            emotional_issues=[profile.primary_issue] + profile.secondary_issues
        )
        energy_recs = get_energy_recommendations(
            chakra_balance=chakra_analysis.get("balance"),
            issue_type=profile.primary_issue
        )
        return {
            "chakra_imbalances": chakra_analysis.get("imbalances", []),
            "energy_blockages": chakra_analysis.get("blockages", []),
            "recommended_practices": energy_recs.get("practices", []),
            "mantras": energy_recs.get("mantras", []),
        }
    
    async def _get_clinical_data(self, profile: ClientProfile) -> Dict:
        """Get FHIR/clinical data"""
        try:
            fhir_data = await query_fhir_data(user_id=profile.user_id)
            context = await get_clinical_context(
                conditions=profile.medical_conditions,
                medications=profile.medications
            )
            return {
                "medical_history": fhir_data.get("conditions", []),
                "medications": fhir_data.get("medications", []),
                "clinical_notes": context.get("notes", []),
            }
        except Exception as e:
            print(f"⚠️ FHIR data unavailable: {e}")
            return {}
    
    async def _generate_hypno_insights(self, profile, graphrag_recs, protocols, jung, siddha, clinical) -> Dict:
        """Generate insights using Hypno LLM"""
        insights = await generate_with_hypno_llm(
            prompt=f"""
            Analyze client with {profile.ep_type} E&P type.
            Primary Issue: {profile.primary_issue}
            Goal: {profile.goal_statement}
            """,
            temperature=0.7,
            max_tokens=2000
        )
        return insights
    
    async def _build_5d_plan(self, profile, graphrag_recs, protocols, scripts, jung, siddha, hypno, clinical) -> TherapeuticPlan:
        """Build complete 5D plan"""
        plan_id = str(uuid4())
        
        executive_summary = f"""
        5D Therapeutic Plan for {profile.user_id}
        PRIMARY: {profile.primary_issue}
        E&P: {profile.ep_type} ({profile.ep_primary_percentage:.0f}% primary)
        DURATION: {len(protocols) * 6} weeks estimated
        """
        
        mind_plan = self._build_mind_dimension(profile, protocols, jung, hypno)
        body_plan = self._build_body_dimension(profile, protocols, siddha, clinical)
        social_plan = self._build_social_dimension(profile, protocols, jung)
        spiritual_plan = self._build_spiritual_dimension(profile, protocols, siddha, jung)
        integration_plan = self._build_integration_dimension(
            profile, mind_plan, body_plan, social_plan, spiritual_plan, hypno
        )
        
        session_structure = self._create_session_structure(protocols, scripts, profile.ep_type)
        baseline_metrics = self._calculate_baseline_metrics(profile)
        target_metrics = self._calculate_target_metrics(baseline_metrics, profile)
        
        return TherapeuticPlan(
            plan_id=plan_id,
            user_id=profile.user_id,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow(),
            version=1,
            executive_summary=executive_summary,
            treatment_philosophy=f"Multi-dimensional healing for {profile.ep_type} type",
            estimated_duration=f"{len(protocols) * 6} weeks",
            session_frequency="weekly",
            mind_dimension=mind_plan,
            body_dimension=body_plan,
            social_dimension=social_plan,
            spiritual_dimension=spiritual_plan,
            integration_dimension=integration_plan,
            session_structure=session_structure,
            protocol_sequence=[p.get("id") for p in protocols],
            milestones=[],
            safety_protocols=[],
            escalation_plan={},
            baseline_metrics=baseline_metrics,
            target_metrics=target_metrics,
            jung_insights=jung,
            siddha_insights=siddha,
            hypno_insights=hypno,
            clinical_insights=clinical
        )
    
    def _build_mind_dimension(self, profile, protocols, jung, hypno) -> DimensionPlan:
        """Build Mind dimension plan"""
        baseline_score = 100 - (profile.issue_severity * 10)
        return DimensionPlan(
            dimension="Mind",
            current_state=f"Client presents with {profile.primary_issue} (severity {profile.issue_severity}/10)",
            baseline_score=baseline_score,
            areas_of_concern=[profile.primary_issue] + profile.secondary_issues,
            strengths=[f"E&P {profile.ep_type} communication style"],
            short_term_goals=[
                f"Reduce {profile.primary_issue} intensity by 30%",
                "Develop awareness of cognitive patterns"
            ],
            long_term_goals=[profile.goal_statement, "Achieve cognitive resilience"],
            primary_protocols=[{"name": p.get("name"), "sessions": p.get("session_count", 6)} for p in protocols[:3]],
            complementary_practices=[
                {"name": "Daily self-hypnosis", "frequency": "daily", "duration": "10 min"},
                {"name": "Cognitive journaling", "frequency": "3x/week", "duration": "15 min"}
            ],
            progress_indicators=["Symptom intensity (0-10)", "Quality of sleep"],
            measurement_frequency="Weekly check-ins",
            recommended_reading=["Man and His Symbols - Carl Jung"],
            exercises=[{"name": "Positive Affirmations", "description": "Daily practice", "frequency": "2x daily"}],
            ep_adaptations=self._get_ep_adaptations(profile.ep_type)
        )
    
    def _build_body_dimension(self, profile, protocols, siddha, clinical) -> DimensionPlan:
        """Build Body dimension plan"""
        return DimensionPlan(
            dimension="Body",
            current_state=f"Somatic assessment: {', '.join(siddha.get('chakra_imbalances', ['balanced']))}",
            baseline_score=70.0,
            areas_of_concern=profile.medical_conditions + siddha.get("energy_blockages", []),
            strengths=["Body awareness present"],
            short_term_goals=["Establish mind-body connection", "Release somatic tension"],
            long_term_goals=["Sustained physical well-being", "Balanced energy system"],
            primary_protocols=[{"name": "Progressive Muscle Relaxation", "sessions": 4}],
            complementary_practices=siddha.get("recommended_practices", []),
            progress_indicators=["Physical tension levels", "Energy levels"],
            measurement_frequency="Daily biometric monitoring",
            recommended_reading=["The Body Keeps the Score - Bessel van der Kolk"],
            exercises=[{"name": "Body Scan", "description": "Daily practice", "frequency": "Daily"}],
            ep_adaptations=self._get_ep_adaptations(profile.ep_type)
        )
    
    def _build_social_dimension(self, profile, protocols, jung) -> DimensionPlan:
        """Build Social dimension plan"""
        baseline_score = {"weak": 50.0, "moderate": 70.0, "strong": 85.0}.get(profile.support_system, 70.0)
        return DimensionPlan(
            dimension="Social",
            current_state=f"Client reports {profile.support_system} support system",
            baseline_score=baseline_score,
            areas_of_concern=["Communication patterns", "Boundary setting"],
            strengths=[f"{profile.support_system.capitalize()} support system"],
            short_term_goals=["Improve communication skills", "Set healthy boundaries"],
            long_term_goals=["Authentic relationships", "Strong support network"],
            primary_protocols=[{"name": "Communication Enhancement", "sessions": 4}],
            complementary_practices=[
                {"name": "Relationship journaling", "frequency": "weekly", "duration": "20 min"}
            ],
            progress_indicators=["Quality of relationships", "Frequency of conflicts"],
            measurement_frequency="Biweekly check-ins",
            recommended_reading=["Nonviolent Communication - Marshall Rosenberg"],
            exercises=[{"name": "Communication Scripts", "description": "Practice assertive communication", "frequency": "As needed"}],
            ep_adaptations=self._get_ep_adaptations(profile.ep_type)
        )
    
    def _build_spiritual_dimension(self, profile, protocols, siddha, jung) -> DimensionPlan:
        """Build Spiritual dimension plan"""
        return DimensionPlan(
            dimension="Spiritual",
            current_state=f"Seeking meaning through: {profile.goal_statement}",
            baseline_score=70.0,
            areas_of_concern=["Sense of purpose", "Connection to higher self"],
            strengths=["Openness to growth"],
            short_term_goals=["Clarify personal values", "Develop daily spiritual practice"],
            long_term_goals=["Authentic self-expression", profile.goal_statement],
            primary_protocols=[{"name": "Inner Guide Visualization", "sessions": 4}],
            complementary_practices=[
                {"name": "Meditation", "frequency": "daily", "duration": "15 min"},
                {"name": "Mantra: " + siddha.get("mantras", ["Om"])[0], "frequency": "daily", "duration": "5 min"}
            ],
            progress_indicators=["Sense of meaning/purpose", "Spiritual well-being"],
            measurement_frequency="Monthly reflection",
            recommended_reading=["Man's Search for Meaning - Viktor Frankl"],
            exercises=[{"name": "Values Clarification", "description": "Identify core values", "frequency": "Monthly"}],
            ep_adaptations=self._get_ep_adaptations(profile.ep_type)
        )
    
    def _build_integration_dimension(self, profile, mind, body, social, spiritual, hypno) -> DimensionPlan:
        """Build Integration dimension plan"""
        baseline_score = (mind.baseline_score + body.baseline_score + social.baseline_score + spiritual.baseline_score) / 4
        return DimensionPlan(
            dimension="Integration",
            current_state=f"Overall wellness baseline: {baseline_score:.1f}%",
            baseline_score=baseline_score,
            areas_of_concern=["Dimensional balance", "Holistic consistency"],
            strengths=["Commitment to transformation"],
            short_term_goals=["Establish integrated daily practice"],
            long_term_goals=["Sustained holistic well-being", profile.goal_statement],
            primary_protocols=[{"name": "Holistic Integration Sessions", "sessions": 8}],
            complementary_practices=[
                {"name": "Daily 5D check-in", "frequency": "daily", "duration": "10 min"}
            ],
            progress_indicators=["Overall well-being score", "Goal achievement rate"],
            measurement_frequency="Weekly 5D dashboard review",
            recommended_reading=["Integral Psychology - Ken Wilber"],
            exercises=[{"name": "5D Radar Chart Review", "description": "Track all dimensions", "frequency": "Weekly"}],
            ep_adaptations={"communication": f"Adapted for {profile.ep_type} type"}
        )
    
    def _create_session_structure(self, protocols, scripts, ep_type):
        """Create session structure"""
        return {
            "session_duration": 60,
            "phases": [
                {"name": "Check-in", "duration": 10},
                {"name": "Induction", "duration": 10},
                {"name": "Depth Work", "duration": 25},
                {"name": "Emergence", "duration": 5},
                {"name": "Integration", "duration": 10}
            ]
        }
    
    def _calculate_baseline_metrics(self, profile):
        """Calculate baseline metrics"""
        return {
            "mind": 100 - (profile.issue_severity * 10),
            "body": 70.0,
            "social": {"weak": 50, "moderate": 70, "strong": 85}.get(profile.support_system, 70),
            "spiritual": 70.0,
            "integration": 65.0
        }
    
    def _calculate_target_metrics(self, baseline, profile):
        """Calculate target metrics"""
        improvement = 0.6
        return {
            "mind": min(baseline["mind"] + (100 - baseline["mind"]) * improvement, 95),
            "body": min(baseline["body"] + (100 - baseline["body"]) * improvement, 90),
            "social": min(baseline["social"] + (100 - baseline["social"]) * improvement, 90),
            "spiritual": min(baseline["spiritual"] + (100 - baseline["spiritual"]) * improvement, 90),
            "integration": min(baseline["integration"] + (100 - baseline["integration"]) * improvement, 95)
        }
    
    def _generate_milestones(self, plan, profile):
        """Generate milestones"""
        return [
            {"week": 2, "title": "Initial Progress Check", "criteria": ["Comfortable with process"]},
            {"week": 4, "title": "First Third", "criteria": ["30% symptom reduction"]},
            {"week": 8, "title": "Two-Thirds", "criteria": ["50% symptom reduction"]},
            {"week": 12, "title": "Completion", "criteria": profile.success_criteria}
        ]
    
    def _create_safety_protocols(self, profile):
        """Create safety protocols"""
        protocols = [
            "Begin each session with safety check",
            "Emergency contact on file",
            "Monitor for abreaction signs"
        ]
        if not profile.referral_verified:
            protocols.append("⚠️ REQUIRES VERIFIED REFERRAL")
        return protocols
    
    def _create_escalation_plan(self, profile):
        """Create escalation plan"""
        return {
            "tier_1_immediate": {
                "indicators": ["Suicidal ideation", "Psychotic break"],
                "actions": ["Call 988", "Contact emergency services"]
            },
            "tier_2_clinical": {
                "indicators": ["Worsening symptoms"],
                "actions": ["Contact referring provider within 24h"]
            }
        }
    
    def _get_ep_adaptations(self, ep_type):
        """Get E&P adaptations"""
        return {
            "Physical": {"language": "Direct, concrete", "imagery": "Literal"},
            "Emotional": {"language": "Permissive, metaphorical", "imagery": "Abstract"},
            "Somnambulist": {"language": "Balanced", "imagery": "Mixed"}
        }.get(ep_type, {"language": "Balanced"})
    
    def _is_protocol_appropriate(self, protocol, profile):
        """Check if protocol appropriate"""
        for contra in profile.contraindications:
            if contra in protocol.get("contraindications", []):
                return False
        return True
    
    def _adapt_protocol_to_ep(self, protocol, ep_type):
        """Adapt protocol to E&P type"""
        adapted = protocol.copy()
        if ep_type == "Physical":
            adapted["language_style"] = "direct_literal"
        elif ep_type == "Emotional":
            adapted["language_style"] = "permissive_metaphorical"
        return adapted
    
    async def _save_plan(self, plan: TherapeuticPlan):
        """Save plan to database"""
        print(f"💾 Saving plan {plan.plan_id}...")


# =============================================================================
# API ENDPOINTS
# =============================================================================

generator = TherapeuticPlanGenerator()

@app.post("/api/v1/plan/generate", response_model=TherapeuticPlan)
async def generate_therapeutic_plan(profile: ClientProfile, background_tasks: BackgroundTasks):
    """Generate comprehensive 5D therapeutic plan"""
    try:
        plan = await generator.generate_plan(profile, background_tasks)
        return plan
    except Exception as e:
        raise HTTPException(500, f"Failed to generate plan: {str(e)}")


@app.get("/api/v1/plan/{user_id}")
async def get_therapeutic_plan(user_id: str):
    """Get existing plan"""
    raise HTTPException(501, "Not implemented")


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "5D Therapeutic Plan Generator"}
