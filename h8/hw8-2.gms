$if not set n $set n 400
$if not set m $set m 100

option limrow=0, limcol=0, solprint=off;

sets
    i /1 * %m%/,
    j /1 * %n%/,
    t /1*100/,
    norm /norm2, norm1, norm_inf/;

parameters b(i), a(i,j), x_hat(j);

free variables x(j), z2, z1, z_inf;

positive variables
    x_plus(j) "auxiliary variables",
    x_minus(j) "auxiliary variables";

equations
    def_P_cond1(i),
    def_P_cond2(i),
    def_z2,
    def_z1,
    def_z_inf(j),
    eq_abv_cons(j);

def_P_cond1(i)$(b(i) >= 0)..
    sum(j, a(i,j)*x(j)) =l= b(i);

def_P_cond2(i)$(b(i) < 0)..
    sum(j, a(i,j)*x(j)) =g= b(i);

def_z2..
    z2 =e= sum(j, sqr(x(j) - x_hat(j)));

def_z1..
    z1 =e= sum(j, x_plus(j) + x_minus(j));

def_z_inf(j)..
    z_inf =g= x_plus(j) + x_minus(j);

eq_abv_cons(j)..
    x_plus(j) - x_minus(j) =e= x(j) - x_hat(j);

* norm2
model prob2_z2 /def_P_cond1, def_P_cond2, def_z2/;

* norm1
model prob2_z1 /def_P_cond1, def_P_cond2, def_z1, eq_abv_cons/;

* norm infinite
model prob2_z_inf /def_P_cond1, def_P_cond2, def_z_inf, eq_abv_cons/;

parameter result(t, norm);

* If the norm is not equal to zero, it means that x_hat does not
* belong to P; otherwise, x_hat belongs to P.

loop( t,
    b(i) = uniform(-10,10);
    a(i,j) = uniform(-2,2);
    x_hat(j) = uniform(-20,20);
    
    solve prob2_z2 using qcp minimizing z2;
    result(t, "norm2") = sqrt(z2.l);
    
    solve prob2_z1 using lp minimizing z1;
    result(t, "norm1") = z1.l;

    solve prob2_z_inf using lp minimizing z_inf;
    result(t, "norm_inf") = z_inf.l;
);

* Since if one of the norm is zero, the other two norms is definitely zero,
* we only need to check norm2 here.
scalar probability "the probability that x_hat belongs to P";
probability = sum(t, 1$(result(t, "norm2") = 0)) / card(t);

display result, probability;

$ontext
We repeated the experiment 100 times. According to the result,
the probability that x_hat belongs to P is zero.
$offtext