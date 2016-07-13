option limrow=0, limcol=0;

set J /1, 2, 3/;

variable obj "objective value";

positive variables
x(J);

equations
    e1 "equation 1",
    defobj "objective equation";

e1..
    3*x("1") =g= sum(J, x(J));

defobj..
    obj =e= 5*(x("1") + 2*x("2")) - 11*(x("2") - x("3"));

x.up(J) = 3;

model prob2 /all/;

solve prob2 using lp maximizing obj;

display x.l, x.lo, x.up, prob2.objval;
