"""Env validation - fails at import if env is malformed.

Pattern: pydantic-settings BaseSettings. Equivalent of Zod env schema for TS.

Usage:
    from resume.config import settings
    db_url = settings.database_url  # type-safe; missing/invalid -> ValidationError at import

Server-side only. Client-exposed vars don't exist in Python CLI tools.
"""

from __future__ import annotations

from pathlib import Path
from typing import Literal

from pydantic import Field, HttpUrl, PostgresDsn, RedisDsn, SecretStr, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Project-wide env-derived configuration."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # ---- Runtime -----------------------------------------------------------
    node_env: Literal["development", "test", "production"] = "development"
    log_level: Literal["debug", "info", "warn", "error"] = "info"

    # ---- Database / cache --------------------------------------------------
    database_url: PostgresDsn
    redis_url: RedisDsn

    # ---- Security ----------------------------------------------------------
    jwt_secret: SecretStr = Field(..., min_length=32)
    session_secret: SecretStr = Field(..., min_length=32)
    cors_origins: str

    @field_validator("cors_origins")
    @classmethod
    def split_cors(cls, v: str) -> list[str]:  # type: ignore[override]
        return [o.strip() for o in v.split(",") if o.strip()]  # noqa

    # ---- AI provider keys (optional) ---------------------------------------
    anthropic_api_key: SecretStr | None = None
    openai_api_key: SecretStr | None = None

    # ---- Cost guardrails ---------------------------------------------------
    llm_daily_budget_usd: float = Field(default=10.0, gt=0)
    llm_max_tokens_per_request: int = Field(default=4096, gt=0)
    llm_budget_alert_pct: float = Field(default=80.0, ge=0, le=100)

    # ---- Observability -----------------------------------------------------
    sentry_dsn: HttpUrl | None = None
    otel_exporter_otlp_endpoint: HttpUrl | None = None
    otel_service_name: str = "resume"


# Import-time singleton. Module load fails loud on bad env.
settings = Settings()  # type: ignore[call-arg]

__all__ = ["Settings", "settings"]
