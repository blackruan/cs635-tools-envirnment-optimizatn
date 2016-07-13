$title CS635 hw9 problem3  Jin Ruan

set n /1*4/;
alias(n,m);

scalar
    epsilon_inv /-3.71/,
    q /-0.03/;

parameter r_hat(n) /1 0.12, 2 0.1, 3 0.07, 4 0.03/;

table covar(n,m)
      1       2        3      4
1  0.0064  0.0008  -0.0011    0
2  0.0008  0.0025      0      0
3 -0.0011     0     0.0004    0
4     0       0        0      0 ;

positive variables
    x(n) "weights",
    t;

free variables
    tot_ret "total return";

equations
    def_obj,
    eq_sum_weights_lim,
    cons_a(n),
    cons_b,
    cons_c(n),
    def_t,
    cons_d;

def_obj..
    tot_ret =e= sum(n, r_hat(n)*x(n));

eq_sum_weights_lim..
    sum(n, x(n)) =e= 1;

cons_a(n)..
    x(n) =l= 0.4;

cons_b..
    x("4") =l= 0.2;

cons_c(n)..
    x(n) =g= 0.05;

def_t..
    t =e= (1/epsilon_inv) * (q - sum(n, r_hat(n)*x(n)));

cons_d..
    sum((n,m), x(n)*covar(n,m)*x(m)) =l= sqr(t);

model prob3 /all/;
option qcp = cplexd;
solve prob3 using qcp maximizing tot_ret;
display tot_ret.l, x.l;