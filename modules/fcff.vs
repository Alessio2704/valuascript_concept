import "../assumptions/assumptions.vs"
import "wacc.vs"

@export func get_sum_of_fcff(ebit_after_tax: vector,
                     reinvestment_last_year: scalar,
                     wacc: scalar,
                     total_reinvestment: vector) -> scalar {

    let d_fcff_last = (ebit_after_tax[-1] - reinvestment_last_year) / (1 + wacc)^periods

    let d_fcff_to_n_minus_1 = npv(rate: wacc, cash_flows: (ebit_after_tax[:-1] - total_reinvestment))

    let sum_of_d_fcff = d_fcff_to_n_minus_1 + d_fcff_last

    return sum_of_d_fcff
}

@export func get_discounted_terminal_value(total_revenues: vector,
                                   total_ebit_dis: vector,
                                   future_tax_rate: vector,
                                   wacc: scalar) -> scalar {

    let final_revenues = total_revenues[-1] * (1 + rf)
    let final_nopat = final_revenues * total_ebit_dis[-1] * (1 - future_tax_rate[-1])
    let final_reinvestment = rf / return_on_capital_in_perpetuity * final_nopat

    let terminal_fcff = final_nopat - final_reinvestment
    let tv = terminal_fcff / (wacc - rf)
    let d_tv = tv / (1 + wacc)^periods
    return d_tv
}