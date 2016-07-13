$title CS635 hw9 problem2  Jin Ruan

set i /1*3/;
set j /1*2/;

scalar epsilon /0.001/;

free variable x(i), w(j);
free variables
    h "min(x1 + 2, x2 + 2 * x1 - 5)",
    g "min(h, x3 - 6)",
    f "max( x1 + x2 - g, ((x1 - x3)^2 + 2 * x2^2) / (1 - x1) )";

positive variable
    y "((x1 - x3)^2 + 2 * x2^2) / (1 - x1)",
    t "1 - x1";

equations
    eq_h_1,
    eq_h_2,
    eq_g_1,
    eq_g_2,
    eq_f_1,
    eq_f_2,
    eq_x_up(i),
    eq_x_low(i),
    eq_socp,
    eq_t,
    eq_w_1,
    eq_w_2;

eq_h_1..
    h =l= x("1") + 2;

eq_h_2..
    h =l= x("2") + 2 * x("1") - 5;

eq_g_1..
    g =l= h;

eq_g_2..
    g =l= x("3") - 6;

eq_f_1..
    f =g= x("1") + x("2") - g;

eq_f_2..
    f =g= y;

eq_x_up(i)..
    x(i) =l= 1 - epsilon;

eq_x_low(i)..
    x(i) =g= -1 + epsilon;

eq_socp..    
    y*t =g= sum(j, sqr(w(j)));

eq_t..
    t =e= 1 - x("1");

eq_w_1..
    w("1") =e= x("1") - x("3");

eq_w_2..
    w("2") =e= sqrt(2) * x("2");

model prob2 /all/;
option qcp = cplexd;
solve prob2 using qcp minimizing f;
display x.l;

$ontext
For constraint y >= ((x1-x3)^2 + 2*x2^2) / (1-x1), 1-x1 >= 0, y >= 0,
using the converting formula, the standard form of SOCP is
||    2 (x1-x3)   ||
|| 2 (sqrt(2)*x2) ||    <=  1 - x1 + y
||    1 - x1 - y  ||2
$offtext
