from fastapi import APIRouter, HTTPException

router = APIRouter()

@router.post("/login")
async def login(username: str, password: str):
    # placeholder authentication
    if username == "demo" and password == "demo":
        return {"token": "fake-jwt-token"}
    raise HTTPException(status_code=401, detail="Invalid credentials")