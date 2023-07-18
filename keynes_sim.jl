module KeynesSim

using GenieFramework
@genietools

using EconoSim

@app begin
    @in sim_length = 100
    @in initial_money_stock = Currency(1000.0)
    @in maturity_range = 20:20
    @in net_profit = 0.01
end

end