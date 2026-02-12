"""
E&P Profile Generator
Generates detailed personality profiles based on E&P type
"""
from typing import Dict, List
from dataclasses import dataclass
import json

@dataclass
class PersonalityProfile:
    """Complete personality profile for an EP type"""
    ep_type: str
    title: str
    description: str
    strengths: List[str]
    challenges: List[str]
    communication_style: str
    relationship_dynamics: str
    therapeutic_approach: List[str]
    growth_opportunities: List[str]

class EPProfileGenerator:
    """Generates detailed profiles for all 16 EP personality types"""
    
    def __init__(self):
        self.profiles = self._generate_all_profiles()
    
    def get_profile(self, ep_type: str) -> PersonalityProfile:
        """Get the profile for a specific EP type"""
        return self.profiles.get(ep_type.upper(), self.profiles['PP'])
    
    def _generate_all_profiles(self) -> Dict[str, PersonalityProfile]:
        """Generate profiles for all EP types"""
        profiles = {}
        
        # PP - Physical-Physical
        profiles['PP'] = PersonalityProfile(
            ep_type='PP',
            title='The Doer - Physical-Physical',
            description='Highly action-oriented and direct. PP types are energetic, practical, and '
                       'focused on tangible results. They communicate directly and appreciate '
                       'straightforward, logical approaches.',
            strengths=[
                'Highly action-oriented and productive',
                'Direct and clear communication',
                'Practical problem-solving abilities',
                'Strong physical energy and stamina',
                'Logical and analytical thinking',
                'Independent and self-sufficient',
                'Quick decision-making'
            ],
            challenges=[
                'May appear insensitive to emotional needs',
                'Can be overly blunt or harsh',
                'May struggle with expressing feelings',
                'Tendency to be impatient',
                'May dismiss intuition or gut feelings',
                'Can have difficulty with emotional intimacy'
            ],
            communication_style='Direct, factual, and to-the-point. Prefers action over discussion. '
                              'Values efficiency and clarity.',
            relationship_dynamics='Best with partners who appreciate directness. Needs physical '
                                 'connection and shared activities. May need to work on emotional expression.',
            therapeutic_approach=[
                'Use direct, solution-focused interventions',
                'Incorporate physical relaxation techniques',
                'Set clear, measurable goals',
                'Keep sessions structured and time-efficient',
                'Use literal, specific suggestions'
            ],
            growth_opportunities=[
                'Developing emotional awareness',
                'Learning to express feelings verbally',
                'Practicing patience and empathy',
                'Balancing action with reflection'
            ]
        )
        
        # PE - Physical-Emotional
        profiles['PE'] = PersonalityProfile(
            ep_type='PE',
            title='The Balanced Doer - Physical-Emotional',
            description='Action-oriented with emotional depth. PE types combine practical efficiency '
                       'with emotional awareness. They can be direct when needed but also sensitive '
                       'to feelings.',
            strengths=[
                'Balance of logic and emotion',
                'Practical yet empathetic',
                'Can adapt communication style',
                'Strong intuition backed by action',
                'Good at reading situations',
                'Versatile problem-solving',
                'Ability to bridge different personality types'
            ],
            challenges=[
                'May experience internal conflict between head and heart',
                'Can be inconsistent in communication style',
                'May struggle to know which approach to use',
                'Potential for overthinking decisions',
                'May feel torn between action and reflection'
            ],
            communication_style='Adaptable - can be direct or gentle depending on situation. '
                              'Values both efficiency and consideration.',
            relationship_dynamics='Versatile in relationships. Can meet both physical and emotional '
                                 'needs. Best with partners who appreciate flexibility.',
            therapeutic_approach=[
                'Use combination of direct and indirect suggestions',
                'Balance physical and emotional interventions',
                'Acknowledge both logical and feeling aspects',
                'Offer choices between approaches',
                'Use metaphors that include both action and emotion'
            ],
            growth_opportunities=[
                'Integrating physical and emotional aspects',
                'Trusting inner balance',
                'Reducing internal conflict',
                'Accepting versatility as strength'
            ]
        )
        
        # EP - Emotional-Physical
        profiles['EP'] = PersonalityProfile(
            ep_type='EP',
            title='The Feeling Activist - Emotional-Physical',
            description='Emotionally driven with physical expression. EP types lead with their hearts '
                       'but aren\'t afraid to take action. They combine emotional depth with '
                       'practical capability.',
            strengths=[
                'Deep emotional intelligence',
                'Compassionate yet action-oriented',
                'Strong intuitive abilities',
                'Good at emotional and practical support',
                'Can inspire and motivate others',
                'Balanced sensitivity and strength',
                'Authentic emotional expression'
            ],
            challenges=[
                'May take things too personally',
                'Can be emotionally reactive',
                'May struggle with objectivity',
                'Tendency to over-empathize',
                'May have difficulty with purely logical decisions',
                'Can be inconsistent in approach'
            ],
            communication_style='Emotionally expressive with practical follow-through. Values '
                              'authentic connection with concrete action.',
            relationship_dynamics='Needs emotional intimacy and physical connection. Best with '
                                 'partners who value both feeling and doing.',
            therapeutic_approach=[
                'Start with emotional validation',
                'Use feeling-based language',
                'Incorporate physical relaxation after emotional work',
                'Use metaphors and imagery',
                'Allow time for emotional processing'
            ],
            growth_opportunities=[
                'Developing objectivity when needed',
                'Learning to depersonalize situations',
                'Balancing empathy with boundaries',
                'Strengthening logical decision-making'
            ]
        )
        
        # EE - Emotional-Emotional
        profiles['EE'] = PersonalityProfile(
            ep_type='EE',
            title='The Empath - Emotional-Emotional',
            description='Deeply feeling and intuitive. EE types are highly sensitive, empathetic, '
                       'and emotionally aware. They value connection, understanding, and harmony.',
            strengths=[
                'Exceptional emotional intelligence',
                'Deep empathy and compassion',
                'Strong intuitive abilities',
                'Excellent at emotional support',
                'Values relationships and connection',
                'Sensitive to subtle emotional cues',
                'Creative and imaginative'
            ],
            challenges=[
                'Can be overly sensitive',
                'May struggle with practical matters',
                'Tendency to avoid conflict',
                'Can be indecisive',
                'May absorb others\' emotions',
                'Difficulty setting boundaries',
                'May need frequent emotional reassurance'
            ],
            communication_style='Gentle, considerate, and emotionally expressive. Values harmony '
                              'and understanding over directness.',
            relationship_dynamics='Needs deep emotional connection and understanding. Best with '
                                 'partners who are emotionally available and communicative.',
            therapeutic_approach=[
                'Use gentle, indirect suggestions',
                'Create safe, nurturing environment',
                'Use metaphors, stories, and imagery',
                'Allow ample time for emotional processing',
                'Validate feelings throughout session',
                'Use permissive rather than authoritative language'
            ],
            growth_opportunities=[
                'Developing practical skills',
                'Setting healthy boundaries',
                'Building emotional resilience',
                'Learning to balance emotion with logic',
                'Developing assertiveness'
            ]
        )
        
        return profiles
    
    def generate_therapeutic_recommendations(self, ep_type: str, 
                                            presenting_issue: str = None) -> Dict:
        """Generate therapeutic recommendations for specific EP type"""
        profile = self.get_profile(ep_type)
        
        recommendations = {
            'ep_type': ep_type,
            'induction_style': self._get_induction_style(ep_type),
            'deepening_technique': self._get_deepening_technique(ep_type),
            'suggestion_style': self._get_suggestion_style(ep_type),
            'session_structure': self._get_session_structure(ep_type),
            'therapeutic_focus': profile.therapeutic_approach,
            'contraindications': self._get_contraindications(ep_type)
        }
        
        return recommendations
    
    def _get_induction_style(self, ep_type: str) -> str:
        """Recommend induction style based on EP type"""
        if ep_type in ['PP', 'PE']:
            return 'Progressive relaxation with physical focus'
        else:
            return 'Visualization and imagery-based induction'
    
    def _get_deepening_technique(self, ep_type: str) -> str:
        """Recommend deepening technique"""
        if ep_type in ['PP', 'PE']:
            return 'Counting down with physical sensations'
        else:
            return 'Descending stairs or elevator with emotional comfort'
    
    def _get_suggestion_style(self, ep_type: str) -> str:
        """Recommend suggestion delivery style"""
        styles = {
            'PP': 'Direct, authoritative, literal',
            'PE': 'Mix of direct and indirect',
            'EP': 'Gentle with action elements',
            'EE': 'Indirect, permissive, metaphorical'
        }
        return styles.get(ep_type, 'Balanced approach')
    
    def _get_session_structure(self, ep_type: str) -> Dict:
        """Recommend session structure and timing"""
        if ep_type in ['PP', 'PE']:
            return {
                'pace': 'Efficient and structured',
                'session_length': '30-45 minutes',
                'focus': 'Problem-solving and action plans'
            }
        else:
            return {
                'pace': 'Relaxed and flexible',
                'session_length': '45-60 minutes',
                'focus': 'Emotional processing and insight'
            }
    
    def _get_contraindications(self, ep_type: str) -> List[str]:
        """Identify potential contraindications or cautions"""
        contraindications = {
            'PP': [
                'Avoid overly emotional or feeling-focused language',
                'Don\'t use prolonged silence',
                'Limit abstract concepts without concrete applications'
            ],
            'PE': [
                'Avoid being too rigid or too loose in structure',
                'Balance logic and emotion in explanations'
            ],
            'EP': [
                'Be careful with purely logical arguments',
                'Don\'t rush emotional processing',
                'Avoid dismissing feelings'
            ],
            'EE': [
                'Avoid harsh or direct language',
                'Don\'t rush through material',
                'Be cautious with confrontation',
                'Limit purely analytical approaches'
            ]
        }
        return contraindications.get(ep_type, [])
    
    def export_profile(self, ep_type: str, filepath: str):
        """Export complete profile to JSON"""
        profile = self.get_profile(ep_type)
        recommendations = self.generate_therapeutic_recommendations(ep_type)
        
        output = {
            'ep_type': profile.ep_type,
            'title': profile.title,
            'description': profile.description,
            'strengths': profile.strengths,
            'challenges': profile.challenges,
            'communication_style': profile.communication_style,
            'relationship_dynamics': profile.relationship_dynamics,
            'therapeutic_approach': profile.therapeutic_approach,
            'growth_opportunities': profile.growth_opportunities,
            'therapeutic_recommendations': recommendations
        }
        
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(output, f, indent=2, ensure_ascii=False)

if __name__ == '__main__':
    # Test profile generation
    print("Testing E&P Profile Generator...")
    
    generator = EPProfileGenerator()
    
    for ep_type in ['PP', 'PE', 'EP', 'EE']:
        profile = generator.get_profile(ep_type)
        print(f"\n{profile.title}")
        print(f"  Strengths: {len(profile.strengths)}")
        print(f"  Challenges: {len(profile.challenges)}")
        print(f"  Growth areas: {len(profile.growth_opportunities)}")
        
        # Export each profile
        generator.export_profile(ep_type, f'profile_{ep_type}.json')
    
    print(f"\nAll profiles exported!")
