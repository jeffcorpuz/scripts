import json
from fastapi.testclient import TestClient
from backend.app.main import app
from backend.app.species_info import build_species_info

client = TestClient(app)


def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


def test_classify_no_file():
    # Expect 422 when missing file
    r = client.post("/classify")
    assert r.status_code == 422


def test_classify_fallback(monkeypatch):
    # Use tiny blank PNG bytes
    from PIL import Image
    import io
    buf = io.BytesIO()
    Image.new("RGB", (10, 10), (255, 0, 0)).save(buf, format="PNG")
    buf.seek(0)
    files = {"file": ("test.png", buf.read(), "image/png")}
    r = client.post("/classify", files=files)
    assert r.status_code == 200
    data = r.json()
    assert "results" in data
    assert len(data["results"]) > 0
    # Each result should have species_name
    assert all("species_name" in item for item in data["results"])


def test_species_info_build(monkeypatch):
    # Monkeypatch network calls to avoid external dependency
    def fake_fetch_inat_taxon(name: str):
        return {
            "preferred_common_name": "Blue Tang",
            "name": "Paracanthurus hepatus",
            "default_photo": {"medium_url": "http://example.com/image.jpg"},
            "conservation_status": {"status_name": "Least Concern"},
        }

    def fake_fetch_wikidata_summary(title: str):
        return "A popular marine aquarium fish found in coral reefs."

    from backend.app import species_info as si
    monkeypatch.setattr(si, "fetch_inat_taxon", fake_fetch_inat_taxon)
    monkeypatch.setattr(si, "fetch_wikidata_summary", fake_fetch_wikidata_summary)

    info = build_species_info("Blue Tang")
    assert info.common_name == "Blue Tang"
    assert info.scientific_name == "Paracanthurus hepatus"
    assert info.conservation_status == "Least Concern"
    assert info.images
    assert "Wikipedia" in info.sources


def test_create_and_get_sighting(monkeypatch):
    # Monkeypatch classifier to deterministic output
    def fake_classify_image(content: bytes):
        from backend.app.models import ClassificationResult
        return [ClassificationResult(species_name="Clownfish", score=0.9)]

    from backend.app import classifier as clf
    monkeypatch.setattr(clf, "classify_image", fake_classify_image)

    payload = {
        "latitude": 12.34,
        "longitude": 56.78,
        "depth_m": 18.0,
        "species_guess": "Clownfish",
        "notes": "Near anemone"
    }
    r = client.post("/sightings", json=payload)
    assert r.status_code == 200
    sighting = r.json()
    assert sighting["id"]
    sighting_id = sighting["id"]

    r2 = client.get(f"/sightings/{sighting_id}")
    assert r2.status_code == 200
    s2 = r2.json()
    assert s2["id"] == sighting_id
    assert s2["classifications"]


def test_list_sightings():
    r = client.get("/sightings")
    assert r.status_code == 200
    data = r.json()
    assert "items" in data
    assert isinstance(data["items"], list)
