from .client import UbereatsClient

def sync_ubereats(client: UbereatsClient):
    orders = client.list_orders()
    return len(orders)