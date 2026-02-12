"""
E&P Theory Parser
Parses extracted text to identify and structure E&P theory concepts
"""
import re
import json
from typing import Dict, List, Optional
from dataclasses import dataclass
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@dataclass
class EPConcept:
    """Represents an E&P theory concept"""
    name: str
    category: str
    description: str
    details: Dict
    page_references: List[int]

class EPTheoryParser:
    """Parses E&P workbook content for theoretical concepts"""
    
    FOUR_CORE_TRAITS_KEYWORDS = [
        'four core traits', 'logical', 'physical trait', 'emotional trait',
        'communication', 'dominance', 'subdominance'
    ]
    
    RELATIONSHIP_KEYWORDS = [
        'relationship pattern', 'compatibility', 'primary caretaker',
        'secondary caretaker', 'honeymoon stage', 'relationship dynamics'
    ]
    
    ASSESSMENT_KEYWORDS = [
        'assessment', 'questionnaire', 'scoring', 'evaluation',
        'determining type', 'identifying'
    ]
    
    def __init__(self, extracted_json_path: str):
        with open(extracted_json_path, 'r', encoding='utf-8') as f:
            self.data = json.load(f)
        self.workbook_name = self.data['workbook_name']
        self.pages = self.data['pages']
        self.concepts: List[EPConcept] = []
    
    def parse_all_concepts(self) -> List[EPConcept]:
        """Parse all concepts from the workbook"""
        logger.info(f"Parsing concepts from {self.workbook_name}...")
        
        self._parse_four_core_traits()
        self._parse_relationship_patterns()
        self._parse_assessment_concepts()
        
        logger.info(f"[SUCCESS] Parsed {len(self.concepts)} concepts")
        return self.concepts
    
    def _parse_four_core_traits(self):
        """Parse Four Core Traits theory"""
        logger.info("   Parsing Four Core Traits...")
        
        traits = {
            'logical': {'pages': [], 'content': []},
            'physical': {'pages': [], 'content': []},
            'emotional': {'pages': [], 'content': []},
            'communication': {'pages': [], 'content': []}
        }
        
        for page in self.pages:
            text_lower = page['raw_text'].lower()
            
            if any(keyword in text_lower for keyword in self.FOUR_CORE_TRAITS_KEYWORDS):
                for trait_name in traits.keys():
                    if trait_name in text_lower:
                        traits[trait_name]['pages'].append(page['page_number'])
                        traits[trait_name]['content'].append(page['raw_text'])
        
        for trait_name, trait_data in traits.items():
            if trait_data['content']:
                concept = EPConcept(
                    name=f"{trait_name.capitalize()} Trait",
                    category='four_core_traits',
                    description=f"The {trait_name} trait in E&P Sexuality theory",
                    details={
                        'trait_name': trait_name,
                        'content_excerpts': [c[:500] for c in trait_data['content'][:3]]
                    },
                    page_references=trait_data['pages']
                )
                self.concepts.append(concept)
    
    def _parse_relationship_patterns(self):
        """Parse relationship patterns"""
        logger.info("   Parsing Relationship Patterns...")
        
        patterns_found = []
        
        for page in self.pages:
            text = page['raw_text']
            text_lower = text.lower()
            
            if any(keyword in text_lower for keyword in self.RELATIONSHIP_KEYWORDS):
                ep_patterns = re.findall(r'\b([PE]{2})\s+(relationship|couple|pattern|dynamic)', 
                                        text, re.IGNORECASE)
                
                for pattern, _ in ep_patterns:
                    patterns_found.append({
                        'name': f"{pattern.upper()} Relationship Pattern",
                        'page': page['page_number'],
                        'context': text[:500]
                    })
        
        unique_patterns = {}
        for pattern in patterns_found:
            name = pattern['name']
            if name not in unique_patterns:
                unique_patterns[name] = {
                    'pages': [pattern['page']],
                    'contexts': [pattern['context']]
                }
            else:
                unique_patterns[name]['pages'].append(pattern['page'])
                unique_patterns[name]['contexts'].append(pattern['context'])
        
        for pattern_name, pattern_data in unique_patterns.items():
            concept = EPConcept(
                name=pattern_name,
                category='relationship_patterns',
                description=f"E&P relationship pattern: {pattern_name}",
                details={
                    'pattern_type': pattern_name,
                    'context_excerpts': pattern_data['contexts'][:2]
                },
                page_references=pattern_data['pages']
            )
            self.concepts.append(concept)
    
    def _parse_assessment_concepts(self):
        """Parse assessment and evaluation concepts"""
        logger.info("   Parsing Assessment Concepts...")
        
        assessment_pages = []
        
        for page in self.pages:
            text_lower = page['raw_text'].lower()
            
            if any(keyword in text_lower for keyword in self.ASSESSMENT_KEYWORDS):
                assessment_pages.append({
                    'page': page['page_number'],
                    'content': page['raw_text']
                })
        
        if assessment_pages:
            concept = EPConcept(
                name="E&P Sexuality Assessment",
                category='assessment',
                description="Assessment methods and questionnaires for determining E&P type",
                details={
                    'assessment_type': 'questionnaire',
                    'content_excerpts': [p['content'][:500] for p in assessment_pages[:3]]
                },
                page_references=[p['page'] for p in assessment_pages]
            )
            self.concepts.append(concept)
    
    def save_concepts(self, output_path: str):
        """Save parsed concepts to JSON"""
        output = {
            'workbook_name': self.workbook_name,
            'total_concepts': len(self.concepts),
            'concepts': [
                {
                    'name': c.name,
                    'category': c.category,
                    'description': c.description,
                    'details': c.details,
                    'page_references': c.page_references
                }
                for c in self.concepts
            ]
        }
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(output, f, indent=2, ensure_ascii=False)
        
        logger.info(f"[SUCCESS] Saved {len(self.concepts)} concepts to: {output_path}")

def main():
    """Test parser on extracted E&P content"""
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python ep_theory_parser.py <extracted_json_file>")
        sys.exit(1)
    
    json_path = sys.argv[1]
    
    parser = EPTheoryParser(json_path)
    concepts = parser.parse_all_concepts()
    
    print(f"\n[STATS] Parsing Results:")
    print(f"        Total concepts: {len(concepts)}")
    
    categories = {}
    for concept in concepts:
        cat = concept.category
        categories[cat] = categories.get(cat, 0) + 1
    
    print(f"\n        By category:")
    for cat, count in categories.items():
        print(f"           {cat}: {count}")
    
    output_path = json_path.replace('_extracted.json', '_concepts.json')
    parser.save_concepts(output_path)
    
    print(f"\n[SUCCESS] Parsing complete!")
    print(f"          Output: {output_path}")

if __name__ == '__main__':
    main()
