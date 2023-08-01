module App

using GenieFramework
@genietools

include("app/home/app.jl")
using .Home

include("app/inequality/app.jl")
using .Inequality

include("app/keynes_sim/app.jl")
using .KeynesSim

include("app/overshoot/app.jl")
using .Overshoot

@page("/home", "app/home/app.jl.html", Stipple.ReactiveTools.DEFAULT_LAYOUT(), Main.App.Home)
@page("/inequality", "app/inequality/app.jl.html", Stipple.ReactiveTools.DEFAULT_LAYOUT(), Main.App.Inequality)
@page("/keynes_sim", "app/keynes_sim/app.jl.html", Stipple.ReactiveTools.DEFAULT_LAYOUT(), Main.App.KeynesSim)
@page("/overshoot", "app/overshoot/app.jl.html", Stipple.ReactiveTools.DEFAULT_LAYOUT(), Main.App.Overshoot)

route("/") do
    redirect(:get_home)    
end

end
