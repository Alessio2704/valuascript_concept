@export let periods = 10

@export
@correlated(with: [ { name: erp, direction: CorrelationDirection.Negative } ])
let rf = 4.5%

@export 
@correlated(with: [ { name: rf, direction: CorrelationDirection.Negative } ])
let erp = 5%

@export let beta = 1.05

@export let bond_spread = 0.74%

@export let marginal_tax_rate = 21%

@export let effective_tax_rate = 17%

@export let share_price = 220

@export let shares_outstanding = 11_000_000

@export let book_value_of_equity = 300_000

@export let book_value_of_debt = 50_000

@export let cash_and_marketable_securities = 120_000

@export let equity_value = shares_outstanding * share_price