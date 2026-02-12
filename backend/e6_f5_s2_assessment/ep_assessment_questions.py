"""
E&P Assessment Questions Database
45 questions based on Four Core Traits theory from HMI
"""
from typing import List, Dict
from dataclasses import dataclass
import json

@dataclass
class AssessmentQuestion:
    """Represents a single E&P assessment question"""
    id: int
    question_text: str
    trait_assessed: str  # 'logical', 'physical', 'emotional', 'communication'
    physical_response: str
    emotional_response: str
    scoring_key: Dict[str, int]

class EPAssessmentQuestions:
    """Database of 45 E&P assessment questions"""
    
    def __init__(self):
        self.questions = self._generate_questions()
    
    def _generate_questions(self) -> List[AssessmentQuestion]:
        """Generate 45 assessment questions based on Four Core Traits"""
        
        questions = []
        
        # LOGICAL TRAIT QUESTIONS (10 questions)
        logical_questions = [
            {
                'id': 1,
                'text': 'When making important decisions, I primarily rely on:',
                'physical': 'Facts, data, and logical analysis',
                'emotional': 'My feelings and intuition'
            },
            {
                'id': 2,
                'text': 'In problem-solving situations, I prefer to:',
                'physical': 'Break things down systematically',
                'emotional': 'Go with what feels right'
            },
            {
                'id': 3,
                'text': 'When someone asks for my advice, I tend to:',
                'physical': 'Give them logical solutions',
                'emotional': 'Listen and empathize with their feelings'
            },
            {
                'id': 4,
                'text': 'I value being right more than being liked',
                'physical': 'Strongly agree',
                'emotional': 'Strongly disagree'
            },
            {
                'id': 5,
                'text': 'In arguments, I focus on:',
                'physical': 'The facts and logic of my position',
                'emotional': 'How the other person is feeling'
            },
            {
                'id': 6,
                'text': 'I make lists and plans for most activities',
                'physical': 'Yes, very often',
                'emotional': 'No, I prefer to be spontaneous'
            },
            {
                'id': 7,
                'text': 'When reading, I prefer:',
                'physical': 'Non-fiction, factual material',
                'emotional': 'Fiction, emotional stories'
            },
            {
                'id': 8,
                'text': 'I am known for being:',
                'physical': 'Analytical and rational',
                'emotional': 'Warm and empathetic'
            },
            {
                'id': 9,
                'text': 'In group settings, I tend to:',
                'physical': 'Focus on the task at hand',
                'emotional': 'Focus on group harmony'
            },
            {
                'id': 10,
                'text': 'I trust my head over my heart',
                'physical': 'Most of the time',
                'emotional': 'Rarely'
            }
        ]
        
        for q in logical_questions:
            questions.append(AssessmentQuestion(
                id=q['id'],
                question_text=q['text'],
                trait_assessed='logical',
                physical_response=q['physical'],
                emotional_response=q['emotional'],
                scoring_key={'physical': 1, 'emotional': 0}
            ))
        
        # PHYSICAL TRAIT QUESTIONS (12 questions)
        physical_questions = [
            {
                'id': 11,
                'text': 'I prefer activities that involve:',
                'physical': 'Physical action and movement',
                'emotional': 'Quiet reflection and thought'
            },
            {
                'id': 12,
                'text': 'When stressed, I feel it:',
                'physical': 'In my body (tension, headaches, etc.)',
                'emotional': 'In my emotions (anxiety, sadness, etc.)'
            },
            {
                'id': 13,
                'text': 'I learn best by:',
                'physical': 'Doing and hands-on practice',
                'emotional': 'Observing and thinking'
            },
            {
                'id': 14,
                'text': 'My ideal vacation would be:',
                'physical': 'Active and adventurous',
                'emotional': 'Relaxing and peaceful'
            },
            {
                'id': 15,
                'text': 'I express affection through:',
                'physical': 'Touch and physical closeness',
                'emotional': 'Words and emotional sharing'
            },
            {
                'id': 16,
                'text': 'When angry, I tend to:',
                'physical': 'Show it physically (body language, actions)',
                'emotional': 'Feel it deeply inside'
            },
            {
                'id': 17,
                'text': 'I am generally:',
                'physical': 'High energy and active',
                'emotional': 'Calm and contemplative'
            },
            {
                'id': 18,
                'text': 'In relationships, I need:',
                'physical': 'Physical intimacy and touch',
                'emotional': 'Emotional connection and understanding'
            },
            {
                'id': 19,
                'text': 'I prefer to communicate:',
                'physical': 'Face-to-face with physical presence',
                'emotional': 'Through words (written or spoken)'
            },
            {
                'id': 20,
                'text': 'My energy level is typically:',
                'physical': 'High and outwardly expressed',
                'emotional': 'Lower and internally focused'
            },
            {
                'id': 21,
                'text': 'I recharge by:',
                'physical': 'Being active and doing things',
                'emotional': 'Being quiet and reflective'
            },
            {
                'id': 22,
                'text': 'Physical fitness is:',
                'physical': 'Very important to me',
                'emotional': 'Less of a priority'
            }
        ]
        
        for q in physical_questions:
            questions.append(AssessmentQuestion(
                id=q['id'],
                question_text=q['text'],
                trait_assessed='physical',
                physical_response=q['physical'],
                emotional_response=q['emotional'],
                scoring_key={'physical': 1, 'emotional': 0}
            ))
        
        # EMOTIONAL TRAIT QUESTIONS (12 questions)
        emotional_questions = [
            {
                'id': 23,
                'text': 'I express my feelings:',
                'physical': 'Rarely, I keep them to myself',
                'emotional': 'Openly and frequently'
            },
            {
                'id': 24,
                'text': 'When someone is upset, I:',
                'physical': 'Try to fix the problem',
                'emotional': 'Listen and provide emotional support'
            },
            {
                'id': 25,
                'text': 'I cry:',
                'physical': 'Rarely or never',
                'emotional': 'Fairly easily'
            },
            {
                'id': 26,
                'text': 'I am in touch with my emotions',
                'physical': 'Not really',
                'emotional': 'Very much so'
            },
            {
                'id': 27,
                'text': 'I can sense what others are feeling',
                'physical': 'Sometimes',
                'emotional': 'Almost always'
            },
            {
                'id': 28,
                'text': 'I make decisions based on:',
                'physical': 'What makes sense logically',
                'emotional': 'What feels right emotionally'
            },
            {
                'id': 29,
                'text': 'When watching emotional movies, I:',
                'physical': 'Remain composed',
                'emotional': 'Get very emotional'
            },
            {
                'id': 30,
                'text': 'I am comfortable discussing feelings',
                'physical': 'Not really',
                'emotional': 'Yes, very much'
            },
            {
                'id': 31,
                'text': 'My friends would describe me as:',
                'physical': 'Strong and stoic',
                'emotional': 'Sensitive and caring'
            },
            {
                'id': 32,
                'text': 'I take criticism:',
                'physical': 'Objectively, without personal feelings',
                'emotional': 'Very personally'
            },
            {
                'id': 33,
                'text': 'I trust my gut feelings',
                'physical': 'Not usually',
                'emotional': 'Almost always'
            },
            {
                'id': 34,
                'text': 'Emotional intimacy is:',
                'physical': 'Difficult for me',
                'emotional': 'Essential to me'
            }
        ]
        
        for q in emotional_questions:
            questions.append(AssessmentQuestion(
                id=q['id'],
                question_text=q['text'],
                trait_assessed='emotional',
                physical_response=q['physical'],
                emotional_response=q['emotional'],
                scoring_key={'physical': 0, 'emotional': 1}
            ))
        
        # COMMUNICATION TRAIT QUESTIONS (11 questions)
        communication_questions = [
            {
                'id': 35,
                'text': 'When speaking, I am:',
                'physical': 'Direct and to the point',
                'emotional': 'Gentle and considerate'
            },
            {
                'id': 36,
                'text': 'I prefer communication that is:',
                'physical': 'Clear, factual, and specific',
                'emotional': 'Warm, personal, and relational'
            },
            {
                'id': 37,
                'text': 'In conversations, I focus on:',
                'physical': 'The facts and information',
                'emotional': 'The feelings and relationships'
            },
            {
                'id': 38,
                'text': 'I give compliments:',
                'physical': 'Rarely',
                'emotional': 'Frequently'
            },
            {
                'id': 39,
                'text': 'When someone tells me a problem, I:',
                'physical': 'Immediately offer solutions',
                'emotional': 'Listen empathetically first'
            },
            {
                'id': 40,
                'text': 'My communication style is:',
                'physical': 'Blunt and honest',
                'emotional': 'Tactful and diplomatic'
            },
            {
                'id': 41,
                'text': 'I prefer:',
                'physical': 'Written communication (email, text)',
                'emotional': 'Verbal communication (phone, in-person)'
            },
            {
                'id': 42,
                'text': 'In conflict, I:',
                'physical': 'State my position clearly',
                'emotional': 'Try to understand all perspectives'
            },
            {
                'id': 43,
                'text': 'I am comfortable with:',
                'physical': 'Silence in conversations',
                'emotional': 'Continuous dialogue'
            },
            {
                'id': 44,
                'text': 'I express appreciation through:',
                'physical': 'Actions rather than words',
                'emotional': 'Words and emotional expression'
            },
            {
                'id': 45,
                'text': 'My speaking pace is typically:',
                'physical': 'Fast and efficient',
                'emotional': 'Slower and more expressive'
            }
        ]
        
        for q in communication_questions:
            questions.append(AssessmentQuestion(
                id=q['id'],
                question_text=q['text'],
                trait_assessed='communication',
                physical_response=q['physical'],
                emotional_response=q['emotional'],
                scoring_key={'physical': 1, 'emotional': 0}
            ))
        
        return questions
    
    def get_all_questions(self) -> List[AssessmentQuestion]:
        """Return all 45 questions"""
        return self.questions
    
    def get_questions_by_trait(self, trait: str) -> List[AssessmentQuestion]:
        """Get questions for a specific trait"""
        return [q for q in self.questions if q.trait_assessed == trait]
    
    def export_to_json(self, filepath: str):
        """Export questions to JSON file"""
        questions_data = [
            {
                'id': q.id,
                'question_text': q.question_text,
                'trait_assessed': q.trait_assessed,
                'physical_response': q.physical_response,
                'emotional_response': q.emotional_response,
                'scoring_key': q.scoring_key
            }
            for q in self.questions
        ]
        
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(questions_data, f, indent=2, ensure_ascii=False)

if __name__ == '__main__':
    # Test: Generate and display questions
    questions = EPAssessmentQuestions()
    
    print(f"Total questions: {len(questions.get_all_questions())}")
    print(f"\nBy trait:")
    for trait in ['logical', 'physical', 'emotional', 'communication']:
        count = len(questions.get_questions_by_trait(trait))
        print(f"  {trait}: {count} questions")
    
    # Export to JSON
    questions.export_to_json('ep_assessment_questions.json')
    print(f"\nExported to: ep_assessment_questions.json")
