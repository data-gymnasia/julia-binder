using Plots, JuMP, Ipopt

mutable struct SVM
    X # training features
    y # training labels
    α
    β
    C
    η
end

SVM(X,y) = SVM(X,y,0,0,1,0)

function dualfit!(S::SVM; C = 1.0)
    S.C = C
    nrows, ncols = size(S.X)
    model = Model(with_optimizer(Ipopt.Optimizer, print_level=0))
    @variable(model, η[1:nrows])
    @variable(model, α)
    @objective(model, Max, -1/2 * (η .* S.y)' * S.X * S.X' * (η .* S.y) + sum(η))
    @constraint(model, 0 .≤ η[1:nrows] .≤ S.C)
    @constraint(model, η' * S.y == 0)
    optimize!(model)
    S.η = value.(η)
    support_vectors = 1e-2 .<  S.η .< S.C - 1e-2
    S.β = S.X' * (S.η .* S.y)
    S.α = mean((S.y - X * S.β)[support_vectors])
    nothing
end

import Plots.plot

function plot(S::SVM)
    zone(t) = t > 1 ? 2 : (t > 0 ? 1 : (t > -1 ? -1 : -2))
    xmin, xmax = extrema(S.X[:,1])
    ymin, ymax = extrema(S.X[:,2])
    xmin -= (xmax - xmin)/20; xmax += (xmax - xmin)/20
    ymin -= (ymax - ymin)/20; ymax += (ymax - ymin)/20
    xgrid = range(xmin, xmax, length=512)
    ygrid = range(ymin, ymax, length=512)
    scatter(X[:,1], X[:,2], group = y, markersize = 2)
    contour!(xgrid, ygrid, (x,y) -> S.β'*[x,y] + S.α, 
              levels = [-1, 0, 1])
    heatmap!(xgrid, ygrid,
             (x,y) -> zone(S.β'*[x,y] + S.α), fillopacity = 0.5, 
             fillcolor = cgrad([:blue, :lightblue, :pink, :red]))
end

function plot(S::SVM, f::Function)
    P = plot(S)
    annotate!(P, [(S.X[i,1],S.X[i,2]-0.2,
                  text("$(abs(round(f(S,i),digits=2)))",8)) for i in 1:size(S.X,1)])
    plot!(P, size = (600,400), colorbar = false, legend = false)
    P
end