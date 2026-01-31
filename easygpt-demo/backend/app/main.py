from fastapi import FastAPI
from .routers import health, auth, sync, insights, actions

app = FastAPI(title="easygpt-demo backend")

# include routers
app.include_router(health.router, prefix="/health", tags=["health"])
app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(sync.router, prefix="/sync", tags=["sync"])
app.include_router(insights.router, prefix="/insights", tags=["insights"])
app.include_router(actions.router, prefix="/actions", tags=["actions"])

@app.get("/")
async def root():
    return {"message": "Welcome to easygpt-demo backend"}