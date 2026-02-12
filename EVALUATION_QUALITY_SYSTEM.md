# Evaluation & Quality Assurance - Therapeutic Journaling Platform
## Response Grading, Technique Fidelity, Session Plan Schema

**Version:** 1.0
**Date:** 2026-02-11
**Purpose:** Ensure clinical quality, safety compliance, and technique adherence

---

## E1. RESPONSE RUBRIC GRADER

### Scoring Dimensions (0-5 Scale)

```python
from typing import List, Dict
from pydantic import BaseModel, Field
from enum import Enum

class ScoreDimension(str, Enum):
    SAFETY_COMPLIANCE = "safety_compliance"
    TECHNIQUE_ADHERENCE = "technique_adherence"
    CLARITY_TIMEBOXING = "clarity_timeboxing"
    NON_JUDGMENTAL_TONE = "non_judgmental_tone"
    ACTIONABILITY = "actionability"

class Score(BaseModel):
    dimension: ScoreDimension
    score: int = Field(..., ge=0, le=5)
    reasoning: str
    evidence: List[str]

class Issue(BaseModel):
    severity: str  # critical, high, medium, low
    dimension: ScoreDimension
    description: str
    location: str  # e.g., "step 2, minute 3-5"

class SuggestedFix(BaseModel):
    issue_id: str
    fix_type: str  # replace, add, remove, reorder
    original_text: str
    suggested_text: str
    reasoning: str

class RubricEvaluation(BaseModel):
    session_id: str
    technique: str
    scores: Dict[ScoreDimension, Score]
    overall_score: float  # average of all dimension scores
    issues: List[Issue]
    suggested_fixes: List[SuggestedFix]
    passed_quality_gate: bool  # True if overall_score >= 4.0
    timestamp: str
```

---

### Detailed Rubric Criteria

```json
{
  "rubric_criteria": {
    "safety_compliance": {
      "5": "Exemplary safety practices. Explicit safety checks, crisis resources visible, appropriate pacing, trauma-informed language throughout.",
      "4": "Strong safety practices. Safety checks present, appropriate pacing, mostly trauma-informed.",
      "3": "Adequate safety. Safety checks present but could be more explicit. Some pacing issues.",
      "2": "Safety concerns present. Missing safety checks, rushed pacing, or potentially triggering language.",
      "1": "Major safety issues. No safety checks, inappropriate for Code Yellow/Red, or harmful pacing.",
      "0": "Critical safety violations. Contains explicit crisis content without intervention, dangerous pacing, or harmful instructions.",
      "evaluation_checklist": [
        "Does it include pre-exercise safety assessment?",
        "Are crisis resources provided if needed?",
        "Is pacing appropriate for emotional intensity?",
        "Does it avoid re-traumatizing language?",
        "Are mid-exercise safety checks present (for >10 min exercises)?",
        "Is there a grounding close?"
      ]
    },
    "technique_adherence": {
      "5": "Perfect technique execution. All required elements present, correct sequence, proper timeboxing.",
      "4": "Strong technique adherence. Minor deviations that don't compromise therapeutic value.",
      "3": "Adequate technique execution. Some elements missing or out of order, but core intact.",
      "2": "Poor technique adherence. Missing multiple required elements or significant sequence errors.",
      "1": "Minimal technique adherence. Barely recognizable as the selected technique.",
      "0": "Wrong technique entirely. Does not match selected technique at all.",
      "evaluation_checklist": [
        "Are all required technique elements present?",
        "Is the sequence correct?",
        "Is timeboxing accurate?",
        "Are prompts/questions appropriate for this technique?",
        "Does it maintain technique-specific structure?"
      ]
    },
    "clarity_timeboxing": {
      "5": "Crystal clear instructions. Precise timeboxing with timestamps. No ambiguity.",
      "4": "Clear instructions. Good timeboxing with minor timing ambiguities.",
      "3": "Adequate clarity. Instructions understandable but could be clearer. Timeboxing present but imprecise.",
      "2": "Confusing instructions. Poor timeboxing. User likely to be confused.",
      "1": "Very unclear. No effective timeboxing. User will struggle to follow.",
      "0": "Incomprehensible. No timeboxing. Cannot be executed.",
      "evaluation_checklist": [
        "Are instructions specific and actionable?",
        "Is timing clearly indicated?",
        "Are transitions between steps clear?",
        "Is the total duration accurate?",
        "Are guideposts provided at appropriate intervals?"
      ]
    },
    "non_judgmental_tone": {
      "5": "Perfectly non-judgmental. Validating, accepting, client-led. No shoulds/musts.",
      "4": "Mostly non-judgmental. Occasional directive language but overall accepting.",
      "3": "Adequate neutrality. Some judgmental language present but not pervasive.",
      "2": "Judgmental tone present. Multiple instances of shoulds, evaluative language.",
      "1": "Highly judgmental. Prescriptive, authoritarian, invalidating.",
      "0": "Harmful tone. Shaming, blaming, or coercive language.",
      "evaluation_checklist": [
        "Does it avoid 'should' and 'must' language?",
        "Is client agency preserved?",
        "Are all emotions validated as acceptable?",
        "Does it avoid evaluative judgments?",
        "Is language permissive vs prescriptive?"
      ]
    },
    "actionability": {
      "5": "Highly actionable. Clear next steps, concrete action items, realistic timeline.",
      "4": "Strong actionability. Good next steps, mostly concrete.",
      "3": "Adequate actionability. Some action items present but could be more specific.",
      "2": "Poor actionability. Vague next steps, lacks specificity.",
      "1": "Minimal actionability. No clear action items.",
      "0": "No actionability. Purely theoretical with no practical application.",
      "evaluation_checklist": [
        "Are next steps clearly defined?",
        "Are action items specific and measurable?",
        "Is timeline realistic?",
        "Are resources/tools provided?",
        "Can the user implement this independently?"
      ]
    }
  }
}
```

