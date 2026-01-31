# easygpt-demo

Demo backend skeleton for integrating order sources (Square, DoorDash, UberEats) and exposing simple APIs.

Quick start (local)
1. Create a virtualenv and install requirements:
   ```bash
   python -m venv .venv
   source .venv/bin/activate
   pip install -r backend/requirements.txt
   ```

2. Run the app:
   ```bash
   uvicorn backend.app.main:app --reload
   ```

3. Visit http://127.0.0.1:8000/docs for the OpenAPI UI.