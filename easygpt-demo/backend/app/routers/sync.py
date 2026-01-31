from fastapi import APIRouter, BackgroundTasks

router = APIRouter()

@router.post("/start")
async def start_sync(source: str, background_tasks: BackgroundTasks):
    # enqueue background sync job (placeholder)
    background_tasks.add_task(lambda: None)
    return {"message": f"Sync started for {source}"}