---

### Implementation: Rubric Grader

```python
import anthropic
from typing import Dict, List
import json

class ResponseRubricGrader:
    def __init__(self, api_key: str):
        self.client = anthropic.Anthropic(api_key=api_key)
        
    async def evaluate_response(
        self, 
        session_plan: Dict,
        generated_script: str,
        technique: str
    ) -> RubricEvaluation:
        """
        Evaluate a generated session script against rubric criteria
        """
        
        prompt = f"""You are a clinical supervisor evaluating a therapeutic journaling session script.

SESSION PLAN:
{json.dumps(session_plan, indent=2)}

GENERATED SCRIPT:
{generated_script}

TECHNIQUE: {technique}

Evaluate this script on 5 dimensions (0-5 scale each):

1. **Safety Compliance** - Does it follow trauma-informed practices, include safety checks, and use appropriate pacing?
2. **Technique Adherence** - Does it correctly implement the {technique} technique with all required elements?
3. **Clarity & Timeboxing** - Are instructions clear and timing precise?
4. **Non-Judgmental Tone** - Is the language validating, accepting, and free of shoulds/musts?
5. **Actionability** - Does it provide concrete, realistic next steps?

For each dimension:
- Assign a score (0-5)
- Provide reasoning (2-3 sentences)
- Cite specific evidence from the script

Then identify:
- Issues (severity: critical/high/medium/low)
- Suggested fixes (with diff-style before/after)

Return JSON matching this schema:
{{
  "scores": {{
    "safety_compliance": {{"score": 0-5, "reasoning": "...", "evidence": ["quote 1", "quote 2"]}},
    "technique_adherence": {{"score": 0-5, "reasoning": "...", "evidence": [...]}},
    "clarity_timeboxing": {{"score": 0-5, "reasoning": "...", "evidence": [...]}},
    "non_judgmental_tone": {{"score": 0-5, "reasoning": "...", "evidence": [...]}},
    "actionability": {{"score": 0-5, "reasoning": "...", "evidence": [...]}}
  }},
  "overall_score": 0.0,
  "issues": [
    {{"severity": "high", "dimension": "safety_compliance", "description": "...", "location": "step 2, minute 3-5"}}
  ],
  "suggested_fixes": [
    {{"issue_id": "1", "fix_type": "add", "original_text": "", "suggested_text": "Take three grounding breaths before beginning.", "reasoning": "..."}}
  ],
  "passed_quality_gate": true
}}

Be specific, cite evidence, and provide actionable fixes."""

        response = self.client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=4000,
            messages=[{"role": "user", "content": prompt}]
        )
        
        # Parse JSON response
        result_text = response.content[0].text
        
        # Extract JSON (handle markdown code blocks)
        if "```json" in result_text:
            result_text = result_text.split("```json")[1].split("```")[0].strip()
        
        result = json.loads(result_text)
        
        return RubricEvaluation(
            session_id=session_plan.get("session_id", "unknown"),
            technique=technique,
            scores=result["scores"],
            overall_score=result["overall_score"],
            issues=result["issues"],
            suggested_fixes=result["suggested_fixes"],
            passed_quality_gate=result["passed_quality_gate"],
            timestamp=datetime.utcnow().isoformat()
        )
