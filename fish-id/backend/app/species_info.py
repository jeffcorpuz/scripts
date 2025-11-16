import requests
from typing import Optional
from .config import get_settings
from .models import SpeciesInfo

INAT_TAXA_ENDPOINT = "/taxa"  # base added from settings
WIKIDATA_SEARCH = "https://www.wikidata.org/w/api.php"
WIKIPEDIA_SUMMARY = "https://en.wikipedia.org/api/rest_v1/page/summary/"  # + title

headers = {"User-Agent": "fish-id-app/0.1"}


def fetch_inat_taxon(name: str) -> Optional[dict]:
    s = get_settings()
    params = {"q": name, "rank": "species", "per_page": 1}
    try:
        r = requests.get(s.inat_api_base + INAT_TAXA_ENDPOINT, params=params, headers=headers, timeout=15)
        if r.status_code == 200:
            data = r.json().get("results", [])
            return data[0] if data else None
    except Exception:
        return None
    return None


def fetch_wikidata_summary(title: str) -> Optional[str]:
    try:
        r = requests.get(WIKIPEDIA_SUMMARY + title, headers=headers, timeout=15)
        if r.status_code == 200:
            j = r.json()
            return j.get("extract")
    except Exception:
        return None
    return None


def build_species_info(name: str) -> SpeciesInfo:
    taxon = fetch_inat_taxon(name)
    common_name = None
    sci_name = None
    images = []
    sources = []
    status = None
    habitat = None
    if taxon:
        common_name = taxon.get("preferred_common_name") or taxon.get("name")
        sci_name = taxon.get("name")
        sources.append("iNaturalist")
        if taxon.get("default_photo"):
            images.append(taxon["default_photo"].get("medium_url"))
        if taxon.get("conservation_status"):
            status = taxon["conservation_status"].get("status_name")
    summary = None
    if sci_name:
        summary = fetch_wikidata_summary(sci_name)
        if summary:
            sources.append("Wikipedia")
    return SpeciesInfo(
        id=sci_name or name,
        common_name=common_name,
        scientific_name=sci_name,
        wiki_summary=summary,
        conservation_status=status,
        habitat=habitat,
        images=images,
        sources=sources,
    )
