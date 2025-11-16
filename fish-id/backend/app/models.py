from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel

class ClassificationResult(BaseModel):
    species_name: str
    score: float
    common_name: Optional[str] = None
    scientific_name: Optional[str] = None
    external_ids: dict | None = None

class SpeciesInfo(BaseModel):
    id: str
    common_name: str | None = None
    scientific_name: str | None = None
    wiki_summary: str | None = None
    conservation_status: str | None = None
    habitat: str | None = None
    images: List[str] = []
    sources: List[str] = []

class SightingCreate(BaseModel):
    latitude: float
    longitude: float
    depth_m: float | None = None
    species_guess: str | None = None
    notes: str | None = None

class Sighting(SightingCreate):
    id: str
    ts: datetime
    classifications: List[ClassificationResult] = []

class SightingList(BaseModel):
    items: List[Sighting]
