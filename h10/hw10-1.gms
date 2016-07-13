$title CS635 hw10 problem1  Jin Ruan

* number of x variables
$if not set n $set n 5
* number of observations
$if not set t $set t 50

option limrow=0, limcol=0;

sets
    i /1 * %n%/,
    s /1 * %t%/;

alias(i,j,k);

parameters
    x(s,i),
    y(s),
    R(i,j),
    R_t(i,j) "transpose of R",
    Q_hat(i,j) "coefficient matrix for quadratic terms",
    p_hat(i) "coefficient vector for linear terms",
    c_hat "constant term";

option seed = 101;
x(s,i) = uniform(0,1);

* lower triangular matrix
R(i,j) = uniform(0,1)$(ord(i) >= ord(j));
R_t(i,j) = R(j,i);

p_hat(i) = uniform(0,1);
c_hat = uniform(0,1);

Q_hat(i,j) = sum(k, R(i,k) * R_t(k,j));

y(s) = sum((i,j), x(s, i) * Q_hat(i,j) * x(s, j)) +
    sum(i, p_hat(i) * x(s, i)) + c_hat;

free variables Q(i,j), p(i), c;
free variable
    f(s) "predictive value",
    z "objective";

equations
    def_obj,
    eq_f(s);

def_obj..
    z =e= sum(s, sqr(y(s) - f(s)));

eq_f(s)..
    f(s) =e= sum((i,j), x(s, i) * Q(i,j) * x(s, j)) +
        sum(i, p(i) * x(s, i)) + c;

model prob1 /all/;
solve prob1 using nlp minimizing z;

display Q.l, Q_hat, p.l, p_hat, c.l, c_hat;
display x, y;

$ontext
In my test case, the solution of Q, p, c is exactly equal to the
random inputs Q_hat, p_hat, c_hat. But we need to generate enought
data (x and y) to guarantee it.
$offtext
