#Main file for simulations with full estimator
# tempdir1=@__DIR__
# rootdir=tempdir1[1:findfirst("HiddenMenus",tempdir1)[end]]
# cd(rootdir*"/Environment/Mac")
# using Pkg
# Pkg.activate(".")

using Distributed
addprocs(7)
using CSV, DataFrames
@everywhere begin
    using Distributions, KNITRO, JuMP, SpecialFunctions, Random, LinearAlgebra, Optim
    ## ######################### Dir ################################################
    tempdir1=@__DIR__
    rootdir=tempdir1[1:findfirst("Random-Coeff",tempdir1)[end]]
    dir=rootdir*"/Simulations/probit estimator/"
    dirresults=dir*"Results/"
    ## ######################### Functions #########################################
    include(dir*"common_functions.jl")
end

@everywhere begin
    #disz="uniform"
    disz="normal"
    #disg="logistic"
    disg="normal"
    #disg="mixturenormal"
    t=0.0
    param=[-0.5,1.0,0.5,t]
    sampsize=10000
end


@time oneSimJ(8)
@time begin Result=pmap(oneSimJ,1:1000); end
# @time begin ResultJ=pmap(oneSimJ,1:1000); end
Bias=[Result[i][1][2] - param[2] for i=1:1000]
CSV.write(dirresults*"biasKN_probit_$(sampsize)_$(disz)_$(disg)_$(param[4]).csv", DataFrame(Bias',:auto))










@everywhere begin
    #disz="uniform"
    disz="normal"
    disg="logistic"
    #disg="normal"
    #disg="mixturenormal"
    t=0.0
    param=[-0.5,1.0,0.5,t]
    sampsize=1000
end


@time oneSimJ(8)
@time begin Result=pmap(oneSimJ,1:1000); end
# @time begin ResultJ=pmap(oneSimJ,1:1000); end
Bias=[Result[i][1][2] - param[2] for i=1:1000]
CSV.write(dirresults*"biasKN_probit_$(sampsize)_$(disz)_$(disg)_$(param[4]).csv", DataFrame(Bias',:auto))

@everywhere begin
    #disz="uniform"
    disz="normal"
    disg="logistic"
    #disg="normal"
    #disg="mixturenormal"
    t=0.0
    param=[-0.5,1.0,0.5,t]
    sampsize=5000
end


@time oneSimJ(8)
@time begin Result=pmap(oneSimJ,1:1000); end
# @time begin ResultJ=pmap(oneSimJ,1:1000); end
Bias=[Result[i][1][2] - param[2] for i=1:1000]
CSV.write(dirresults*"biasKN_probit_$(sampsize)_$(disz)_$(disg)_$(param[4]).csv", DataFrame(Bias',:auto))

@everywhere begin
    #disz="uniform"
    disz="normal"
    disg="logistic"
    #disg="normal"
    #disg="mixturenormal"
    t=0.0
    param=[-0.5,1.0,0.5,t]
    sampsize=10000
end


@time oneSimJ(8)
@time begin Result=pmap(oneSimJ,1:1000); end
# @time begin ResultJ=pmap(oneSimJ,1:1000); end
Bias=[Result[i][1][2] - param[2] for i=1:1000]
CSV.write(dirresults*"biasKN_probit_$(sampsize)_$(disz)_$(disg)_$(param[4]).csv", DataFrame(Bias',:auto))

