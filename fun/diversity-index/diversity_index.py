import os
import math
import time
import json
import argparse
from collections import defaultdict
from typing import Dict, List, Tuple, Any

import requests

YELP_API_URL = "https://api.yelp.com/v3/businesses/search"
DEFAULT_LIMIT = 50  # Yelp max per request
MAX_PAGES = 5       # safety cap (adjust as needed)
CACHE_TTL_SEC = 3600

ETHNICITY_MAP = {
    "mexican": "latinx",
    "latin": "latinx",
    "brazilian": "latinx",
    "peruvian": "latinx",
    "argentine": "latinx",
    "japanese": "east_asian",
    "chinese": "east_asian",
    "thai": "southeast_asian",
    "vietnamese": "southeast_asian",
    "filipino": "southeast_asian",
    "korean": "east_asian",
    "indian": "south_asian",
    "pakistani": "south_asian",
    "bangladeshi": "south_asian",
    "nepalese": "south_asian",
    "caribbean": "caribbean",
    "ethiopian": "african",
    "somali": "african",
    "west_african": "african",
    "middle_eastern": "middle_eastern",
    "lebanese": "middle_eastern",
    "turkish": "middle_eastern",
    "greek": "mediterranean",
    "italian": "mediterranean",
    "spanish": "mediterranean",
    "french": "european",
    "german": "european",
    "polish": "european",
    "irish": "european",
    "ukrainian": "european",
    "russian": "european",
    "afghan": "south_asian",
    "hawaiian": "pacific_islander",
    "seafood": "general",
    "grocery": "general",
    "market": "general",
}

CATEGORY_KEYWORDS = list(ETHNICITY_MAP.keys())


def shannon_index(counts: Dict[str, int]) -> float:
    total = sum(counts.values())
    if total == 0:
        return 0.0
    h = 0.0
    for c in counts.values():
        if c == 0:
            continue
        p = c / total
        h -= p * math.log(p)
    return h


def simpson_index(counts: Dict[str, int]) -> float:
    total = sum(counts.values())
    if total == 0:
        return 0.0
    acc = 0.0
    for c in counts.values():
        if c == 0:
            continue
        p = c / total
        acc += p * p
    return 1 - acc  # diversity version


def pielou_evenness(counts: Dict[str, int]) -> float:
    s = sum(1 for v in counts.values() if v > 0)
    if s <= 1:
        return 0.0
    h = shannon_index(counts)
    return h / math.log(s)


def categorize_business(b: Dict[str, Any]) -> List[str]:
    categories = b.get("categories", [])
    mapped = set()
    for cat in categories:
        alias = cat.get("alias", "").lower()
        title = cat.get("title", "").lower()
        for token in CATEGORY_KEYWORDS:
            if token in alias or token in title:
                mapped.add(ETHNICITY_MAP[token])
    if not mapped:
        mapped.add("uncategorized")
    return list(mapped)


def load_cache(path: str) -> Dict[str, Any]:
    if not os.path.exists(path):
        return {}
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}


def save_cache(path: str, data: Dict[str, Any]) -> None:
    try:
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
    except Exception:
        pass


def fetch_yelp(zip_code: str, term: str, api_key: str) -> List[Dict[str, Any]]:
    headers = {"Authorization": f"Bearer {api_key}"}
    all_businesses = []
    for page in range(MAX_PAGES):
        offset = page * DEFAULT_LIMIT
        params = {
            "location": zip_code,
            "term": term,
            "limit": DEFAULT_LIMIT,
            "offset": offset,
        }
        r = requests.get(YELP_API_URL, headers=headers, params=params, timeout=20)
        if r.status_code != 200:
            break
        payload = r.json()
        batch = payload.get("businesses", [])
        if not batch:
            break
        all_businesses.extend(batch)
        if len(batch) < DEFAULT_LIMIT:
            break
        time.sleep(0.2)  # polite pacing
    return all_businesses


def aggregate_ethnicities(businesses: List[Dict[str, Any]]) -> Dict[str, int]:
    counts: Dict[str, int] = defaultdict(int)
    for b in businesses:
        cats = categorize_business(b)
        for c in cats:
            counts[c] += 1
    return dict(counts)


def compute_metrics(counts: Dict[str, int]) -> Dict[str, Any]:
    return {
        "total": sum(counts.values()),
        "richness": sum(1 for v in counts.values() if v > 0),
        "shannon": shannon_index(counts),
        "simpson": simpson_index(counts),
        "pielou_evenness": pielou_evenness(counts),
        "counts": counts,
    }


def run(zip_code: str, term: str, force_refresh: bool, cache_path: str) -> Dict[str, Any]:
    api_key = os.getenv("YELP_API_KEY")
    if not api_key:
        raise RuntimeError("YELP_API_KEY environment variable not set")
    cache = load_cache(cache_path)
    cache_key = f"{zip_code}:{term}"
    now = time.time()
    cached_entry = cache.get(cache_key)
    if cached_entry and not force_refresh and now - cached_entry.get("ts", 0) < CACHE_TTL_SEC:
        businesses = cached_entry["data"]
    else:
        businesses = fetch_yelp(zip_code, term, api_key)
        cache[cache_key] = {"ts": now, "data": businesses}
        save_cache(cache_path, cache)
    counts = aggregate_ethnicities(businesses)
    metrics = compute_metrics(counts)
    metrics["zip_code"] = zip_code
    metrics["term"] = term
    metrics["business_count"] = len(businesses)
    return metrics


def main():
    parser = argparse.ArgumentParser(description="Compute diversity index for food/ethnic stores in a ZIP code using Yelp API.")
    parser.add_argument("zip_code", help="Target ZIP code")
    parser.add_argument("--term", default="grocery", help="Search term (e.g. grocery, market, food, restaurant)")
    parser.add_argument("--refresh", action="store_true", help="Force refresh ignoring cache")
    parser.add_argument("--cache", default="cache.json", help="Cache file path")
    parser.add_argument("--output", choices=["json", "markdown"], default="markdown", help="Output format")
    args = parser.parse_args()

    metrics = run(args.zip_code, args.term, args.refresh, args.cache)
    if args.output == "json":
        print(json.dumps(metrics, indent=2))
    else:
        print(f"# Diversity Index for {metrics['zip_code']} (term: {metrics['term']})\n")
        print(f"Total Businesses: {metrics['business_count']}")
        print(f"Richness (distinct groups): {metrics['richness']}")
        print(f"Shannon Index: {metrics['shannon']:.3f}")
        print(f"Simpson Index: {metrics['simpson']:.3f}")
        print(f"Pielou Evenness: {metrics['pielou_evenness']:.3f}\n")
        print("## Counts by Group")
        for group, count in sorted(metrics['counts'].items(), key=lambda x: -x[1]):
            print(f"- {group}: {count}")

if __name__ == "__main__":
    main()
