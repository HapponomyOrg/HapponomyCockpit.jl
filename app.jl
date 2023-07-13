module App

include("overshoot.jl")

using GenieFramework
using Dates
using DataFrames
using .Overshoot
@genietools

df = create_df()

function filter_df(df)
    nf = DataFrames.select(df, [:year, :overshoot_date, :rounded_weight, :rounded_overshoot_days, :rounded_cumulative_overshoot_days])
    rename!(nf, :year => :Year)
    rename!(nf, :overshoot_date => :"Overshoot date")
    rename!(nf, :rounded_weight => :Weight)
    rename!(nf, :rounded_overshoot_days => :"Overshoot days")
    rename!(nf, :rounded_cumulative_overshoot_days => :"Cumulative overshoot days")

    return nf
end

@app begin
    @in consumption_date = today()

    @out consumed_on = string(calculate_used_date(today(), df))
    @out consuming = string(calculate_using_date(today(), df))

    @in day_weights = PlotData[PlotData(x = df.year, y = df.rounded_weight)]
    @in overshoot_days = PlotData(x = df.year, y = df.rounded_overshoot_days)
    @in cumulative_overshoot_days = PlotData(x = df.year, y = df.rounded_cumulative_overshoot_days)
    
    @in table = DataTable(filter_df(df))

    @onchange consumption_date begin
        consumed_on = string(calculate_used_date(consumption_date))
        consuming = string(calculate_using_date(consumption_date))
    end
end

@page("/", "app.jl.html")
end
