$setglobal NUM_WANDS 1000
$setglobal NUM_COMPONENTS 100
$setglobal DENSITY_CONTROL 0.05
sets
    W Wands /wand1*wand%NUM_WANDS%/
    C Components /component1*component%NUM_COMPONENTS%/
;

parameters
    b(C) Number of components on hand
    g(W) Galleons per wand
    a(C,W)  Number of c requried to make w
    u(W)    Max number of wands to make
    ell(W)    Min number of wans to make
;

scalars
    alpha / %DENSITY_CONTROL% /
;

b(C) = round(uniform(5000,10000)) ;
g(W) = uniform(5,30) ;
a(C,W) = 1$(uniform(0,1) < alpha) + 1$(uniform(0,1) < alpha) ;
ell(W) = round(uniform(5,20)) ;
u(W) = round(uniform(50,100)) ;

positive variables x(W) "amount of each type of wands to produce";

free variable galleons "number of Galleons to maximize";

equations
galleon_obj "define the objective function",
comp_limit(C) "limit for each type of components";

galleon_obj..
galleons =e= sum(W, g(W)*x(W));

comp_limit(C)..
sum(W, a(C,W)*x(W)) =l= b(C);

x.up(W) = u(W);
x.lo(W) = ell(W);

model prob4 /all/;       
solve prob4 using lp maximizing galleons;


