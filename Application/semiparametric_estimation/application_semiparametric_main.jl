using Pkg
Pkg.activate(".")

using CSV, DataFrames
using LinearAlgebra
using Random
using Distributions, Statistics
using ForwardDiff

## Directories
tempdir1=@__DIR__
rootdir=tempdir1[1:findfirst("Random-Coeff",tempdir1)[end]]
dir=rootdir*"/Application/semiparametric_estimation/"
dirresults=rootdir*"/Application/results/"
dirdata=rootdir*"/Application/data/"

## Functions
include(dir*"/semiparametric_functions.jl")

## Data
data=CSV.read(dirdata*"margarine_subset.csv", DataFrame)
id=data[:,1];
choice=data[:,2];
z21=data[:,3]; #Blue Bonnet
z22=data[:,4]; #Fleischmann’s
z23=data[:,5]; #House Brand
z24=data[:,6]; #Generic
z25=data[:,7]; #Shed Spread
z1=data[:,8];

# Choice data
choice=data[:,2]; #2=Blue Bonnet, 3=Fleischman's,
                  #4=House brand, 5=Generic brand, 7=Shed Spread
n=length(choice); # Sample size

## Tuning parameters
# Orders of Chebyshev polinomials
order1=4;
order2=1;

## Determining the sign of beta1
# I use y=3 (Fleischman's) to determine the sign of beta1, since only in this case
# the sign restrictions on z_2 are satisfied.
ydata=(choice.==3) # Setting Fleischman's as an outside good
xdata=hcat(z1,z21-z22,z23-z22,z24-z22,z25-z22) # z22 -- price of Fleischman's
# Rescalling z to a box
b=maximum(xdata,dims=1)'
a=minimum(xdata,dims=1)'
shift_ap=(a.+b)./(b.-a)
scale_ap=diagm(vec(2.0./(b.-a)))
# Computing the polynomials
sieve_func=Cheb2_func_gen_app(order1,order2,scale_ap,shift_ap)
# Estimating p_0
eta, gammahat, Psi=EstCoef_app(sieve_func,ydata,xdata)
f1,f2,f11,f12,f111=derivatives_app(eta)
# Estimating the sign of beta1
signbeta1=betasign1(f1,xdata)

## Estimating beta
# For estimation of beta I use y=5 (Generic)
ydata=(choice.==5) # Setting Generic as an outside good
xdata=hcat(z1,z21-z24,z22-z24,z23-z24,z25-z24) # z24 -- price of Generic
# Rescalling z to a box
b=maximum(xdata,dims=1)'
a=minimum(xdata,dims=1)'
shift_ap=(a.+b)./(b.-a)
scale_ap=diagm(vec(2.0./(b.-a)))
# Computing the polynomials
sieve_func=Cheb2_func_gen_app(order1,order2,scale_ap,shift_ap)
# Estimating p_0
eta, gammahat, Psi=EstCoef_app(sieve_func,ydata,xdata)
f1,f2,f11,f12,f111=derivatives_app(eta)
# Estimating beta: betahat[1]=betahat1, betahat[2]=betahat0
betahat, G11,G22=beta_coeff_app(f1,f2,f11,f12,f111,xdata,signbeta1)

## Estimating As. Variance
Qhat=Psi'*Psi./n;
Ghat=diagm([2*betahat[1], 1])*inv(diagm([G11,G22]));
sfunc1, sfunc11, sfunc111, sfunc2=derivativesofsieves(sieve_func);
Ahat, Sigmahat=Asy_variance(sieve_func,eta, sfunc1, sfunc11, sfunc111, sfunc2,betahat[1],gammahat, ydata,xdata);
Vhat=Ghat*Ahat'*inv(Qhat)*Sigmahat*inv(Qhat)*Ahat*Ghat';
# Standard errors for betas
seg=sqrt.(diag(Vhat/n))

## Estimating beta1 max_iz^i_1/beta0
Ratio=betahat[1]*maximum(xdata[:,1])/betahat[2]
grad=[maximum(xdata[:,1])/betahat[2];-betahat[1]*maximum(xdata[:,1])/betahat[2]^2]
# Standard error
serat=sqrt.(grad'*Vhat*grad/n)

## Combining and saving the results
Results=DataFrame(variable=["estimate", "std.err"], beta1=[betahat[1], seg[1]], beta0=[betahat[2], seg[2]], ratio=[Ratio, serat])
CSV.write(dirresults*"estimates_and_se.csv", Results)
