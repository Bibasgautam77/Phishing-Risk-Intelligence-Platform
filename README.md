# Phishing Risk Intelligence Platform
Developed by Bibas Gautam | Project ID: BG-CYBER-002

Assesses URLs and raw emails with offline, rule-based scoring. Every score lists the rules that produced it, and analysts can mark results as false positives, which feeds rule-level statistics and admin-tunable weights.

## Architecture
React UI (`static/`, served at `/ui`) → FastAPI (`app/main.py`) → analysis modules (`scoring.py`, `email_analysis.py`, `reputation.py`) → SQLite → CSV/JSON reports + audit log.

## Setup
    python -m venv .venv && source .venv/bin/activate
    pip install -r requirements.txt
    python -m app.mkkey admin ; python -m app.mkkey analyst ; python -m app.mkkey viewer   # copy each key + hash line
    export PRP_API_KEYS="<hash>:admin,<hash>:analyst,<hash>:viewer"
    python -m scripts.seed          # synthetic sample data only
    uvicorn app.main:app --reload   # UI: http://127.0.0.1:8000/ui/   API docs: /docs
    pytest -v
Docker: `docker build -t prp . && docker run -p 8000:8000 -e PRP_API_KEYS=... prp`

## API
| Endpoint | Role |
|---|---|
| POST /analyze, POST /analyze-email, POST /analyses/{id}/feedback | analyst |
| GET /analyses/{id}, GET /rules/stats, GET /report?format=csv | viewer |
| PUT /rules/{rule}/weight, POST /blocklist, GET /audit | admin |

## Security design
Hashed API keys (SHA-256), role-based access, per-key rate limit, strict input validation and size caps, URLs never fetched, queries/email bodies not stored, parameterized SQL, audit log with masked actor IDs, non-root container. Use HTTPS (reverse proxy) outside local demos.

## Limitations
- Heuristic scoring gives false positives and misses; it is decision support, not a verdict.
- Look-alike detection is single-edit and covers a short brand list; no homoglyph/Unicode confusable analysis.
- Reputation lookup is a generic, disabled-by-default hook; connect only sources you are authorized to use.
- SHA-256 key hashing without salt suits high-entropy generated keys only; no user accounts/SSO; SQLite single-node.
- Unit/integration tests are in `tests/`; record real results in `docs/TESTING.md`. Operate only on synthetic data or authorized samples.