```

---

### Example Evaluation Output

```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "technique": "unsent_letter",
  "scores": {
    "safety_compliance": {
      "score": 4,
      "reasoning": "Strong safety practices present. Includes intensity assessment and grounding close. However, missing explicit mid-exercise safety check at 7-minute mark.",
      "evidence": [
        "Before we begin, rate your emotional intensity 1-5",
        "Let's close with three grounding breaths",
        "No explicit safety check during 15-minute writing"
      ]
    },
    "technique_adherence": {
      "score": 5,
      "reasoning": "Perfect implementation of unsent letter technique. All required elements present: intention setting, scaffolded prompts, optional boundary statement, integration reflection.",
      "evidence": [
        "Set intention (2 min)",
        "Scaffolded prompts: 'I need to tell you...', 'What I wish you understood...'",
        "Optional boundary: 'From now on, I will...'",
        "Integration: 'What did I learn?'"
      ]
    },
    "clarity_timeboxing": {
      "score": 3,
      "reasoning": "Instructions are clear but timeboxing is imprecise. Total duration stated as '15 minutes' but individual steps add up to 22 minutes.",
      "evidence": [
        "Set intention: 2 min",
        "Write letter: 15 min",
        "Boundary statement: 2 min",
        "Integration: 3 min",
        "Total: 22 min (not 15 min as stated)"
      ]
    },
    "non_judgmental_tone": {
      "score": 5,
      "reasoning": "Perfectly non-judgmental throughout. Uses permissive language, validates all emotions, preserves client agency. No shoulds or musts.",
      "evidence": [
        "You might notice...",
        "If you wish, you can...",
        "Whatever arises is welcome",
        "There's no right way to do this"
      ]
    },
    "actionability": {
      "score": 4,
      "reasoning": "Good actionability with concrete reflection questions. However, missing explicit next-step action item at the end.",
      "evidence": [
        "What did I learn from writing this?",
        "What boundary do I need to set?",
        "No concrete action like 'One thing I will do this week is...'"
      ]
    }
  },
  "overall_score": 4.2,
  "issues": [
    {
      "severity": "high",
      "dimension": "clarity_timeboxing",
      "description": "Timeboxing math error. Stated duration (15 min) doesn't match sum of steps (22 min).",
      "location": "Overall session duration"
    },
    {
      "severity": "medium",
      "dimension": "safety_compliance",
      "description": "Missing mid-exercise safety check for intense emotional work.",
      "location": "Step 2 (Write letter), minute 7-8"
    },
    {
      "severity": "low",
      "dimension": "actionability",
      "description": "No explicit next-step action item after reflection.",
      "location": "Step 4 (Integration), end"
    }
  ],
  "suggested_fixes": [
    {
      "issue_id": "1",
      "fix_type": "replace",
      "original_text": "Total duration: 15 minutes",
      "suggested_text": "Total duration: 20 minutes (adjusted from 22 by reducing letter writing to 13 min)",
      "reasoning": "Fix timeboxing math by either adjusting stated total or reducing letter writing time."
    },
    {
      "issue_id": "2",
      "fix_type": "add",
      "original_text": "",
      "suggested_text": "[At 7 minutes] Pause for a moment. Take a breath. Notice how you're feeling. If this feels too intense, you can stop or take a break. Otherwise, continue.",
      "reasoning": "Add mid-exercise safety check during intense emotional processing."
    },
    {
      "issue_id": "3",
      "fix_type": "add",
      "original_text": "What did I learn from writing this?",
      "suggested_text": "What did I learn from writing this? Based on this insight, one small action I can take this week is...",
      "reasoning": "Add concrete action item to improve actionability."
    }
  ],
  "passed_quality_gate": true,
  "timestamp": "2026-02-11T10:30:00Z"
}
```

---

## E2. TECHNIQUE FIDELITY CHECKER

### Technique Requirements Database

```python
from typing import Dict, List, Set
from pydantic import BaseModel

class TechniqueElement(BaseModel):
    name: str
    required: bool
    expected_duration_minutes: int
    keywords: List[str]
    validation_rules: List[str]

class TechniqueSpec(BaseModel):
    technique_id: str
    name: str
    min_duration_minutes: int
    max_duration_minutes: int
    required_elements: List[TechniqueElement]
    sequence_order: List[str]  # Expected order of elements
    optional_elements: List[TechniqueElement]

