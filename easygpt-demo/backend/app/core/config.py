from pydantic import BaseSettings

class Settings(BaseSettings):
    ENV: str = "development"
    DATABASE_URL: str = "sqlite:///./dev.db"

    class Config:
        env_file = ".env"

settings = Settings()