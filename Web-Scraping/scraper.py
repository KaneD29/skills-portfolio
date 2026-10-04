import time
import re
from urllib.parse import urljoin
import requests
from bs4 import BeautifulSoup
import pandas as pd

# Base URL for the e-commerce store
START_URL = "http://books.toscrape.com/catalogue/page-1.html"

# Custom HTTP Headers (This is to prevent 403 Forbidden errors)
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept-Language": "en-US,en;q=0.9",
}

# Helper dictionary to convert word-based ratings into clean numeric values
RATING_MAP = {
    "One": 1,
    "Two": 2,
    "Three": 3,
    "Four": 4,
    "Five": 5
}

def fetch_page_html(url):
    """Downloads HTML content safely using the requests library."""
    try:
        response = requests.get(url, headers=HEADERS, timeout=10)
        response.raise_for_status()  # Raises error for 4xx or 5xx status codes
        return response.text
    except requests.exceptions.RequestException as e:
        print(f"[ERROR] Failed to fetch {url}: {e}")
        return None

def parse_product_data(html_content):
    """Extracts product details and next page link from HTML using BeautifulSoup."""
    soup = BeautifulSoup(html_content, "html.parser")
    products = []
    
    # Locate all individual product cards on the page
    cards = soup.find_all("article", class_="product_pod")
    
    for card in cards:
        # 1. Extract Product Title
        title_element = card.find("h3").find("a")
        title = title_element["title"] if title_element.has_attr("title") else title_element.text.strip()
        
        # 2. Extract Price and clean currency symbols (£ -> Float)
        raw_price = card.find("p", class_="price_color").text.strip()
        price_match = re.search(r"[\d.]+", raw_price)
        cleaned_price = float(price_match.group()) if price_match else 0.0
        
        # 3. Extract Availability status
        availability_text = card.find("p", class_="instock availability").text.strip()
        is_in_stock = "In stock" in availability_text
        
        # 4. Extract Star Rating from CSS class names (e.g., 'star-rating Three')
        rating_tag = card.find("p", class_="star-rating")
        rating_classes = rating_tag.get("class", []) if rating_tag else []
        
        rating_value = 0
        for cls in rating_classes:
            if cls in RATING_MAP:
                rating_value = RATING_MAP[cls]
                break

        # Append structured data
        products.append({
            "product_name": title,
            "price_gbp": cleaned_price,
            "rating_stars": rating_value,
            "in_stock": is_in_stock
        })
        
    next_button = soup.find("li", class_="next")
    return products, next_button

def run_scraper(max_pages=3):
    """Orchestrates pagination, scraping, and data pipeline processing."""
    current_url = START_URL
    all_products = []
    page_count = 1

    print("--- Starting Competitor Price Scraper ---")

    while current_url and page_count <= max_pages:
        print(f"[INFO] Scraping Page {page_count}: {current_url}")
        
        html = fetch_page_html(current_url)
        if not html:
            break
            
        page_products, next_button = parse_product_data(html)
        all_products.extend(page_products)
        
        # Handle Pagination: Look for the 'next' button link
        if next_button and next_button.find("a"):
            next_page_rel = next_button.find("a")["href"]
            current_url = urljoin(current_url, next_page_rel)
            page_count += 1
            
            # Polite scraping delay to avoid hitting server limits
            time.sleep(1)
        else:
            current_url = None

    if not all_products:
        print("[WARNING] No product data collected. Exiting.")
        return

    # Convert list to Pandas DataFrame and drop duplicates
    df = pd.DataFrame(all_products)
    
    # Data Cleaning / Transformation step
    df.drop_duplicates(subset=["product_name"], inplace=True)

    # 1. Full Catalog - CSV
    df.to_csv("products_output.csv", index=False, encoding="utf-8")

    # 2. Full Catalog - JSON
    df.to_json("products_output.json", orient="records", indent=4)

    # 3. Full Catalog - Excel
    df.to_excel("products_output.xlsx", index=False)

    # 4. Filtered Subset: Top-Rated Products Only (4 & 5 stars)
    high_rated_df = df[df["rating_stars"] >= 4]
    high_rated_df.to_csv("sample_top_rated.csv", index=False, encoding="utf-8")

    # 5. Summary Report: Aggregated Metrics by Rating
    summary_df = df.groupby("rating_stars").agg(
        total_products=("product_name", "count"),
        average_price_gbp=("price_gbp", "mean"),
        min_price_gbp=("price_gbp", "min"),
        max_price_gbp=("price_gbp", "max")
    ).reset_index()

    summary_df["average_price_gbp"] = summary_df["average_price_gbp"].round(2)
    summary_df.to_csv("sample_price_summary.csv", index=False, encoding="utf-8")

    print(f"--- Finished Successfully! Exported 5 sample files across CSV, JSON, and XLSX formats ---")

if __name__ == "__main__":
    # Run scraper for first 3 pages as a proof-of-concept
    run_scraper(max_pages=3)