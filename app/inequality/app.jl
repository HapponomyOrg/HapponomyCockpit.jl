module Inequality

using GenieFramework
@genietools

using EconoSim

sim_model_options::R{Vector{String}} = ["Standard", "SuMSy", "Debt Based"]

function rum_inequality_simulation()
end

@app begin
    @in lock_random_generator::Bool = true
    @in sim_length::Int = 100
    @in num_agents::Int = 1000
    @in transactions_per_cycle = 200

    @in bottom_10::Bool = true
    @in bottom_50::Bool = true
    @in middle_40::Bool = true
    @in top_10::Bool = true
    @in top_1::Bool = true

    @in sim_model::Symbol = sim_model_options[1]
end

@page("/", "app.jl.html")

end