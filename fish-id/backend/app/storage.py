import json
import os
import uuid
from datetime import datetime
from typing import List

from .models import Sighting, SightingCreate, ClassificationResult
from .config import get_settings

class Storage:
    def __init__(self):
        settings = get_settings()
        self.data_dir = settings.data_dir
        os.makedirs(self.data_dir, exist_ok=True)
        self.path = os.path.join(self.data_dir, "sightings.json")
        if not os.path.exists(self.path):
            with open(self.path, "w", encoding="utf-8") as f:
                json.dump([], f)

    def _load(self) -> List[dict]:
        with open(self.path, "r", encoding="utf-8") as f:
            return json.load(f)

    def _save(self, data: List[dict]):
        with open(self.path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)

    def list(self) -> List[Sighting]:
        return [Sighting(**d) for d in self._load()]

    def create(self, payload: SightingCreate, classifications: List[ClassificationResult]) -> Sighting:
        data = self._load()
        sighting_id = str(uuid.uuid4())
        sighting = Sighting(
            id=sighting_id,
            ts=datetime.utcnow(),
            latitude=payload.latitude,
            longitude=payload.longitude,
            depth_m=payload.depth_m,
            species_guess=payload.species_guess,
            notes=payload.notes,
            classifications=classifications,
        )
        data.append(json.loads(sighting.json()))
        self._save(data)
        return sighting

    def get(self, sighting_id: str) -> Sighting | None:
        for d in self._load():
            if d.get("id") == sighting_id:
                return Sighting(**d)
        return None

storage = Storage()
