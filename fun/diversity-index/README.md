# Diversity Index (Food & Ethnic Stores)

Compute a diversity index of food / grocery / ethnic-oriented businesses in a given US ZIP code using the Yelp Fusion API.

## Features

- Fetches businesses by ZIP + term (`grocery`, `market`, etc.).
- Categorizes businesses into ethnicity / region buckets via keyword mapping.
- Calculates:
  - Richness (distinct groups with ≥1 business)
  - Shannon Index
  - Simpson Diversity (1 - D)
  - Pielou Evenness
- Caching layer to reduce API calls.
- Output as Markdown summary or raw JSON.

## Setup

1. Obtain a Yelp Fusion API key: <https://www.yelp.com/developers/documentation/v3/authentication>
1. Export your key:

```powershell
$Env:YELP_API_KEY = "YOUR_KEY_HERE"
```

1. Install dependencies:

```powershell
pip install -r requirements.txt
```

## Usage

```powershell
python diversity_index.py 94103 --term grocery --output markdown
python diversity_index.py 10001 --term restaurant --output json
```

Flags:

- `--refresh` : Ignore cache and re-query API.
- `--cache <path>` : Custom cache file (default `cache.json`).
- `--term` : Search term (examples: `grocery`, `market`, `restaurant`, `food`).
- `--output` : `markdown` or `json`.

## Ethnicity / Region Mapping

Defined in `diversity_index.py` (`ETHNICITY_MAP`). Extend by adding category keywords mapping to buckets (e.g. `"jamaican": "caribbean"`).

## Diversity Metrics

- **Shannon**: `-Σ p_i ln p_i`
- **Simpson**: `1 - Σ p_i^2`
- **Evenness (Pielou)**: `Shannon / ln(S)` where `S` = richness.

## Extending

- Add new sources (e.g., Google Places) by implementing another fetch function and merging business lists.
- Improve classification using NLP on business descriptions.
- Introduce weighting by rating or review count.

## Notes

- This is approximate; Yelp category aliases may not perfectly map to cultural / ethnic identities.
- Results are sensitive to the search term; try multiple (`grocery`, `market`, `restaurant`).

## Example Output (Markdown)

```text
# Diversity Index for 94103 (term: grocery)
Total Businesses: 42
Richness (distinct groups): 9
Shannon Index: 2.013
Simpson Index: 0.842
Pielou Evenness: 0.92

## Counts by Group
- east_asian: 8
- latinx: 7
- mediterranean: 5
- south_asian: 5
- african: 4
- middle_eastern: 4
- european: 3
- general: 3
- uncategorized: 3
```

## Caching

Cache entries expire after 1 hour; adjust `CACHE_TTL_SEC` constant as needed.
