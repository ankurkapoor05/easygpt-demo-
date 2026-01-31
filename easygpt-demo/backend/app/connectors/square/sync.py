from .client import SquareClient

def sync_square(client: SquareClient):
    orders = client.list_orders()
    # transform and persist
    return len(orders)