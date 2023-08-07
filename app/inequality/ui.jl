using GenieFramework

[
    Stipple.Html.div(class = "row", [
            Stipple.Html.div(class = "st-col col-4 col-sm st-module", [
                    h2(
                "Simulation parameters"
            ),
            br(),
            checkbox("Lock random generator", :lock_random_generator, ),
            textfield("Simulation length", :sim_length, type = "number", filled = "", ),
            textfield("Number of agents", :num_agents, type = "number", filled = "", ),
            textfield("Transactions per cycle", :transactions_per_cycle, type = "number", filled = "", )
        ]),
        Stipple.Html.div(class = "st-col col-4 col-sm st-module", [
                    h2(
                "Displayed percentiles"
            ),
            br(),
            checkbox("Top 1%", :top_1, ),
            br(),
            checkbox("Top 10%", :top_10, ),
            br(),
            checkbox("Middle 40%", :middle_40, ),
            br(),
            checkbox("Bottom 50%", :bottom_50, ),
            br(),
            checkbox("Bottom 10%", :bottom_10, )
        ]),
        Stipple.Html.div(class = "st-col col-4 col-sm st-module", [
                    h2(
                "Simulation model"
            ),
            br()
        ])
    ])
]