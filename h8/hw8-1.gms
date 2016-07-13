$if not set m $set m 4000
$if not set C $set C 1

option limrow=0, limcol=0;

set i, headr;
parameter Data(i,headr);

$gdxin abalone.gdx
$load i, headr
$load Data
$gdxin

alias(headr,k);

sets i_s(i),k_s(k);
i_s(i)$(ord(i) <= %m%) = yes;
k_s(k)$(ord(k) < 11) = yes;

parameters x(i,k), y(i);
x(i,k) = Data(i,k);
y(i) = -1;
y(i)$(Data(i,'Rings') > 10) = 1;

free variables w(k), v(k), gamma;
positive variables a(i), psi(i);
free variables z_primal, z_dual;

equations
    def_obj_dual,
    def_v(k),
    lim_y_a,
    lim_a_up(i);

def_obj_dual..
    z_dual =e= sum(i_s, a(i_s)) - 0.5 * sum(k_s, sqr(v(k_s)));

def_v(k_s)..
    v(k_s) =e= sum(i_s, a(i_s) * y(i_s) * x(i_s, k_s));

lim_y_a..
    sum(i_s, y(i_s) * a(i_s)) =e= 0;

lim_a_up(i_s)..
    a(i_s) =l= %C%;

model prob1_dual /def_obj_dual, def_v, lim_y_a, lim_a_up/;
option optcr=0;
solve prob1_dual using qcp maximizing z_dual;

parameter psi_value(i), gamma_value;
psi_value(i_s) = lim_a_up.m(i_s);
gamma_value = lim_y_a.m;

equations
    def_obj_primal,
    eq_primal(i);

def_obj_primal..
   z_primal =e= 0.5 * sum(k_s, sqr(w(k_s))) + %C% * sum(i_s, psi(i_s));

eq_primal(i_s)..
   y(i_s) * (sum(k_s, w(k_s) * x(i_s,k_s)) + gamma) =g= 1 - psi(i_s);

psi.l(i_s) = psi_value(i_s);
gamma.l = gamma_value;

model prob1_primal /def_obj_primal, eq_primal/; 
option optcr=0;
solve prob1_primal using qcp minimizing z_primal;

set i_pred(i);
i_pred(i)$(ord(i) > %m%) = yes;

parameter y_pred(i), num_error;
y_pred(i_pred) = -1;
y_pred(i_pred)$(sum(k_s, w.l(k_s) * x(i_pred,k_s)) + gamma.l > 0) = 1;
num_error = sum(i_pred, 1$(y_pred(i_pred) <> y(i_pred)));

file report /'error.txt'/;
put report;
put "Number of errors: " num_error:4:0;
putclose report;


