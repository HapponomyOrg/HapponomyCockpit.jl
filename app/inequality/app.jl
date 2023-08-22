module Inequality

using GenieFramework
@genietools

using EconoSim

transaction_model_options = [:Yardsale, Symbol("Supplier/Consumer")]
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

    @out transaction_model_options
    @in transaction_model::Symbol = :Yardsale

    # Yardsale
    @in transfer_range::Bool = false
    @in wealth_transfer::Int = 20
    @in wealth_transfer_range::RangeData{Int} = RangeData(10:20)

    @out sim_model_options
    @in sim_model::Symbol = :Standard

    # Standard model parameters
    @in standard_initial_wealth = 1000

    # SuMSy parameters
    @in set_telo::Bool = false
    @in interval::Int = 30
    @in guaranteed_income::Int = 2000
    @out prev_demurrage_free::Int = 0
    @in demurrage_free::Int = 0
    @in transactional::Bool = false
    @in dem_tiers = [[0, 1.0]]
    @in add_dem_tier = false
    @in remove_dem_tier = false
    @in sumsy_initial_wealth::Int = 0

    @onchange add_dem_tier begin
        @show dem_tiers
        last_tier = [dem_tiers[end][1] + 1000, dem_tiers[end][2] + 1]
        push!(dem_tiers, last_tier)
        dem_tiers = copy(dem_tiers)
    end

    @onchange remove_dem_tier begin
        if length(dem_tiers) > 1
            @show dem_tiers
            pop!(dem_tiers)
            dem_tiers = copy(dem_tiers)
        end
    end

    @onchange demurrage_free begin
        @show dem_tiers

        for dem_tier in dem_tiers
            dem_tier[1] += demurrage_free - prev_demurrage_free
        end

        prev_demurrage_free = demurrage_free

        dem_tiers = copy(dem_tiers)
    end

    @onchange set_telo, guaranteed_income, demurrage_free, dem_tiers begin
        @show sumsy_initial_wealth

        if set_telo
            adjusted_dem_tiers = Vector{Tuple{Real, Real}}()

            for tier in dem_tiers
                push!(adjusted_dem_tiers, (tier[1] - demurrage_free, tier[2] / 100))
            end

            sumsy_initial_wealth = Integer(round(telo(guaranteed_income, demurrage_free, adjusted_dem_tiers)))
        end
    end

    # Debt Based parameters
    @in debt_initial_wealth::Int = 0

    # Display options
    @in bottom_1::Bool = true
    @in bottom_10::Bool = true
    @in bottom_50::Bool = true
    @in middle_40::Bool = true
    @in top_10::Bool = true
    @in top_1::Bool = true

    # Run simulation
    @in run_sim = false

    @onchange run_sim begin
        if sim_model === sim_model_options[1] # Standard
            run_standard_simulation()
        elseif sim_model === sim_model_options[2] # SuMSy
        elseif sim_model === sim_model_options[3] # Debt Based
        end
    end
end

@page("/", "app.jl.html")

end