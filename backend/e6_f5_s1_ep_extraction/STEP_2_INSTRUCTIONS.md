# STEP 2: Download and Run Python Files

## SUCCESS - Step 1 Complete!

You successfully ran the ASCII-only PowerShell script and created:
- Directory structure
- ep_database_schema.py
- .env configuration

---

## STEP 2: Download These 4 Python Files

Download and place in: `D:\ChatGPT Projects\genai-portfolio\projects\02-clinical-hypno-self-improvement-platform\backend\e6_f5_s1_ep_extraction\`

### 1. ep_pdf_extractor.py (5.7 KB)
Extracts text from PDF workbooks

### 2. ep_theory_parser.py (7.9 KB)
Parses E&P theory concepts

### 3. ep_database_loader.py (4.4 KB)
Loads data into PostgreSQL

### 4. run_e6_f5_s1.py (3.2 KB)
Main execution script

---

## HOW TO PLACE THE FILES

### Option 1: Manual Download (Easiest)
1. Download each file from Claude (click the file names above)
2. Save them to: `backend\e6_f5_s1_ep_extraction\`
3. Done!

### Option 2: PowerShell Copy (If you have the files)
```powershell
cd "D:\ChatGPT Projects\genai-portfolio\projects\02-clinical-hypno-self-improvement-platform\backend\e6_f5_s1_ep_extraction"

# Copy the 4 files here
# (Download from Claude first, then copy)
```

---

## VERIFY FILES ARE IN PLACE

Your directory should look like this:

```
backend\e6_f5_s1_ep_extraction\
├── .env
├── ep_database_schema.py      <-- Created by Step 1
├── ep_pdf_extractor.py         <-- Download this
├── ep_theory_parser.py         <-- Download this
├── ep_database_loader.py       <-- Download this
├── run_e6_f5_s1.py            <-- Download this
├── output\                     <-- Will be created
└── logs\                       <-- Will be created
```

---

## STEP 3: Run the Complete Extraction

### 1. Open PowerShell (regular, not Admin needed for this part)

```powershell
cd "D:\ChatGPT Projects\genai-portfolio\projects\02-clinical-hypno-self-improvement-platform\backend\e6_f5_s1_ep_extraction"
```

### 2. Run the extraction script

```powershell
python run_e6_f5_s1.py
```

### 3. Expected Output

```
[FOUND] Workbook: Jithendran_Sellamuthu__Emotional_and_Physical_Sexuality_1__Workbook.pdf

================================================================================
STEP 1: Extracting text from PDF
================================================================================
Extracting text from Jithendran_Sellamuthu__Emotional_and_Physical_Sexuality_1__Workbook.pdf...
   Total pages: 89
   Processed 10/89 pages...
   Processed 20/89 pages...
   ...
[SUCCESS] Extracted 87 pages with content
[SUCCESS] Saved extracted content to: output\..._extracted.json
   [STATS] Extracted 87 pages
   [STATS] Total characters: 124,583

================================================================================
STEP 2: Parsing E&P theory concepts
================================================================================
Parsing concepts from E&P_Sexuality_1...
   Parsing Four Core Traits...
   Parsing Relationship Patterns...
   Parsing Assessment Concepts...
[SUCCESS] Parsed 12 concepts
[SUCCESS] Saved 12 concepts to: output\..._concepts.json
   [STATS] Parsed 12 concepts

================================================================================
STEP 3: Loading into PostgreSQL database
================================================================================
Initializing E&P Sexuality database schema...
Database schema created successfully!
Loading extracted pages from output\..._extracted.json...
[SUCCESS] Loaded 87 new pages
Loading parsed concepts from output\..._concepts.json...
[SUCCESS] Loaded 12 new concepts
   [STATS] Database now contains:
           Total pages: 87
           Total concepts: 12

================================================================================
[SUCCESS] E6-F5-S1 COMPLETE!
================================================================================

   Output files:
      output\..._extracted.json
      output\..._concepts.json

   Database: E&P content loaded
      87 pages
      12 concepts
```

---

## TROUBLESHOOTING

### "ModuleNotFoundError: No module named 'pdfplumber'"
Re-run the PowerShell setup script - it installs dependencies

### "E&P Sexuality Workbook 1 not found!"
Check that your workbook is in the correct location (or update WORKBOOK_PATH in .env)

### "Database connection error"
1. Make sure PostgreSQL is running
2. Check the DATABASE_URL in .env file
3. Create the database if needed:
   ```sql
   CREATE DATABASE jeethhypno;
   ```

---

## AFTER SUCCESS

Once you see "[SUCCESS] E6-F5-S1 COMPLETE!", tell me:

> "E6-F5-S1 extraction complete! 87 pages, 12 concepts loaded."

Then we'll move to **Story 2: E&P Assessment System!**

---

## SUMMARY

1. [DONE] Step 1: Ran ASCII-only PowerShell script
2. [NOW] Step 2: Download 4 Python files
3. [NEXT] Step 3: Run `python run_e6_f5_s1.py`
4. [THEN] Report success & get Story 2

---

Ready to complete the extraction! Download those 4 files and run the script!
