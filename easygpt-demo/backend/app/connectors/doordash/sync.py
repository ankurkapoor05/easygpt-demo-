from .client import DoordashClient

def sync_doordash(client: DoordashClient):
    orders = client.list_orders()
    return len(orders)