TECHNIQUE_SPECS: Dict[str, TechniqueSpec] = {
    "sprint": TechniqueSpec(
        technique_id="sprint",
        name="Sprint / Free-Write",
        min_duration_minutes=5,
        max_duration_minutes=10,
        required_elements=[
            TechniqueElement(
                name="prep",
                required=True,
                expected_duration_minutes=1,
                keywords=["prepare", "setup", "begin", "ready"],
                validation_rules=["Must appear before writing phase"]
            ),
            TechniqueElement(
                name="writing",
                required=True,
                expected_duration_minutes=7,
                keywords=["write", "pen moving", "keep going", "don't stop"],
                validation_rules=[
                    "Duration must be 5-10 minutes",
                    "Must include 'keep pen moving' instruction",
                    "Must have guideposts at 2min, 4min, 6min intervals"
                ]
            ),
            TechniqueElement(
                name="reflection",
                required=True,
                expected_duration_minutes=2,
                keywords=["reflect", "notice", "themes", "what emerged"],
                validation_rules=["Must include 2-3 reflection questions"]
            ),
            TechniqueElement(
                name="close",
                required=True,
                expected_duration_minutes=1,
                keywords=["breath", "grounding", "complete", "finish"],
                validation_rules=["Must include grounding exercise"]
            )
        ],
        sequence_order=["prep", "writing", "reflection", "close"],
        optional_elements=[]
    ),
    "unsent_letter": TechniqueSpec(
        technique_id="unsent_letter",
        name="Unsent Letter",
        min_duration_minutes=15,
        max_duration_minutes=25,
        required_elements=[
            TechniqueElement(
                name="intensity_assessment",
                required=True,
                expected_duration_minutes=1,
                keywords=["intensity", "rate", "1-5", "scale"],
                validation_rules=["Must assess emotional intensity before starting"]
            ),
            TechniqueElement(
                name="intention",
                required=True,
                expected_duration_minutes=2,
                keywords=["intention", "who", "what you need to say"],
                validation_rules=["Must clarify recipient and purpose"]
            ),
            TechniqueElement(
                name="letter_writing",
                required=True,
                expected_duration_minutes=15,
                keywords=["write", "letter", "dear", "I need to tell you"],
                validation_rules=[
                    "Duration 10-15 minutes (reduce to 10 if intensity >=4)",
                    "Must include scaffolded prompts",
                    "Must remind 'This letter will NOT be sent'"
                ]
            ),
            TechniqueElement(
                name="boundary_statement",
                required=False,
                expected_duration_minutes=2,
                keywords=["boundary", "from now on", "I will"],
                validation_rules=["Marked as optional"]
            ),
            TechniqueElement(
                name="integration",
                required=True,
                expected_duration_minutes=3,
                keywords=["learn", "release", "insight"],
                validation_rules=["Must include 'What did I learn?' question"]
            ),
            TechniqueElement(
                name="grounding_close",
                required=True,
                expected_duration_minutes=2,
                keywords=["breath", "grounding", "self-compassion"],
                validation_rules=["Must include self-compassion statement"]
            )
        ],
        sequence_order=[
            "intensity_assessment",
            "intention",
            "letter_writing",
            "boundary_statement",
            "integration",
            "grounding_close"
        ],
        optional_elements=[
            TechniqueElement(
                name="boundary_statement",
                required=False,
                expected_duration_minutes=2,
                keywords=["boundary"],
                validation_rules=[]
            )
        ]
    ),
    "sentence_stems": TechniqueSpec(
        technique_id="sentence_stems",
        name="Sentence Stems",
        min_duration_minutes=20,
        max_duration_minutes=30,
        required_elements=[
            TechniqueElement(
                name="intro",
                required=True,
                expected_duration_minutes=2,
                keywords=["complete", "sentences", "first thing"],
                validation_rules=["Must explain the process"]
            ),
            TechniqueElement(
                name="stems_presentation",
                required=True,
                expected_duration_minutes=20,
                keywords=["notice", "believe", "if I weren't afraid"],
                validation_rules=[
                    "Must have 12 stems",
                    "Stems 1-3: observation",
                    "Stems 4-6: beliefs",
                    "Stems 7-9: needs/fears",
                    "Stems 10-12: identity/action"
                ]
            ),
            TechniqueElement(
                name="review",
                required=True,
                expected_duration_minutes=5,
                keywords=["review", "insights", "patterns"],
                validation_rules=["Must prompt user to review their answers"]
            )
        ],
        sequence_order=["intro", "stems_presentation", "review"],
        optional_elements=[]
    )
}
```

---

### Fidelity Checker Implementation

```python
import re
from difflib import unified_diff
from typing import List, Tuple

