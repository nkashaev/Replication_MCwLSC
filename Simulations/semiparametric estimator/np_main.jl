using Pkg
Pkg.activate(".")

using Distributed
addprocs(7)
using CSV, DataFrames
@everywhere begin
    using Distributions, Random, LinearAlgebra
    ## ######################### Dir ################################################
    tempdir1=@__DIR__
    rootdir=tempdir1[1:findfirst("Random-Coeff",tempdir1)[end]]
    dir=rootdir*"/Simulations/semiparametric estimator/"
    dirresults=dir*"Results/"
    ## ######################### Functions #########################################
    include(dir*"common_functions.jl")
end
order=4
order1=order; order2=order;
Pol, DPol1, DPol2, DPol12, DPol11, DPol22, DPol111, DPol112=polyn(order1,order2);
## ######################### Parameters #########################################
@everywhere begin
    disz="normal"
    #Set disg to "logistic" or mixturenormal
    
    #disg="logistic"
    disg="mixturenormal"
    
    #Set t to 0.0, 1.0, 2.0, 3.0, 4.0, or 5.0
    t=2.0
    param=[-0.5,1.0,0.5,t]
    #Set sampsize to 1000, 5000, or 10000
    sampsize=1000
    Pol=$Pol; DPol1=$DPol1; DPol2=$DPol2; DPol12=$DPol12; DPol11=$DPol11; DPol22=$DPol22; DPol111=$DPol111; DPol112=$DPol112;
end
@time oneSim(8)
@time begin Result=pmap(oneSim,1:1000); end
Bias=zeros(1000,4);
Bias[:,1]=[Result[i][1] .- param[2] for i=1:1000];
Bias[:,2]=[Result[i][2] .- param[2] for i=1:1000];
Bias[:,3]=[Result[i][3] .- param[2] for i=1:1000];
Bias[:,4]=[Result[i][4] .- param[2] for i=1:1000];

CSV.write(dirresults*"bias_np_$(order1)_$(order2)_$(sampsize)_$(disz)_$(disg)_$(param[4]).csv", DataFrame(Bias,:auto))


