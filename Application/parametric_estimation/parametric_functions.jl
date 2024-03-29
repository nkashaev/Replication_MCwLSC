ncdf(x)=(1.0+erf(x/sqrt(2.0)))/2.0  # Normal CDF
npdf(x)=exp(-x^2/2.0)/sqrt(2.0*pi)  # Normal PDF

## Likelihood function
function LogitL(y,z,beta)
    f=0.0
    n,d=size(z)
    for m in 1:n
        al=Int(y[m])
        if al<5
            f=f+log(quadgk(e->exp(beta[3+al]+(beta[1]+beta[2]*z[m,1] + exp(beta[3])*e)*z[m,1+al])*npdf(e)/(1.0+sum(exp(beta[3+i]+(beta[1]+beta[2]*z[m,1]+exp(beta[3])*e)*z[m,1+i]) for i=1:d-1)),-20.0,20.0)[1])
        else
            f=f+log(1.0 -sum(quadgk(e->exp(beta[3+alt]+(beta[1]+beta[2]*z[m,1] + exp(beta[3])*e)*z[m,1+alt])*npdf(e)/(1.0+sum(exp(beta[3+i]+(beta[1]+beta[2]*z[m,1]+exp(beta[3])*e)*z[m,1+i]) for i=1:d-1)),-20.0,20.0)[1] for alt=1:d-1))
        end
    end
    return f
end