class TechniqueFidelityChecker:
    def __init__(self):
        self.specs = TECHNIQUE_SPECS
    
    def check_fidelity(
        self, 
        technique: str, 
        session_script: str
    ) -> Dict:
        """
        Verify session script follows technique requirements
        """
        if technique not in self.specs:
            return {"error": f"Unknown technique: {technique}"}
        
        spec = self.specs[technique]
        
        # Parse script into sections
        sections = self._parse_script_sections(session_script)
        
        # Check required elements
        missing_elements = self._check_required_elements(spec, sections)
        
        # Check sequence order
        sequence_violations = self._check_sequence_order(spec, sections)
        
        # Check duration
        duration_issues = self._check_duration(spec, sections)
        
        # Check validation rules
        rule_violations = self._check_validation_rules(spec, sections)
        
        # Generate diff suggestions
        suggestions = self._generate_fixes(
            spec,
            missing_elements,
            sequence_violations,
            duration_issues,
            rule_violations
        )
        
        return {
            "technique": technique,
            "fidelity_score": self._calculate_fidelity_score(
                missing_elements,
                sequence_violations,
                rule_violations
            ),
            "missing_elements": missing_elements,
            "sequence_violations": sequence_violations,
            "duration_issues": duration_issues,
            "rule_violations": rule_violations,
            "suggestions": suggestions,
            "passed": len(missing_elements) == 0 and len(rule_violations) == 0
        }
    
    def _parse_script_sections(self, script: str) -> List[Dict]:
        """Parse script into identifiable sections"""
        sections = []
        
        # Simple section detection based on headers or time markers
        lines = script.split('\n')
        current_section = {"name": "intro", "content": "", "start_line": 0}
        
        for i, line in enumerate(lines):
            # Detect section headers (### Header, **Bold**, TIME: markers)
            if re.match(r'^#{2,3}\s+(.+)', line) or re.match(r'\*\*(.+)\*\*', line):
                if current_section["content"]:
                    sections.append(current_section)
                
                section_name = re.sub(r'[#*]', '', line).strip().lower()
                current_section = {
                    "name": section_name,
                    "content": "",
                    "start_line": i
                }
            else:
                current_section["content"] += line + "\n"
        
        if current_section["content"]:
            sections.append(current_section)
        
        return sections
    
    def _check_required_elements(
        self, 
        spec: TechniqueSpec, 
        sections: List[Dict]
    ) -> List[str]:
        """Check for missing required elements"""
        missing = []
        
        for element in spec.required_elements:
            found = False
            
            for section in sections:
                # Check if section name matches element name
                if element.name in section["name"].lower():
                    found = True
                    break
                
                # Check if keywords appear in content
                if any(kw in section["content"].lower() for kw in element.keywords):
                    found = True
                    break
            
            if not found:
                missing.append(element.name)
        
        return missing
    
    def _check_sequence_order(
        self, 
        spec: TechniqueSpec, 
        sections: List[Dict]
    ) -> List[Dict]:
        """Check if elements appear in correct order"""
        violations = []
        
        detected_order = []
        for section in sections:
            for expected_name in spec.sequence_order:
                if expected_name in section["name"].lower():
                    detected_order.append(expected_name)
                    break
        
        for i, expected_name in enumerate(spec.sequence_order):
            if expected_name in detected_order:
                actual_index = detected_order.index(expected_name)
                if actual_index != i:
                    violations.append({
                        "element": expected_name,
                        "expected_position": i + 1,
                        "actual_position": actual_index + 1
                    })
        
        return violations
    
    def _check_duration(
        self, 
        spec: TechniqueSpec, 
        sections: List[Dict]
    ) -> List[Dict]:
        """Check if durations are appropriate"""
        issues = []
        
        # Extract total duration from script
        total_duration = 0
        for section in sections:
            # Look for duration markers like "Duration: X min" or "X minutes"
            duration_match = re.search(r'(\d+)\s*min', section["content"], re.IGNORECASE)
            if duration_match:
                total_duration += int(duration_match.group(1))
        
        if total_duration < spec.min_duration_minutes:
            issues.append({
                "type": "too_short",
                "expected_min": spec.min_duration_minutes,
                "actual": total_duration
            })
        elif total_duration > spec.max_duration_minutes:
            issues.append({
                "type": "too_long",
                "expected_max": spec.max_duration_minutes,
                "actual": total_duration
            })
        
        return issues
    
    def _check_validation_rules(
        self, 
        spec: TechniqueSpec, 
        sections: List[Dict]
    ) -> List[Dict]:
        """Check technique-specific validation rules"""
        violations = []
        
        for element in spec.required_elements:
            for rule in element.validation_rules:
                # Find relevant section
                relevant_section = None
                for section in sections:
                    if element.name in section["name"].lower():
                        relevant_section = section
                        break
                
                if not relevant_section:
                    continue
                
                # Check rule
                if "must include" in rule.lower():
                    # Extract what must be included
                    match = re.search(r"must include '(.+?)'", rule, re.IGNORECASE)
                    if match:
                        required_text = match.group(1).lower()
                        if required_text not in relevant_section["content"].lower():
                            violations.append({
                                "element": element.name,
                                "rule": rule,
                                "section": relevant_section["name"]
                            })
        
        return violations
    
    def _calculate_fidelity_score(
        self, 
        missing: List, 
        sequence: List, 
        rules: List
    ) -> float:
        """Calculate fidelity score 0-1"""
        total_issues = len(missing) + len(sequence) + len(rules)
        if total_issues == 0:
            return 1.0
        
        # Weight: missing elements = 0.5, sequence = 0.3, rules = 0.2
        penalty = (len(missing) * 0.5) + (len(sequence) * 0.3) + (len(rules) * 0.2)
        return max(0.0, 1.0 - (penalty / 5.0))
    
    def _generate_fixes(
        self,
        spec: TechniqueSpec,
        missing: List[str],
        sequence: List[Dict],
        duration: List[Dict],
        rules: List[Dict]
    ) -> List[Dict]:
        """Generate diff-style suggestions"""
        suggestions = []
        
        # Fix missing elements
        for element_name in missing:
            element = next(
                (e for e in spec.required_elements if e.name == element_name),
                None
            )
            if element:
                suggestions.append({
                    "type": "add",
                    "element": element_name,
                    "location": f"After {spec.sequence_order[spec.sequence_order.index(element_name) - 1] if spec.sequence_order.index(element_name) > 0 else 'intro'}",
                    "suggestion": f"""
--- Missing: {element.name} ({element.expected_duration_minutes} min)
+++ Add this section:

## {element.name.title()} ({element.expected_duration_minutes} minutes)

[Include: {', '.join(element.keywords)}]

[TODO: Write {element.name} content following these rules:
{chr(10).join(f'- {rule}' for rule in element.validation_rules)}]
"""
                })
        
        # Fix sequence violations
        for violation in sequence:
            suggestions.append({
                "type": "reorder",
                "element": violation["element"],
                "suggestion": f"""
--- {violation['element']} is at position {violation['actual_position']}
+++ Move {violation['element']} to position {violation['expected_position']}

Expected order: {' → '.join(spec.sequence_order)}
"""
            })
        
        # Fix duration issues
        for issue in duration:
            if issue["type"] == "too_short":
                suggestions.append({
                    "type": "extend",
                    "suggestion": f"""
--- Total duration: {issue['actual']} minutes (too short)
+++ Extend to at least: {issue['expected_min']} minutes

Consider adding:
- More reflection time
- Additional prompts
- Extended grounding close
"""
                })
            else:
                suggestions.append({
                    "type": "shorten",
                    "suggestion": f"""
--- Total duration: {issue['actual']} minutes (too long)
+++ Reduce to maximum: {issue['expected_max']} minutes

Consider reducing:
- Writing phase duration
- Number of prompts
- Reflection questions
"""
                })
        
        # Fix rule violations
        for violation in rules:
            suggestions.append({
                "type": "fix_rule",
                "element": violation["element"],
                "suggestion": f"""
--- Missing requirement in {violation['element']}
+++ {violation['rule']}

Location: {violation['section']}
"""
            })
        
        return suggestions
