# Fish ID Pokédex Backend

FastAPI service to classify fish images and provide enriched species information for scuba divers and snorkelers. Acts as a foundation for partnerships with aquariums and conservation groups.

## Features (MVP)

- Image classification via HuggingFace Inference API (fallback random curated fish list)
- Species enrichment (iNaturalist + optional Wikipedia summary)
- Sighting logging with geo-coordinates & depth
- Simple JSON file storage (replaceable with SQLite/Postgres)

## Setup

```powershell
# (Optional) create virtual env
python -m venv .venv; .\.venv\Scripts\activate

pip install -r backend/requirements.txt

# Environment variables (optional tokens)
$Env:FISH_HF_TOKEN = "YOUR_HF_TOKEN"            # HuggingFace token (optional)
$Env:FISH_MODEL = "google/vit-base-patch16-224"  # Override model
$Env:FISH_ID_DATA_DIR = "data"                  # Storage directory
```

## Run Dev Server

```powershell
uvicorn backend.app.main:app --reload --port 8000
```

## Frontend (Prototype)

Static UI at `fish-id/frontend/`:

```powershell
Start-Process "fish-id/frontend/index.html"
```

Ensure backend is running on `http://localhost:8000`.

## Key Endpoints

- `GET /health` : Service status
- `POST /classify` : Upload image (`multipart/form-data` with `file` field)
- `GET /species/{name}` : Enriched species info
- `POST /sightings` : Create sighting (JSON body + optional image upload)
- `GET /sightings` : List sightings
- `GET /sightings/{id}` : Retrieve single sighting

### Example: Classify Image (PowerShell)

```powershell
$url = "http://localhost:8000/classify"
Invoke-RestMethod -Method Post -Uri $url -InFile fish.jpg -ContentType "multipart/form-data"
```
(For complex multipart in PowerShell use `curl.exe` or a REST client.)

## Species Enrichment

- iNaturalist taxa search (`preferred_common_name`, image, conservation status)
- Wikipedia summary lookup (if scientific name available)
- Future additions: FishBase, GBIF, OBIS, local aquarium curated notes

## Storage

Currently JSON file `data/sightings.json`. To migrate to SQLite:

1. Replace `storage.py` implementation with SQLAlchemy models.
2. Maintain same interface (`list`, `create`, `get`).

## Roadmap Ideas

- Video frame extraction + batch classification
- Confidence calibration & ensemble (YOLO + ViT + custom CNN)
- Photo quality scoring & blur rejection
- Diver profile & logbook integration
- Conservation alerts (protected species flags)
- Aquarium partner data overlays (feeding times, exhibits)

## Testing

Add tests under `backend/tests/`. (Not yet implemented.) Example future test topics:

- Classification fallback behavior
- Species enrichment merging sources
- Sightings persistence

## Docker (future)

Example placeholder (to be added):

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY backend/app ./backend/app
CMD ["uvicorn", "backend.app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Notes

- Image inference may be slow without a token (public models cached variably).
- Classification list is broad; refine by training on reef-specific dataset later.
