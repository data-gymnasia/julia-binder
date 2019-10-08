using LinearAlgebra, Statistics, Roots, Optim, Plots, Random
Random.seed!(1234)
n = 1000 # number of observations to draw

# the true regression function
r(x) = 2 + 1/50*x*(30-x)
# the true density function
σy = 3/2  
f(x,y) = 3/4000 * 1/√(2π*σy^2) * x*(20-x)*exp(-1/(2σy^2)*(y-r(x))^2)

# x values and y values for a grid
xs = 0:1/2^3:20
ys = 0:1/2^3:10

# F(t) is the CDF of X
F(t) = -t^3/4000 + 3t^2/400

"Sample from the distribution of X (inverse CDF trick)"
function sampleX()
    U = rand()
    find_zero(t->F(t)-U,(0,20),Bisection())
end

"Sample from joint distribution of X and Y"
function sampleXY(r,σ)
    X = sampleX()
    Y = r(X) + σ*randn()
    (X,Y)
end

# Sample n observations
sample = [sampleXY(r,σy) for i=1:n]