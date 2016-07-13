option limrow=0, limcol=0;

positive variables x1, x2, x3;
variable obj "objective value";

equations
    e1 "equation 1",
    e2 "equation 2",
    e3 "equation 3",
    defobj "objective equation";

e1..
    x1 - 4*x2 + x3 =l= 15;

e2..
    9*x1 + 6*x3 =e= 12;

e3..
    -5*x1 + 9*x2 =g= 3;

defobj..
    obj =e= 3*x1 + 2*x2 - 33*x3;

model prob1 /e1,e2,e3,defobj/;
solve prob1 using lp minimizing obj;

parameter x1val, x2val, x3val, objval;
objval = obj.l;
x1val = x1.l;
x2val = x2.l;
x3val = x3.l;
display objval, x1val, x2val, x3val;
