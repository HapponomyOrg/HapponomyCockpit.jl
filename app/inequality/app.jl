module Inequality

using GenieFramework
@genietools

using EconoSim

sim_model_options = [:Standard, :SuMSy, Symbol("Debt Based")]

function rum_inequality_simulation()
end

@app begin
    @in lock_random_generator::Bool = true
    @in sim_length::Int = 100
    @in num_agents::Int = 1000
    @in transaction_range::Bool = false
    @in transaction_range_per_cycle::RangeData{Int} = RangeData(100:200)
    @in transactions_per_cycle::Int = 100

    @in bottom_10::Bool = true
    @in bottom_50::Bool = true
    @in middle_40::Bool = true
    @in top_10::Bool = true
    @in top_1::Bool = true

    @out sim_model_options
    @in sim_model::Symbol = :Standard

    # Standard model parameters
    @in initial_wealth = 1000

    # SuMSy parameters
    @in guaranteed_income::Int = 2000
    @in dem_percentages = [1.0]
    @in dem_tiers = [25000]
    @in add_dem_tier = false
    @in remove_dem_tier = false

    @onchange add_dem_tier begin
        @show dem_percentages
        last_percentage = isempty(dem_percentages) ? 1.0 : dem_percentages[end] + 1
        push!(dem_percentages, last_percentage)
        dem_percentages = copy(dem_percentages)

        @show dem_tiers
        last_tier = isempty(dem_tiers) ? 25000 : dem_tiers[end] + 1000
        push!(dem_tiers, last_tier)
        dem_tiers = copy(dem_tiers)
    end

    @onchange remove_dem_tier begin
        if !isempty(dem_tiers)
            @show dem_percentages
            pop!(dem_percentages)
            dem_percentages = copy(dem_percentages)

            @show dem_tiers
            pop!(dem_tiers)
            dem_tiers = copy(dem_tiers)
        end
    end

    # Debt Based parameters
end

@page("/", "app.jl.html")

end