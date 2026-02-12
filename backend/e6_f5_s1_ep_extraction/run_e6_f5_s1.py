"""
E6-F5-S1 Main Execution Script
Runs the complete E&P extraction pipeline
"""
import os
import sys
from pathlib import Path
import logging

from dotenv import load_dotenv

load_dotenv()  # <-- This line was missing!

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def main():
    # Find E&P Sexuality Workbook 1
    workbook_path_env = os.getenv('WORKBOOK_PATH', '.')
    workbook_path = Path(workbook_path_env)
    
    # Search for E&P workbook
    ep_workbooks = list(workbook_path.glob('*Emotional and Physical Sexuality*.pdf'))
    #ep_workbooks.append(workbook_path.glo('*Practicum*.pdf'))
    
    if not ep_workbooks:
        logger.error("[ERROR] E&P Sexuality Workbook 1 not found!")
        logger.error(f"        Searched in: {workbook_path}")
        logger.error("        Expected filename pattern: *Emotional and Physical Sexuality*.pdf")
        return 1
    
    ep_workbook = ep_workbooks[0]
    logger.info(f"[FOUND] Workbook: {ep_workbook.name}")
    
    # Step 1: Extract text
    logger.info("\n" + "="*80)
    logger.info("STEP 1: Extracting text from PDF")
    logger.info("="*80)
    
    from ep_pdf_extractor import EPPDFExtractor
    extractor = EPPDFExtractor(str(ep_workbook))
    pages = extractor.extract_all_pages()
    
    extracted_json = Path('output') / f"{ep_workbook.stem}_extracted.json"
    extracted_json.parent.mkdir(exist_ok=True)
    extractor.save_to_json(str(extracted_json))
    
    stats = extractor.get_statistics()
    logger.info(f"   [STATS] Extracted {stats['total_pages']} pages")
    logger.info(f"   [STATS] Total characters: {stats['total_characters']:,}")
    
    # Step 2: Parse concepts
    logger.info("\n" + "="*80)
    logger.info("STEP 2: Parsing E&P theory concepts")
    logger.info("="*80)
    
    from ep_theory_parser import EPTheoryParser
    parser = EPTheoryParser(str(extracted_json))
    concepts = parser.parse_all_concepts()
    
    concepts_json = Path('output') / f"{ep_workbook.stem}_concepts.json"
    parser.save_concepts(str(concepts_json))
    
    logger.info(f"   [STATS] Parsed {len(concepts)} concepts")
    
    # Step 3: Load into database
    logger.info("\n" + "="*80)
    logger.info("STEP 3: Loading into PostgreSQL database")
    logger.info("="*80)
    
    from ep_database_schema import init_database
    from ep_database_loader import EPDatabaseLoader
    
    init_database()
    loader = EPDatabaseLoader()
    
    pages_loaded = loader.load_extracted_pages(str(extracted_json))
    concepts_loaded = loader.load_parsed_concepts(str(concepts_json))
    
    stats = loader.get_statistics()
    logger.info(f"   [STATS] Database now contains:")
    logger.info(f"           Total pages: {stats['total_pages']}")
    logger.info(f"           Total concepts: {stats['total_concepts']}")
    
    # Success!
    logger.info("\n" + "="*80)
    logger.info("[SUCCESS] E6-F5-S1 COMPLETE!")
    logger.info("="*80)
    logger.info(f"\n   Output files:")
    logger.info(f"      {extracted_json}")
    logger.info(f"      {concepts_json}")
    logger.info(f"\n   Database: E&P content loaded")
    logger.info(f"      {stats['total_pages']} pages")
    logger.info(f"      {stats['total_concepts']} concepts")
    
    return 0

if __name__ == '__main__':
    sys.exit(main())