```

---

### Example Fidelity Check Output

```json
{
  "technique": "unsent_letter",
  "fidelity_score": 0.75,
  "missing_elements": ["intensity_assessment"],
  "sequence_violations": [],
  "duration_issues": [
    {
      "type": "too_short",
      "expected_min": 15,
      "actual": 12
    }
  ],
  "rule_violations": [
    {
      "element": "letter_writing",
      "rule": "Must remind 'This letter will NOT be sent'",
      "section": "letter_writing"
    }
  ],
  "suggestions": [
    {
      "type": "add",
      "element": "intensity_assessment",
      "location": "Before intention",
      "suggestion": "--- Missing: intensity_assessment (1 min)\n+++ Add this section:\n\n## Intensity Assessment (1 minute)\n\nBefore we begin, rate your emotional intensity around this person/situation on a scale of 1-5:\n1 = Minimal emotion\n5 = Very intense emotion\n\n[If intensity >= 4, reduce letter writing time to 10 minutes and add extra grounding]"
    },
    {
      "type": "extend",
      "suggestion": "--- Total duration: 12 minutes (too short)\n+++ Extend to at least: 15 minutes\n\nConsider adding:\n- Extend letter writing from 10 to 13 minutes\n- Add 2 minutes to integration reflection"
    },
    {
      "type": "fix_rule",
      "element": "letter_writing",
      "suggestion": "--- Missing requirement in letter_writing\n+++ Must remind 'This letter will NOT be sent'\n\nLocation: letter_writing\n\nAdd this reminder: 'Remember: This letter is for you. It will NOT be sent. This is a safe space to express anything.'"
    }
  ],
  "passed": false
}
```

---

## RECOMMENDED SESSION PLAN SCHEMA

```typescript
import { z } from 'zod'

