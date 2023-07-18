module App

using GenieFramework
@genietools

include("home.jl")
using .Home

include("overshoot.jl")
using .Overshoot

include("keynes_sim.jl")
using .KeynesSim

include("inequality.jl")
using .Inequality

Genie.Renderers.Html.register_normal_element(:marquee)

@page("/overshoot", "overshoot.jl.html", Stipple.ReactiveTools.DEFAULT_LAYOUT(), Main.App.Overshoot)
@page("/keynes_sim", "keynes_sim.jl.html", Stipple.ReactiveTools.DEFAULT_LAYOUT(), Main.App.KeynesSim)
@page("/inequality", "inequality.jl.html", Stipple.ReactiveTools.DEFAULT_LAYOUT(), Main.App.Inequality)
end
