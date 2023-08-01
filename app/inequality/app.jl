module Inequality

using GenieFramework
@genietools

using EconoSim

function rum_inequality_simulation()
end

@app begin
    @in lock_random_generator::Bool = true
    @in sim_length::Int = 100
    @in num_agents::Int = 1000
    @in transactions_per_cycle = 200

    @in display_bottom_10::Bool = true
    @in display_bottom_50::Bool = true
    @in display_middle_40::Bool = true
    @in display_top_10::Bool = true
    @in display_top_1::Bool = true

    @in sim_model::Symbol = :standard
end

@page("/", "app.jl.html")

end