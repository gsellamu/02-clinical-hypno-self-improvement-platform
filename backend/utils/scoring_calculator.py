"""
HMI E and P Suggestibility Scoring Calculator
Implements official HMI scoring methodology from Panorama Publishing 2003
"""
from typing import Dict, List, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import text

class SuggestibilityScorer:
    """
    Official HMI E and P Suggestibility scoring calculator.
    
    Scoring Rules:
    - Questions 1-2: 10 points each for "yes"
    - Questions 3-18: 5 points each for "yes"
    - Questions 19-20: 10 points each for "yes"
    - Questions 21-36: 5 points each for "yes"
    - Q1 Score: Sum of questions 1-18
    - Q2 Score: Sum of questions 19-36
    - Combined Score: Q1 + Q2
    - Physical %: Lookup from official HMI chart
    - Emotional %: 100 - Physical %
    """
    
    # Official HMI weights
    Q1_HIGH_WEIGHT_QUESTIONS = [1, 2]           # 10 points each
    Q1_STANDARD_WEIGHT_QUESTIONS = list(range(3, 19))  # 5 points each (3-18)
    Q2_HIGH_WEIGHT_QUESTIONS = [19, 20]         # 10 points each
    Q2_STANDARD_WEIGHT_QUESTIONS = list(range(21, 37)) # 5 points each (21-36)
    
    HIGH_WEIGHT_POINTS = 10
    STANDARD_WEIGHT_POINTS = 5
    
    MAX_Q1_SCORE = 100  # (2  10) + (16  5)
    MAX_Q2_SCORE = 100  # (2  10) + (16  5)
    MAX_COMBINED_SCORE = 200
    
    def __init__(self, db: Session):
        self.db = db
    
    def calculate_scores(
        self,
        answers: Dict[int, bool],
        questionnaire_version_id: str
    ) -> Dict:
        """
        Calculate E and P Suggestibility scores from answers.
        
        Args:
            answers: Dict mapping question_number (1-36) to boolean answer
            questionnaire_version_id: UUID of questionnaire version
            
        Returns:
            Dict containing all scores and interpretation
        """
        # Validate answers
        if len(answers) != 36:
            raise ValueError(f"Expected 36 answers, got {len(answers)}")
        
        # Calculate Q1 Score (Physical indicators)
        q1_score = self._calculate_q1_score(answers)
        
        # Calculate Q2 Score (Emotional indicators)
        q2_score = self._calculate_q2_score(answers)
        
        # Combined score
        combined_score = q1_score + q2_score
        
        # Round to nearest 5 for lookup (HMI chart uses increments of 5)
        q1_lookup = self._round_to_nearest_5(q1_score)
        combined_lookup = self._round_to_nearest_5(combined_score)
        
        # Get physical percentage from lookup table
        physical_percentage = self._lookup_physical_percentage(
            q1_lookup,
            combined_lookup,
            questionnaire_version_id
        )
        
        # Calculate emotional percentage
        emotional_percentage = 100 - physical_percentage
        
        # Determine suggestibility type
        suggestibility_type = self._determine_type(physical_percentage)
        
        return {
            "q1_score": q1_score,
            "q2_score": q2_score,
            "combined_score": combined_score,
            "q1_lookup": q1_lookup,
            "combined_lookup": combined_lookup,
            "physical_percentage": physical_percentage,
            "emotional_percentage": emotional_percentage,
            "suggestibility_type": suggestibility_type,
            "interpretation": self._generate_interpretation(
                physical_percentage,
                emotional_percentage,
                suggestibility_type
            )
        }
    
    def _calculate_q1_score(self, answers: Dict[int, bool]) -> int:
        """Calculate Questionnaire 1 score (Physical indicators)."""
        score = 0
        
        # High weight questions (1-2): 10 points each
        for q_num in self.Q1_HIGH_WEIGHT_QUESTIONS:
            if answers.get(q_num, False):
                score += self.HIGH_WEIGHT_POINTS
        
        # Standard weight questions (3-18): 5 points each
        for q_num in self.Q1_STANDARD_WEIGHT_QUESTIONS:
            if answers.get(q_num, False):
                score += self.STANDARD_WEIGHT_POINTS
        
        return min(score, self.MAX_Q1_SCORE)
    
    def _calculate_q2_score(self, answers: Dict[int, bool]) -> int:
        """Calculate Questionnaire 2 score (Emotional indicators)."""
        score = 0
        
        # High weight questions (19-20): 10 points each
        for q_num in self.Q2_HIGH_WEIGHT_QUESTIONS:
            if answers.get(q_num, False):
                score += self.HIGH_WEIGHT_POINTS
        
        # Standard weight questions (21-36): 5 points each
        for q_num in self.Q2_STANDARD_WEIGHT_QUESTIONS:
            if answers.get(q_num, False):
                score += self.STANDARD_WEIGHT_POINTS
        
        return min(score, self.MAX_Q2_SCORE)
    
    def _round_to_nearest_5(self, score: int) -> int:
        """Round score to nearest 5 for HMI lookup table."""
        return round(score / 5) * 5
    
    def _lookup_physical_percentage(
        self,
        q1_score: int,
        combined_score: int,
        questionnaire_version_id: str
    ) -> int:
        """
        Lookup physical percentage from HMI chart.
        
        Uses official HMI lookup table seeded in database.
        """
        # Clamp scores to valid ranges
        q1_score = max(0, min(100, q1_score))
        combined_score = max(50, min(200, combined_score))
        
        query = text("""
            SELECT physical_percentage
            FROM scoring_lookup_tables
            WHERE questionnaire_version_id = :version_id
                AND lookup_type = 'physical_percentage'
                AND q1_score = :q1_score
                AND combined_score = :combined_score
            LIMIT 1
        """)
        
        result = self.db.execute(
            query,
            {
                "version_id": questionnaire_version_id,
                "q1_score": q1_score,
                "combined_score": combined_score
            }
        ).fetchone()
        
        if not result:
            raise ValueError(
                f"No lookup entry found for Q1={q1_score}, "
                f"Combined={combined_score}"
            )
        
        return result[0]
    
    def _determine_type(self, physical_percentage: int) -> str:
        """
        Determine suggestibility type based on physical percentage.
        
        HMI Classifications:
        - Pure Physical: 90-100%
        - Primarily Physical: 60-89%
        - Somnambulistic: 40-59% (balanced)
        - Primarily Emotional: 11-39%
        - Pure Emotional: 0-10%
        """
        if physical_percentage >= 90:
            return "Pure Physical"
        elif physical_percentage >= 60:
            return "Primarily Physical"
        elif physical_percentage >= 40:
            return "Somnambulistic (Balanced)"
        elif physical_percentage >= 11:
            return "Primarily Emotional"
        else:
            return "Pure Emotional"
    
    def _generate_interpretation(
        self,
        physical_pct: int,
        emotional_pct: int,
        sugg_type: str
    ) -> Dict:
        """Generate clinical interpretation of scores."""
        
        # Physical Suggestibility characteristics
        physical_traits = []
        if physical_pct >= 60:
            physical_traits = [
                "Responds to direct, literal suggestions",
                "Prefers clear, straightforward communication",
                "Strong mind-body connection",
                "Learns best through demonstration",
                "Immediate physical response to suggestions"
            ]
        
        # Emotional Suggestibility characteristics
        emotional_traits = []
        if emotional_pct >= 60:
            emotional_traits = [
                "Responds to inferential, metaphorical suggestions",
                "Analytical and introspective",
                "Sensitivity to tone and emotional context",
                "May experience mind-body disconnection",
                "Benefits from indirect therapeutic approaches"
            ]
        
        # Therapeutic recommendations
        if physical_pct >= 60:
            therapy_approach = {
                "induction_style": "Direct, authoritative",
                "suggestion_format": "Literal, specific commands",
                "language_style": "Clear, concrete, step-by-step",
                "deepening": "Progressive relaxation, counting",
                "imagery": "Concrete, visual, kinesthetic"
            }
        elif emotional_pct >= 60:
            therapy_approach = {
                "induction_style": "Permissive, conversational",
                "suggestion_format": "Metaphorical, story-based",
                "language_style": "Abstract, inferential, open-ended",
                "deepening": "Confusion, paradox, time distortion",
                "imagery": "Abstract concepts, emotions, meanings"
            }
        else:  # Somnambulistic (balanced)
            therapy_approach = {
                "induction_style": "Flexible, adaptive",
                "suggestion_format": "Mix of direct and inferential",
                "language_style": "Varied - can use both styles",
                "deepening": "Any method works well",
                "imagery": "Both concrete and abstract"
            }
        
        return {
            "suggestibility_type": sugg_type,
            "physical_percentage": physical_pct,
            "emotional_percentage": emotional_pct,
            "physical_traits": physical_traits,
            "emotional_traits": emotional_traits,
            "therapeutic_approach": therapy_approach,
            "clinical_notes": self._get_clinical_notes(sugg_type)
        }
    
    def _get_clinical_notes(self, sugg_type: str) -> str:
        """Get clinical notes for suggestibility type."""
        notes = {
            "Pure Physical": (
                "Client demonstrates strong direct suggestibility. "
                "Use authoritative, direct inductions with literal suggestions. "
                "Excellent response to progressive relaxation and direct imagery."
            ),
            "Primarily Physical": (
                "Client leans toward physical suggestibility. "
                "Primarily use direct suggestions with some inferential elements. "
                "Good response to structured, clear therapeutic approaches."
            ),
            "Somnambulistic (Balanced)": (
                "Client shows balanced suggestibility - the 'ideal' hypnotic subject. "
                "Can utilize both direct and inferential approaches effectively. "
                "Highly flexible and responsive to various induction styles."
            ),
            "Primarily Emotional": (
                "Client leans toward emotional suggestibility. "
                "Primarily use inferential, metaphorical suggestions. "
                "Benefits from permissive, conversational approaches."
            ),
            "Pure Emotional": (
                "Client demonstrates strong emotional suggestibility. "
                "Use indirect, metaphorical, story-based approaches. "
                "Avoid authoritative tone; use permissive suggestions."
            )
        }
        return notes.get(sugg_type, "")


