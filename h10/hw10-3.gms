$title CS635 hw10 problem3  Jin Ruan

$if not set n $set n 2000

option limrow = 0, limcol = 0;

set i /1*%n%/;
set j /1*3/;
* generate random reproducable data

option seed = 101;
parameter r(i); r(i) = uniform(0,0.2);
parameter c(i,j); c(i,j) = uniform(0,1);

positive variables
    r_s "radius of the smallest enclosed sphere",
    t(i);
free variable
    c_s(j) "center of the smallest enclosed sphere",
    obj,
    y(i,j);

equations
    def_obj,
    def_t(i),
    def_y(i,j),
    eq_enclose(i);

def_obj..
    obj =e= r_s;

def_t(i)..
    t(i) =e= r_s - r(i);

def_y(i,j)..
    y(i,j) =e= c_s(j) - c(i,j);

eq_enclose(i)..
    sum(j, sqr(y(i,j))) =l= sqr(t(i));

model prob3 /all/;
option qcp = cplexd;
solve prob3 using qcp minimizing obj;
display r_s.l, c_s.l;
