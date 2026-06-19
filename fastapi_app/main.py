from fastapi import FastAPI

from fastapi_app.routers.users import router as user_router

app = FastAPI(
    title="Multi Vendor E-Commerce API",
    description="CRUD APIs using FastAPI",
    version="1.0"
)

app.include_router(
    user_router
)


@app.get("/")
def home():

    return {
        "message": "FastAPI is running!"
    }