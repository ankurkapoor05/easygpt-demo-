def compute_metrics(orders: list) -> dict:
    total = sum(o.get("amount", 0) for o in orders)
    return {"count": len(orders), "total_amount": total}