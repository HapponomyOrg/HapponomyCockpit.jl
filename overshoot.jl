module Overshoot

using Dates
using StatsPlots
using DataFrames

OVERSHOOT_DATES = [
    Date(1970, 12, 29),
    Date(1971, 12, 20),
    Date(1972, 12, 9),
    Date(1973, 11, 26),
    Date(1974, 11, 27),
    Date(1975, 11, 30),
    Date(1976, 11, 16),
    Date(1977, 11, 10),
    Date(1978, 11, 7),
    Date(1979, 10, 29),
    Date(1980, 11, 3),
    Date(1981, 11, 11),
    Date(1982, 11, 15),
    Date(1983, 11, 14),
    Date(1984, 11, 6),
    Date(1985, 11, 4),
    Date(1986, 10, 30),
    Date(1987, 10, 23),
    Date(1988, 10, 15),
    Date(1989, 10, 12),
    Date(1990, 10, 11),
    Date(1991, 10, 10),
    Date(1992, 10, 13),
    Date(1993, 10, 13),
    Date(1994, 10, 11),
    Date(1995, 10, 5),
    Date(1996, 10, 2),
    Date(1997, 9, 30),
    Date(1998, 9, 30),
    Date(1999, 9, 30),
    Date(2000, 9, 23),
    Date(2001, 9, 22),
    Date(2002, 9, 19),
    Date(2003, 9, 9),
    Date(2004, 9, 1),
    Date(2005, 8, 26),
    Date(2006, 8, 20),
    Date(2007, 8, 14),
    Date(2008, 8, 15),
    Date(2009, 8, 19),
    Date(2010, 8, 8),
    Date(2011, 8, 4),
    Date(2012, 8, 4),
    Date(2013, 8, 4),
    Date(2014, 8, 5),
    Date(2015, 8, 6),
    Date(2016, 8, 5),
    Date(2017, 8, 3),
    Date(2018, 8, 1),
    Date(2019, 7, 29),
    Date(2020, 8, 22),
    Date(2021, 7, 29),
    Date(2022, 7, 28)
]

function create_df()
    df = DataFrame(year = year.(OVERSHOOT_DATES),
                    overshoot_date = OVERSHOOT_DATES)
    df.weight = daysinyear.(df.year) ./ dayofyear.(df.overshoot_date)
    df.rounded_weight = round.(df.weight, digits = 2)
    df.overshoot_days = df.weight .* daysinyear.(df.year) - daysinyear.(df.year)
    df.rounded_overshoot_days = Int.(round.(df.overshoot_days))

    cumul = Float64[]
    rounded_cumul = Int[]

    for days in df.overshoot_days
        if isempty(cumul)
            push!(cumul, days)
        else
            push!(cumul, cumul[end] + days)
        end

        push!(rounded_cumul, round(cumul[end]))
    end

    df.cumulative_overshoot_days = cumul
    df.rounded_cumulative_overshoot_days = rounded_cumul

    return df
end

function get_year_index(cur_year::Int, df::DataFrame = create_df())
    return findall(x -> x == cur_year, df.year)[1]
end

function get_weight(cur_year::Int, df::DataFrame = create_df())
    return df.weight[get_year_index(cur_year, df)]
end

function get_weight(date::Date, df::DataFrame = create_df())
    get_weight(year(date), df)
end

function calculate_normal_days(date::Date, df::DataFrame = create_df())
    if year(date) < df.year[begin]
        return 0
    else
        normal_days = 0

        for cur_year in df.year[begin]:year(date - Year(1))
            normal_days += daysinyear(cur_year)
        end

        return normal_days + dayofyear(date)
    end
end

function calculate_consumption_days(date::Date, df::DataFrame = create_df())
    cur_year = year(date)

    if cur_year < df.year[begin]
        return 0
    elseif cur_year > df.year[end]
        consumption_days = df.cumulative_overshoot_days[end] + sum(daysinyear.(df.year))
        last_weight = df.weight[end]

        for a_year in (df.year[end] + 1):cur_year - 1
            consumption_days += last_weight * daysinyear(a_year)
        end

        consumption_days += last_weight * dayofyear(date)
    else
        year_index = get_year_index(cur_year, df)
        consumption_days = df.cumulative_overshoot_days[year_index] + sum(daysinyear.(df.year[1:year_index]))
        cur_weight = df.weight[year_index]

        consumption_days -= (daysinyear(cur_year) - dayofyear(date)) * cur_weight
    end

    return Int64(round(consumption_days))
end

function calculate_overshoot_days(date::Date, df::DataFrame = create_df())
    return Int(round(get_weight(year(date), df) * dayofyear(date) - dayofyear(date)))
end

function calculate_cumulative_overshoot_days(date::Date, df::DataFrame = create_df())
    return calculate_consumption_days(date, df) - calculate_normal_days(date, df)
end

function calculate_date(days::Int, df::DataFrame = create_df())
    date = nothing
    cur_year = df.year[begin]

    while isnothing(date)
        if days > daysinyear(cur_year)
            days -= daysinyear(cur_year)
            cur_year += 1
        else
            date = Date(cur_year, 1, 1) + Day(days - 1)
        end
    end

    return date
end

function calculate_using_date(date::Date, df::DataFrame = create_df())
    if year(date) < df.year[begin]
        return date
    else
        return calculate_date(calculate_consumption_days(date, df))
    end
end

function calculate_used_date(date::Date, df::DataFrame = create_df())
    if year(date) < df.year[begin]
        return date
    else
        normal_days = calculate_normal_days(date)
        used_date = nothing
        index = 1

        while isnothing(used_date)
            weight = df.weight[index]
            cur_year = df.year[index]
            days = daysinyear(cur_year)

            if days * weight < normal_days
                normal_days -= days * weight
                index += 1
            else
                consumption_days = round(normal_days / weight)
                used_date = Date(cur_year, 1, 1) + Day(consumption_days - 1)
            end
        end

        return used_date
    end
end

function plot_weights(df::DataFrame = create_df())
end

function plot_overshoot_days(df::DataFrame = create_df())
end

function plot_cumulative_overshoot_days(df::DataFrame = create_df())
end

export create_df
export get_weight
export calculate_using_date, calculate_used_date
export plot_overshoot_days, plot_cumulative_overshoot_days, plot_weights

end