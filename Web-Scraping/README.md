# Automated E-Commerce Competitor Price Scraper

An end-to-end Python web scraper designed to extract product details, live pricing, stock availability, and user ratings from e-commerce catalogs. Built as a portfolio project to demonstrate production-grade scraping practices, data transformation pipelines, and multi-format reporting.

---

## Key Features

- **Robust Networking**: Custom HTTP request headers (`User-Agent`, `Accept-Language`) to bypass basic anti-bot blocks and prevent `403 Forbidden` responses.
- **Dynamic Relative Pagination**: Uses `urllib.parse.urljoin` to dynamically resolve pagination links across variable directory levels without breaking link paths.
- **Data Cleaning & Regex Extraction**: Cleans raw web strings (stripping UTF-8 currency artifacts like `Â£`) and extracts pure numerical floats via Regular Expressions (`re`).
- **Resilient Data Parsing**: Safely handles missing DOM elements and maps string-based ratings (`One`–`Five`) into structured numeric integers.
- **Multi-Format Pipeline**: Automatically exports scraped data into CSV, JSON (REST API compliant), and Microsoft Excel (`.xlsx`) formats.
- **Analytics & Subsets**: Generates filtered reports (top-rated products) and grouped statistical summaries (average, min, max price per rating category).

---

## Target Website

This project targets [Books to Scrape](http://books.toscrape.com), an e-commerce sandbox that mirrors modern store structures—including category pages, multi-page pagination, star ratings, and inventory status indicators.

---

## Tech Stack & Dependencies

- **Python 3.x**
- **Requests**: HTTP interaction & network handling
- **BeautifulSoup4**: HTML parsing & DOM manipulation
- **Pandas**: Data transformation, deduplication, and export pipelines
- **OpenPyXL**: Excel workbook generation support

---

## Project Structure

```text
├── scraper.py                 # Core scraping orchestration & pipeline script
├── products_output.csv        # Complete catalog output (CSV)
├── products_output.json       # Complete catalog output (JSON)
├── products_output.xlsx       # Complete catalog output (Excel)
├── sample_top_rated.csv       # Filtered report: Products with 4+ star ratings
├── sample_price_summary.csv   # Aggregated pricing analytics report
└── README.md                  # Technical overview and documentation
```

---

## Generated Sample Outputs

| File | Purpose / Description |
| :--- | :--- |
| `products_output.csv` | Raw tabular dataset containing title, price (GBP), rating, and stock status. |
| `products_output.json` | Nested array of JSON objects structured for REST API ingestion. |
| `products_output.xlsx` | Spreadsheet workbook ready for business operations and client presentation. |
| `sample_top_rated.csv` | Filtered dataset isolating high-performing items (4 and 5 stars). |
| `sample_price_summary.csv` | Summary report with count, average price, min price, and max price grouped by star rating. |

---

## Setup & Execution

### 1. Prerequisites
Ensure Python 3 is installed on your system.

### 2. Install Required Packages
Run the following command in your terminal to install dependencies:
```bash
pip install requests beautifulsoup4 pandas openpyxl
```

### 3. Run the Scraper
Execute the main script:
```bash
python scraper.py
```

---

## Code Architecture Highlights

The script follows a modular design pattern separating fetching, parsing, and pipeline orchestration:

1. **`fetch_page_html(url)`**: Isolates HTTP network calls with timeout boundaries and status code validation.
2. **`parse_product_data(html_content)`**: Parses HTML cards into structured Python dictionaries and extracts relative navigation elements.
3. **`run_scraper(max_pages)`**: Controls pagination limits, polite request throttling (`time.sleep`), deduplication, and file generation.

## AI Usage Disclaimer
Used Gemini for Code Debugging and Grammar checking for README. [https://gemini.google.com]