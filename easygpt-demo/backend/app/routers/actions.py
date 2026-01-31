from fastapi import APIRouter

router = APIRouter()

@router.post("/run")
async def run_action(action_name: str):
    # placeholder action runner
    return {"status": "ok", "action": action_name}