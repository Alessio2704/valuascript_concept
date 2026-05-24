import "../assumptions/assumptions.vs"

@export func get_segment_data(segment: Segment) -> vector, vector {
    """Computes the segment data: revenues and operating income for a segment based on its overall market of reference (TAM)"""

    let market_total_revenues = grow_series(start: segment.market_size, rate: segment.cagr, periods: periods)
    let interim_market_share = interpolate_series(start: segment.market_share, target: segment.target_market_share, periods: periods)
    let revenues = market_total_revenues * interim_market_share
    let margins_interim = interpolate_series(start: segment.current_margin, target: segment.target_margin, periods: periods)
    let operating_income = revenues * margins_interim   

    return revenues, operating_income
}

@export func get_base_segment_data(segment: Segment) -> vector, vector  {
    """
    Computes the segment data: revenues and operating income for a segment where the segment represents the majority on its overall market of reference (TAM).

    In other words when it makes little sense to try to model the overall market because the segment is niche or because it is a very well known and established product (e.g. YouTube)
    """

    let revenues = grow_series(start: segment.market_size, rate: segment.cagr, periods: periods)
    let margins_interim = interpolate_series(start: segment.current_margin, target: segment.target_margin, periods: periods)
    let operating_margin = revenues * margins_interim

    return revenues, operating_margin
}

@export func get_base_segment_data_from_cagr_vector(segment: Segment) -> vector, vector  {
    """
    Computes the segment data: revenues and operating income for a segment where the segment represents the majority on its overall market of reference (TAM).

    In other words when it makes little sense to try to model the overall market because the segment is niche or because it is a very well known and established product (e.g. YouTube).

    It calculates the revenues using the vector of rates for each compounding period instead of a single cagr value.
    """

    let cagr_interim = grow_series(start: segment.cagr, rate: segment.cagr_variation_per_period, periods: periods)
    let revenues = compound_series(start: segment.market_size, rates: cagr_interim)
    let margins_interim = interpolate_series(start: segment.current_margin, target: segment.target_margin, periods: periods)
    let operating_margin = revenues * margins_interim

    return revenues, operating_margin
}

@export func get_segment_reinvestment(segment: Segment,
                                      revenues: vector,
                                      ebit: vector,
                                      total_revenues: vector) -> (vector, vector) {

    let sales_to_capital = interpolate_series(start: segment.sales_to_capital, target: segment.target_sales_to_capital, periods: get_periods())
    let revenues_weight_percentage = revenues / total_revenues
    let ebit_margin_weight_percentage = ebit / revenues
    let ebit_dis = ebit_margin_weight_percentage * revenues_weight_percentage
    let reinvestment = series_delta(data: revenues) / sales_to_capital[:-1]

    return (reinvestment, ebit_dis)
}