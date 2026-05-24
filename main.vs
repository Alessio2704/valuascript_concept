import "modules/wacc.vs"
import "modules/segment.vs"
import "modules/fcff.vs"

#iterations = 10_000_000

let value_of_research_assets, current_year_amortization = get_rd()

let wacc = get_wacc()

struct Segment {
    market_share: Decimal,
    @correlated(with: [ { name: self.market_size, direction: CorrelationDirection.Positive } ]) // It implies that the more the market grows the more people tend to start using the leader of the market services
    target_market_share: Decimal,
    market_size: Decimal,
    cagr: Decimal,
    cagr_variation_per_period: Decimal,
    current_margin: Decimal,
    target_margin: Decimal,
    sales_to_capital: Decimal,
    target_sales_to_capital: Decimal
}

// ==========================================
// 1. SEGMENT ASSUMPTIONS
// ==========================================

@scenario(type: "base") 
let gcp_segment: Segment = {
    market_share: 11%,
    target_market_share: Uniform(min: 10%, max: 15%),
    market_size: 13_624 / self.market_share * 4,
    cagr: Pert(min: 15%, likely: 20%, max: 25%),
    cagr_variation_per_period: 0%,
    current_margin: 15%,
    @correlated(with: [ { name: gcp_revenues, direction: CorrelationDirection.Positive } ])
    target_margin: Uniform(min: 30%, max: 40%),
    sales_to_capital: 22%,
    target_sales_to_capital: 100%
}

@scenario(type: "base") 
let yt_segment: Segment = {
    market_share: 100%,
    target_market_share: 100%,
    market_size: 9_796 * 4,
    cagr: 11%,
    cagr_variation_per_period: 0%,
    current_margin: 40%,
    @correlated(with: [ { name: yt_revenues, direction: CorrelationDirection.Positive } ])
    target_margin: Uniform(min: 40%, max: 45%),
    sales_to_capital: 100%,
    target_sales_to_capital: 200%
}

@scenario(type: "base") 
let google_network_segment: Segment = {
    market_share: 100%,
    target_market_share: 100%,
    market_size: 7_354 * 4,
    cagr: -10%,
    cagr_variation_per_period: 0%,
    current_margin: 40%,
    target_margin: 40%,
    sales_to_capital: 200%,
    target_sales_to_capital: 200%
}

@scenario(type: "base") 
let google_subscriptions_segment: Segment = {
    market_share: 100%,
    target_market_share: 100%,
    market_size: 11_203 * 4,
    cagr: 10%,
    cagr_variation_per_period: 0%,
    current_margin: 20%,
    @correlated(with: [ { name: google_subscriptions_revenues, direction: CorrelationDirection.Positive } ])
    target_margin: Uniform(min: 20%, max: 25%),
    sales_to_capital: 200%,
    target_sales_to_capital: 200%
}

@scenario(type: "base") 
let google_search_segment: Segment = {
    market_share: 100%,
    target_market_share: 100%,
    market_size: 54_190 * 4,
    cagr: 10%,
    cagr_variation_per_period: -15%,
    current_margin: 30%,
    @correlated(with: [ { name: google_search_revenues, direction: CorrelationDirection.Positive } ])
    target_margin: Uniform(min: 30%, max: 40%),
    sales_to_capital: 200%,
    target_sales_to_capital: 200%
}

// ==========================================
// 2. REVENUE & EBIT COMPUTATION
// ==========================================

let gcp_revenues, gcp_ebit = get_segment_data(segment: gcp_segment)
let yt_revenues, yt_ebit = get_segment_data(segment: yt_segment)
let google_network_revenues, google_network_ebit = get_segment_data(segment: google_network_segment)
let google_subscriptions_revenues, google_subscriptions_ebit = get_segment_data(segment: google_subscriptions_segment)
let google_search_revenues, google_search_ebit = get_segment_data(segment: google_search_segment)

let total_revenues = gcp_revenues + yt_revenues + google_network_revenues + google_subscriptions_revenues + google_search_revenues
let total_ebit = gcp_ebit + yt_ebit + google_network_ebit + google_subscriptions_ebit + google_search_ebit

// ==========================================
// 3. NOPAT & REINVESTMENT
// ==========================================

let future_tax_rate = get_tax_rates_progression()
let ebit_after_tax = total_ebit * (1 - future_tax_rate)

let gcp_reinvestment, gcp_ebit_dis = get_segment_reinvestment(stc: gcp_segment.sales_to_capital, target_stc: gcp_segment.target_sales_to_capital, rev: gcp_revenues, ebit: gcp_ebit, total_rev: total_revenues)
let yt_reinvestment, yt_ebit_dis = get_segment_reinvestment(stc: yt_segment.sales_to_capital, target_stc: yt_segment.target_sales_to_capital, rev: yt_revenues, ebit: yt_ebit, total_rev: total_revenues)
let google_network_reinvestment, google_network_ebit_dis = get_segment_reinvestment(stc: google_network_segment.sales_to_capital, target_stc: google_network_segment.target_sales_to_capital, rev: google_network_revenues, ebit: google_network_ebit, total_rev: total_revenues)
let google_subscriptions_reinvestment, google_subscriptions_ebit_dis = get_segment_reinvestment(stc: google_subscriptions_segment.sales_to_capital, target_stc: google_subscriptions_segment.target_sales_to_capital, rev: google_subscriptions_revenues, ebit: google_subscriptions_ebit, total_rev: total_revenues)
let google_search_reinvestment, google_search_ebit_dis = get_segment_reinvestment(stc: google_search_segment.sales_to_capital, target_stc: google_search_segment.target_sales_to_capital, rev: google_search_revenues, ebit: google_search_ebit, total_rev: total_revenues)

let total_reinvestment = gcp_reinvestment + yt_reinvestment + google_network_reinvestment + google_subscriptions_reinvestment + google_search_reinvestment
let total_current_capital = get_book_value_of_equity() + get_book_value_of_debt() - get_cash_and_marketable_securities() + value_of_research_assets
let capital_year_9 = total_current_capital + sum_series(data: total_reinvestment)

let year_10_growth = total_revenues[-1] / total_revenues[-2] - 1
let year_10_roi = total_ebit[-1] / capital_year_9
let reinvestment_year_10 = year_10_growth / year_10_roi * ebit_after_tax[-1]

// ==========================================
// 4. FCFF & VALUATION
// ==========================================

let sum_of_d_fcff = get_sum_of_fcff(ebit: ebit_after_tax, reinvestment: reinvestment_year_10, rate: wacc, total_reinv: total_reinvestment)

let total_ebit_dis = gcp_ebit_dis + yt_ebit_dis + google_network_ebit_dis + google_subscriptions_ebit_dis + google_search_ebit_dis
let d_tv = get_discounted_terminal_value(rev: total_revenues, ebit: total_ebit_dis, tax: future_tax_rate, rate: wacc)

let value_of_common_equity = sum_of_d_fcff + d_tv
let final_value_of_common_equity = value_of_common_equity - get_book_value_of_debt() + get_cash_and_marketable_securities()

let value_per_share = final_value_of_common_equity / get_shares_outstanding()

#output = value_per_share
#output_file = "results.csv"