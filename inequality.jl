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
    @out button
end

@onchange button do
    @show "button"
end

end