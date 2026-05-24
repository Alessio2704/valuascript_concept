import "../assumptions/assumptions.vs"

@export func get_wacc() -> scalar {
    let k_equity = rf + (beta * erp)
    let k_debt = (rf + bond_spread) * (1 - marginal_tax_rate)
    let total_k = equity_value + book_value_of_debt
    let equity_percentage = equity_value / total_k
    let debt_percentage = 1 - equity_percentage

    let wacc = k_debt * debt_percentage + k_equity * equity_percentage

    return wacc
}