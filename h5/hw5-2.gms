set mode "modes of transport" /Train, Portkey, Thestral/;
alias(mode, m1, m2);

set pairCt "pairs of cities in order" /1-2, 2-3, 3-4, 4-5/;

table tCost(mode, pairCt) "cost of transport in galleons per dragon between the pairs of cities"
           1-2  2-3  3-4  4-5
Train      30   25   40   60
Portkey    25   40   45   50
Thestral   40   20   50   45 ;

table cCost(m1, m2) "cost of changing the mode of transport in galleons/dragon"
          Train  Portkey  Thestral
Train      0      5        12
Portkey    8      0        10
Thestral   15     10       0  ;

binary variables
    u(mode, pairCt) "1 if the mode is used in this pair of cities, otherwise, 0",
    c(m1, m2, pairCt) "1 if the mode is changed from m1 to m2 at the beginning for this pair of cities";
free variable cost "total cost";

equations
    def_cost "equation of the cost, composed of transport fees and changing-mode fees",
    eq_changeM_lim(mode, pairCt) "limit of changing mode at the beginning of each pair of cities",
    eq_modeUsed_lim(mode, pairCt) "limit of mode used due to mode-changing",
    eq_signle_mode(pairCt) "a single mode of transport is used between two consecutive cities",
    eq_single_change(pairCt) "a single mode-changing can be implemented between two consecutive cities";

def_cost..
    cost =e= sum((mode, pairCt), 20*u(mode, pairCt)*tCost(mode, pairCt))
         + sum((m1, m2, pairCt), 20*c(m1, m2, pairCt)*cCost(m1, m2));

* The mode changed from at the beginning of the pair of cities should be the same with the mode used for
* the previous pair of cities.
eq_changeM_lim(mode, pairCt)$(ord(pairCt) < 4)..
    sum(m2, c(mode, m2, pairCt + 1)) =g= u(mode, pairCt);

* The mode used in a pair of cities should be the same with the mode changed to at the beginning of this
* pair of cities.
eq_modeUsed_lim(mode, pairCt)..
    u(mode, pairCt) =g= sum(m1, c(m1, mode, pairCt));

eq_signle_mode(pairCt)..
    sum(mode, u(mode, pairCt)) =e= 1;

eq_single_change(pairCt)..
    sum((m1, m2), c(m1, m2, pairCt)) =e= 1;

model prob2 /def_cost, eq_changeM_lim, eq_modeUsed_lim, eq_signle_mode, eq_single_change/;
solve prob2 using mip minimizing cost;
display cost.l, u.l;
    