export const SessionPlanSchema = z.object({
  // Core Identifiers
  session_id: z.string().uuid(),
  user_id: z.string().uuid(),
  
  // Session Configuration
  goal_area: z.enum(['relationships', 'career', 'personal', 'health', 'grief', 'trauma', 'anxiety', 'other']),
  technique: z.enum([
    'sprint',
    'inventory',
    'unsent_letter',
    'sentence_stems',
    'list_100',
    'non_dominant',
    'dialogue',
    'biographical',
    'inner_critic',
    'vulnerability',
    'forgiveness',
    'scribble',
    'bilateral_drawing',
    'six_phase_meditation'
  ]),
  duration_minutes: z.number().int().min(5).max(60),
  intensity: z.number().int().min(1).max(5),
  
  // Session Steps
  steps: z.array(z.object({
    type: z.enum(['grounding', 'assessment', 'exercise', 'reflection', 'integration', 'close']),
    minutes: z.number().int().min(1),
    script: z.string().optional(),
    prompt: z.string().optional(),
    questions: z.array(z.string()).optional(),
    guideposts: z.array(z.object({
      time_minutes: z.number(),
      message: z.string()
    })).optional()
  })),
  
  // XR Configuration
  xr_scene: z.object({
    preset: z.enum(['forest', 'garden', 'studio', 'space', 'temple', 'beach', 'mountain']),
    audio: z.array(z.string()),
    comfort_mode: z.boolean(),
    lighting_intensity: z.number().min(0).max(1).optional(),
    camera_height: z.number().optional()
  }).optional(),
  
  // Safety
  safety: z.object({
    status: z.enum(['green', 'yellow', 'red']),
    constraints: z.array(z.string()).optional(),
    notes: z.array(z.string()).optional(),
    escalation_required: z.boolean().optional()
  }),
  
  // E&P Adaptation
  ep_profile: z.object({
    physical_percentage: z.number().min(0).max(100),
    emotional_percentage: z.number().min(0).max(100),
    classification: z.enum(['Physical', 'Emotional', 'Hybrid']),
    language_style: z.enum(['direct', 'inferential', 'balanced'])
  }).optional(),
  
  // Metadata
  created_at: z.string().datetime(),
  created_by: z.enum(['ai', 'therapist', 'hybrid']),
  version: z.string()
})

export type SessionPlan = z.infer<typeof SessionPlanSchema>
```

---

### Example Session Plan

```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "goal_area": "relationships",
  "technique": "unsent_letter",
  "duration_minutes": 20,
  "intensity": 3,
  "steps": [
    {
      "type": "grounding",
      "minutes": 1,
      "script": "Take three deep breaths. Breathe in... hold... breathe out. Feel your feet on the floor. You are safe here."
    },
    {
      "type": "assessment",
      "minutes": 1,
      "prompt": "Rate your emotional intensity around this person/situation (1-5).",
      "questions": ["On a scale of 1-5, how intense is this emotion?"]
    },
    {
      "type": "exercise",
      "minutes": 15,
      "prompt": "Write an unsent letter to [person]. This letter will NOT be sent. It's for you.",
      "guideposts": [
        {
          "time_minutes": 5,
          "message": "You're doing great. Keep writing."
        },
        {
          "time_minutes": 10,
          "message": "Halfway there. What else needs to be said?"
        },
        {
          "time_minutes": 13,
          "message": "Two more minutes. Begin moving toward a close."
        }
      ]
    },
    {
      "type": "reflection",
      "minutes": 2,
      "questions": [
        "What did you learn from writing this?",
        "What are you releasing?",
        "What boundary do you need to set?"
      ]
    },
    {
      "type": "close",
      "minutes": 1,
      "script": "Take three closing breaths. You showed up for yourself today. That takes courage."
    }
  ],
  "xr_scene": {
    "preset": "garden",
    "audio": ["ambient_forest", "stream_water"],
    "comfort_mode": true,
    "lighting_intensity": 0.7,
    "camera_height": 1.6
  },
  "safety": {
    "status": "green",
    "constraints": [],
    "notes": ["User reported manageable intensity (3/5)", "No crisis indicators detected"],
    "escalation_required": false
  },
  "ep_profile": {
    "physical_percentage": 35,
    "emotional_percentage": 65,
    "classification": "Emotional",
    "language_style": "inferential"
  },
  "created_at": "2026-02-11T10:00:00Z",
  "created_by": "ai",
  "version": "1.0"
}
```

---

## PRACTICAL IMPLEMENTATION LOOP

```python
from typing import Dict
import asyncio

