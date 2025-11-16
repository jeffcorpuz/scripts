import os
from functools import lru_cache
from pydantic import BaseSettings

class Settings(BaseSettings):
    hf_token: str | None = None
    inat_api_base: str = "https://api.inaturalist.org/v1"
    data_dir: str = os.getenv("FISH_ID_DATA_DIR", "data")
    model_name: str = os.getenv("FISH_MODEL", "google/vit-base-patch16-224")
    classification_top_k: int = int(os.getenv("FISH_TOP_K", "5"))

    class Config:
        env_prefix = "FISH_"
        case_sensitive = False

@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()
