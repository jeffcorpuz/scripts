from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse

from .classifier import classify_image
from .species_info import build_species_info
from .storage import storage
from .models import SightingCreate, ClassificationResult, SightingList

app = FastAPI(title="Fish ID Pokédex", version="0.1.0")

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/classify")
async def classify(file: UploadFile = File(...)):
    content = await file.read()
    results = classify_image(content)
    return {"results": [r.dict() for r in results]}

@app.get("/species/{name}")
async def species(name: str):
    info = build_species_info(name)
    return info.dict()

@app.post("/sightings")
async def create_sighting(payload: SightingCreate, file: UploadFile | None = File(default=None)):
    classifications: list[ClassificationResult] = []
    if file:
        content = await file.read()
        classifications = classify_image(content)
    sighting = storage.create(payload, classifications)
    return sighting.dict()

@app.get("/sightings")
async def list_sightings():
    items = storage.list()
    return SightingList(items=items)

@app.get("/sightings/{sighting_id}")
async def get_sighting(sighting_id: str):
    s = storage.get(sighting_id)
    if not s:
        raise HTTPException(status_code=404, detail="Not found")
    return s.dict()
