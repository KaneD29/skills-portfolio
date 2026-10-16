import asyncio
import re
import time
from urllib.parse import urljoin
import aiohttp
from bs4 import BeautifulSoup
import pandas as pd

# Base URL for the e-commerce store
START_URL = "http://books.toscrape.com/catalogue/page-1.html"
BASE_CATALOGUE_URL = "http://books.toscrape.com/catalogue/"

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

async def fetch_page_html(session, url, semaphore):
    """Downloads HTML content safely using the requests library."""
    async with semaphore:
        try:
            async with session.get(url, headers=HEADERS, timeout=10) as response:
                if response.status != 200:
                    return None
                return await response.text()
        except Exception as e:
            print(f"[ERROR] Failed to fetch {url}: {e}")
            return None

def parse_product_data(html_content):
    """Extracts product details and next page link from HTML using BeautifulSoup."""
    soup = BeautifulSoup(html_content, "lxml")
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

async def fetch_and_parse_page(session, url, semaphore):
    html = await fetch_page_html(session, url, semaphore)
    if not html:
        return []
    page_products, _ = parse_product_data(html)
    return page_products

async def run_scraper_async(max_pages=50, max_concurrent=10):
    """Orchestrates pagination, scraping, and data pipeline processing."""
    start_time = time.perf_counter()

    print("--- Starting Competitor Price Scraper ---")

    # Generate page URLs directly since the structure is predictable
    urls = [f"{BASE_CATALOGUE_URL}page-{i}.html" for i in range(1, max_pages + 1)]
    semaphore = asyncio.Semaphore(max_concurrent)

    async with aiohttp.ClientSession() as session:
        tasks = [fetch_and_parse_page(session, url, semaphore) for url in urls]
        results = await asyncio.gather(*tasks)

    all_products = [product for page in results for product in page]

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

    end_time = time.perf_counter()
    total_duration = end_time - start_time
    print(f"--- Finished Successfully! Exported 5 sample files across CSV, JSON, and XLSX formats ---")
    print(f"Total Execution Time: {total_duration:.2f} seconds ({total_duration/60:.2f} minutes)")

def run_scraper(max_pages=50):
    asyncio.run(run_scraper_async(max_pages=max_pages))

if __name__ == "__main__":
    # Run scraper 50 pages as a proof-of-concept
    run_scraper(max_pages=50)