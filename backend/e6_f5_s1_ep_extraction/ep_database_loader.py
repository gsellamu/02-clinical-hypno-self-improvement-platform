"""
E&P Database Loader
Loads parsed E&P concepts into PostgreSQL database
"""
import json
from ep_database_schema import (
    init_database, get_session,
    EPWorkbookContent, EPCoreTheory
)
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class EPDatabaseLoader:
    """Loads E&P content into database"""
    
    def __init__(self):
        self.session = get_session()
    
    def load_extracted_pages(self, json_path: str):
        """Load raw extracted pages"""
        logger.info(f"Loading extracted pages from {json_path}...")
        
        with open(json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        workbook_name = data['workbook_name']
        pages = data['pages']
        
        loaded_count = 0
        for page_data in pages:
            existing = self.session.query(EPWorkbookContent).filter_by(
                workbook_name=workbook_name,
                page_number=page_data['page_number']
            ).first()
            
            if not existing:
                content = EPWorkbookContent(
                    workbook_name=workbook_name,
                    page_number=page_data['page_number'],
                    section_title=page_data.get('section_title'),
                    content_type=page_data.get('content_type', 'text'),
                    raw_text=page_data['raw_text']
                )
                self.session.add(content)
                loaded_count += 1
        
        self.session.commit()
        logger.info(f"[SUCCESS] Loaded {loaded_count} new pages")
        return loaded_count
    
    def load_parsed_concepts(self, json_path: str):
        """Load parsed concepts"""
        logger.info(f"Loading parsed concepts from {json_path}...")
        
        with open(json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        workbook_name = data['workbook_name']
        concepts = data['concepts']
        
        loaded_count = 0
        for concept_data in concepts:
            existing = self.session.query(EPCoreTheory).filter_by(
                concept_name=concept_data['name']
            ).first()
            
            if not existing:
                theory = EPCoreTheory(
                    concept_name=concept_data['name'],
                    category=concept_data['category'],
                    description=concept_data['description'],
                    details=concept_data['details'],
                    workbook_source=workbook_name,
                    page_references=concept_data['page_references']
                )
                self.session.add(theory)
                loaded_count += 1
        
        self.session.commit()
        logger.info(f"[SUCCESS] Loaded {loaded_count} new concepts")
        return loaded_count
    
    def get_statistics(self):
        """Get database statistics"""
        return {
            'total_pages': self.session.query(EPWorkbookContent).count(),
            'total_concepts': self.session.query(EPCoreTheory).count(),
            'by_category': {
                'four_core_traits': self.session.query(EPCoreTheory).filter_by(
                    category='four_core_traits').count(),
                'relationship_patterns': self.session.query(EPCoreTheory).filter_by(
                    category='relationship_patterns').count(),
                'assessment': self.session.query(EPCoreTheory).filter_by(
                    category='assessment').count()
            }
        }

def main():
    """Load E&P data into database"""
    import sys
    
    if len(sys.argv) < 3:
        print("Usage: python ep_database_loader.py <extracted_json> <concepts_json>")
        sys.exit(1)
    
    logger.info("Initializing database...")
    init_database()
    
    loader = EPDatabaseLoader()
    
    extracted_json = sys.argv[1]
    concepts_json = sys.argv[2]
    
    loader.load_extracted_pages(extracted_json)
    loader.load_parsed_concepts(concepts_json)
    
    stats = loader.get_statistics()
    print("\n[STATS] Database Statistics:")
    print(f"        Total pages: {stats['total_pages']}")
    print(f"        Total concepts: {stats['total_concepts']}")
    print(f"\n        By category:")
    for cat, count in stats['by_category'].items():
        print(f"           {cat}: {count}")
    
    print("\n[SUCCESS] Database loading complete!")

if __name__ == '__main__':
    main()
