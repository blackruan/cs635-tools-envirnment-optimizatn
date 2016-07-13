sets
    T /t1*t24/
    P /p1*p10/
    C(P)
    N(P)
;

C(P) = yes$(mod(ord(P),2) = 0) ;
N(P) = yes$(mod(ord(P),2) = 1) ;

alias (S,T) ;

parameters
    d(T)
    cost(P)
    ell(P)
    u(P)
;

option seed = 666 ;
d(T) = uniform(100,1000) ;
cost(P) = uniform(6,8) ;
ell(P) = uniform(100,150) ;
u(P) = 2*ell(P) ;

positive variable x(T,P) "amount of power produced in plant P at T";

binary variables
    z(T,P) "1 if the plant P is operating at T, otherwise, 0",
    delta(T) "1 if 2 or more coal generation plants are operating at T",
    sigma(T,P) "1 if a nuclear plant N initially start to generate power at T";

free variable totcost "total cost";

equations
    def_totcost "equation of total cost",
    eq_demandReq(T) "requirements of demand in each period",
    eq1_envirmRegult(T) "equation1 of environment regulation requirement",
    eq2_envirmRegult(T) "equation2 of environment regulation requirement",
    eq1_meltdown(T,P) "equation1 of meltdown requirement",
    eq2_meltdown(T,P) "equation2 of meltdown requirement",
    eq_x_upperBound "upper bound equation of x(T,P)",
    eq_x_lowerBound "lower bound equation of x(T,P)";
    
def_totcost..
    totcost =e= sum((T,P), cost(P)*x(T,P));

eq_demandReq(T)..
    sum(P, x(T,P)) =g= d(T);

eq1_envirmRegult(T)..
    sum(C, z(T,C)) - (card(C)+1)*delta(T) =l= 2-1;

eq2_envirmRegult(T)..
    sum(N, z(T,N)) + (-3)*delta(T) =g= -3+3;

eq1_meltdown(T,N)..
    z(T,N) - z(T-1,N) =l= sigma(T,N);

eq2_meltdown(T,N)..
    z(T+1,N)+z(T+2,N)+z(T+3,N) + (-3)*sigma(T,N) =g= -3+3;

* Limit the upper bound and lower bound of variable x in the form of equation
* of x and z. In this way, relationship between x and z is also defined.

eq_x_upperBound(T,P)..
    x(T,P) =l= u(P)*z(T,P);

eq_x_lowerBound(T,P)..
    x(T,P) =g= ell(P)*z(T,P);

option optcr = 0;
model prob3 /all/;
solve prob3 using mip minimizing totcost;
display totcost.l, z.l, x.l;