def get_answer_breakdown(
    answers: Dict[int, bool],
    db: Session,
    questionnaire_version_id: str
) -> Dict:
    """
    Get detailed breakdown of answers by category.
    
    Returns analysis showing which physical/emotional indicators
    the client answered yes/no to.
    """
    physical_yes = []
    physical_no = []
    emotional_yes = []
    emotional_no = []
    
    # Get questions from database
    query = text("""
        SELECT question_number, question_text, category
        FROM questionnaire_questions
        WHERE questionnaire_version_id = :version_id
        ORDER BY question_number
    """)
    
    questions = db.execute(
        query,
        {"version_id": questionnaire_version_id}
    ).fetchall()
    
    for q_num, q_text, category in questions:
        answered_yes = answers.get(q_num, False)
        
        if category == 'physical':
            if answered_yes:
                physical_yes.append({"number": q_num, "text": q_text})
            else:
                physical_no.append({"number": q_num, "text": q_text})
        else:  # emotional
            if answered_yes:
                emotional_yes.append({"number": q_num, "text": q_text})
            else:
                emotional_no.append({"number": q_num, "text": q_text})
    
    return {
        "physical_indicators": {
            "yes_count": len(physical_yes),
            "no_count": len(physical_no),
            "yes_answers": physical_yes,
            "no_answers": physical_no
        },
        "emotional_indicators": {
            "yes_count": len(emotional_yes),
            "no_count": len(emotional_no),
            "yes_answers": emotional_yes,
            "no_answers": emotional_no
        }
    }
