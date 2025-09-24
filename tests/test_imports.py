def test_import_fastapi_app():
    from services.api.app.main import app  # noqa: F401

def test_redis_consumer_module():
    import consumers.redis_consumer.consumer as c  # noqa: F401