class SessionOrchestrator:
    """
    Complete loop: Safety → Intake → Technique → Plan → Scene → Narration → TTS → Eval → Save
    """
    
    def __init__(self):
        self.safety_guardian = SafetyGuardianClient()
        self.technique_selector = TechniqueSelector()
        self.plan_generator = SessionPlanGenerator()
        self.scene_generator = XRSceneGenerator()
        self.narration_generator = NarrationGenerator()
        self.tts_renderer = TTSRenderer()
        self.rubric_grader = ResponseRubricGrader()
        self.fidelity_checker = TechniqueFidelityChecker()
    
    async def orchestrate_session(self, user_input: Dict) -> Dict:
        """
        Full session orchestration pipeline
        """
        
        # STEP 1: Safety Screen
        safety_result = await self.safety_guardian.screen(
            user_id=user_input["user_id"],
            context="journaling_initiation",
            user_input=user_input.get("presenting_issue")
        )
        
        if safety_result["status"] == "red":
            return {
                "status": "blocked",
                "crisis_resources": safety_result["resources"],
                "message": "We've detected signs of distress. Please reach out to these resources."
            }
        
        # STEP 2: Intake (goal, intensity, timebox)
        intake_data = await self.conduct_intake(
            user_id=user_input["user_id"],
            goal_area=user_input.get("goal_area", "personal"),
            intensity=user_input.get("intensity", 3),
            available_time=user_input.get("available_time", 15)
        )
        
        # STEP 3: Technique Select
        technique = await self.technique_selector.select(
            ep_profile=user_input.get("ep_profile"),
            presenting_issue=intake_data["goal_area"],
            session_number=user_input.get("session_number", 1),
            recent_themes=user_input.get("recent_themes", []),
            safety_status=safety_result["status"],
            available_time=intake_data["available_time"]
        )
        
        # STEP 4: Generate SessionPlan JSON
        session_plan = await self.plan_generator.generate(
            user_id=user_input["user_id"],
            technique=technique["technique"],
            intake_data=intake_data,
            safety_constraints=safety_result.get("constraints", []),
            ep_profile=user_input.get("ep_profile")
        )
        
        # STEP 5: Generate XR SceneSpec JSON
        scene_spec = await self.scene_generator.generate(
            theme=session_plan["xr_scene"]["preset"],
            technique=technique["technique"],
            comfort_mode=session_plan["xr_scene"]["comfort_mode"]
        )
        
        # STEP 6: Generate narration chunks
        narration_chunks = await self.narration_generator.generate(
            session_plan=session_plan,
            ep_profile=user_input.get("ep_profile")
        )
        
        # STEP 7: Render TTS
        tts_files = await self.tts_renderer.render_chunks(
            chunks=narration_chunks,
            voice_id="sophia_calm"
        )
        
        # STEP 8: Run eval rubrics
        rubric_eval = await self.rubric_grader.evaluate_response(
            session_plan=session_plan,
            generated_script=self._compile_script(session_plan, narration_chunks),
            technique=technique["technique"]
        )
        
        fidelity_check = self.fidelity_checker.check_fidelity(
            technique=technique["technique"],
            session_script=self._compile_script(session_plan, narration_chunks)
        )
        
        # Check quality gates
        if not rubric_eval.passed_quality_gate or not fidelity_check["passed"]:
            # Log issues for human review
            await self.log_quality_issues(
                session_id=session_plan["session_id"],
                rubric_eval=rubric_eval,
                fidelity_check=fidelity_check
            )
            
            # Attempt auto-fix if possible
            if rubric_eval.overall_score >= 3.5:
                session_plan = await self.apply_suggested_fixes(
                    session_plan,
                    rubric_eval.suggested_fixes + fidelity_check["suggestions"]
                )
        
        # STEP 9: Save artifacts
        artifacts = await self.save_artifacts(
            session_plan=session_plan,
            scene_spec=scene_spec,
            narration_chunks=narration_chunks,
            tts_files=tts_files,
            rubric_eval=rubric_eval,
            fidelity_check=fidelity_check
        )
        
        return {
            "status": "ready",
            "session_id": session_plan["session_id"],
            "session_plan": session_plan,
            "scene_spec": scene_spec,
            "tts_files": tts_files,
            "quality_scores": {
                "rubric_overall": rubric_eval.overall_score,
                "fidelity_score": fidelity_check["fidelity_score"]
            },
            "artifacts": artifacts
        }
```

---

**STATUS:** E1 Rubric Grader + E2 Fidelity Checker + SessionPlan Schema + Implementation Loop Complete ✅

**Files:**
- Rubric grading with 5 dimensions (0-5 scale)
- Technique fidelity checker with diff-style suggestions
- Complete SessionPlan Zod schema
- End-to-end orchestration loop (9 steps)

**Ready for integration into platform.**
