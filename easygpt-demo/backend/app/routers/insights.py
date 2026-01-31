from fastapi import APIRouter

router = APIRouter()

@router.get("/")
async def get_insights():
    # placeholder: return simple metrics
    return {"insights": {"orders_last_24h": 42}}