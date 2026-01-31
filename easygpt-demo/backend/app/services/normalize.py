def normalize_order(raw_order: dict) -> dict:
    """
    Convert provider-specific order shape into a canonical internal format.
    """
    # placeholder normalization
    return {
        "id": raw_order.get("id"),
        "amount": raw_order.get("total", raw_order.get("amount")),
    }