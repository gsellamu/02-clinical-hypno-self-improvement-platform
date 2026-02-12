"""
E&P Sexuality PDF Text Extractor
Extracts text from HMI E&P Sexuality workbooks while preserving structure
"""
import pdfplumber
import PyPDF2
import re
import json
from pathlib import Path
from typing import Dict, List, Optional
from dataclasses import dataclass, asdict
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@dataclass
class ExtractedPage:
    """Represents content from a single page"""
    page_number: int
    raw_text: str
    section_title: Optional[str] = None
    content_type: str = 'text'
    has_images: bool = False
    
class EPPDFExtractor:
    """Extracts and structures content from E&P Sexuality workbooks"""
    
    def __init__(self, pdf_path: str):
        self.pdf_path = Path(pdf_path)
        self.workbook_name = self._get_workbook_name()
        self.pages: List[ExtractedPage] = []
        
    def _get_workbook_name(self) -> str:
        """Determine workbook name from filename"""
        filename = self.pdf_path.stem
        if 'Sexuality_1' in filename or 'Physical_Sexuality_1' in filename:
            return 'E&P_Sexuality_1'
        elif 'Sexuality_2' in filename or 'Physical_Sexuality_2' in filename:
            return 'E&P_Sexuality_2'
        else:
            return filename
    
    def extract_all_pages(self) -> List[ExtractedPage]:
        """Extract text from all pages"""
        logger.info(f"Extracting text from {self.pdf_path.name}...")
        
        try:
            with pdfplumber.open(self.pdf_path) as pdf:
                total_pages = len(pdf.pages)
                logger.info(f"   Total pages: {total_pages}")
                
                for page_num, page in enumerate(pdf.pages, start=1):
                    # Extract text
                    text = page.extract_text()
                    
                    if text and len(text.strip()) > 50:
                        # Detect section titles
                        section_title = self._detect_section_title(text)
                        
                        # Check for tables
                        tables = page.extract_tables()
                        content_type = 'table' if tables else 'text'
                        
                        # Check for images
                        has_images = len(page.images) > 0
                        
                        extracted_page = ExtractedPage(
                            page_number=page_num,
                            raw_text=text,
                            section_title=section_title,
                            content_type=content_type,
                            has_images=has_images
                        )
                        
                        self.pages.append(extracted_page)
                        
                        if page_num % 10 == 0:
                            logger.info(f"   Processed {page_num}/{total_pages} pages...")
                
                logger.info(f"[SUCCESS] Extracted {len(self.pages)} pages with content")
                return self.pages
                
        except Exception as e:
            logger.error(f"[ERROR] Error extracting PDF: {e}")
            raise
    
    def _detect_section_title(self, text: str) -> Optional[str]:
        """Attempt to detect section titles from text"""
        lines = text.split('\n')
        if not lines:
            return None
        
        # First non-empty line is often the title
        for line in lines[:3]:
            line = line.strip()
            if line and len(line) < 100:
                # Common title patterns in HMI workbooks
                if any(keyword in line.lower() for keyword in [
                    'chapter', 'section', 'introduction', 'overview',
                    'four core traits', 'assessment', 'relationship', 'sexuality'
                ]):
                    return line
        
        return None
    
    def save_to_json(self, output_path: str):
        """Save extracted content to JSON"""
        output = {
            'workbook_name': self.workbook_name,
            'source_file': str(self.pdf_path),
            'total_pages': len(self.pages),
            'pages': [asdict(page) for page in self.pages]
        }
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(output, f, indent=2, ensure_ascii=False)
        
        logger.info(f"[SUCCESS] Saved extracted content to: {output_path}")
    
    def get_statistics(self) -> Dict:
        """Get extraction statistics"""
        return {
            'workbook_name': self.workbook_name,
            'total_pages': len(self.pages),
            'pages_with_tables': sum(1 for p in self.pages if p.content_type == 'table'),
            'pages_with_images': sum(1 for p in self.pages if p.has_images),
            'total_characters': sum(len(p.raw_text) for p in self.pages),
            'pages_with_sections': sum(1 for p in self.pages if p.section_title)
        }

def main():
    """Test extraction on E&P Sexuality Workbook 1"""
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python ep_pdf_extractor.py <path_to_ep_workbook.pdf>")
        sys.exit(1)
    
    pdf_path = sys.argv[1]
    
    # Extract
    extractor = EPPDFExtractor(pdf_path)
    pages = extractor.extract_all_pages()
    
    # Show statistics
    stats = extractor.get_statistics()
    print("\n[STATS] Extraction Statistics:")
    for key, value in stats.items():
        print(f"        {key}: {value}")
    
    # Save to JSON
    output_path = Path(pdf_path).stem + '_extracted.json'
    extractor.save_to_json(output_path)
    
    print(f"\n[SUCCESS] Extraction complete!")
    print(f"          Output: {output_path}")

if __name__ == '__main__':
    main()
