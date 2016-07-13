sets
ALLI /c1*c400/
ALLJ /x1*x100/
;
sets
I(ALLI) /c1*c6/
J(ALLJ) /x1*x4/
;

parameters
TotalDevSmall,
xValSmall(ALLJ),
MinMaxDevSmall,
TotalDevBig
MinMaxDevBig;

parameters
A(ALLI,ALLJ) /c1.x1 8, c1.x2 -2, c1.x3 4, c1.x4 -9,
              c2.x1 1, c2.x2 6, c2.x3 -1, c2.x4 -5,
              c3.x1 1, c3.x2 -1, c3.x3 1, c3.x4 0,
              c4.x1 1, c4.x2 2, c4.x3 -7, c4.x4 4,
              c5.x1 0, c5.x2 0, c5.x3 1, c5.x4 -1,
              c6.x1 1, c6.x2 0, c6.x3 1, c6.x4 -1/,
b(ALLI) /c1 17, c2 -16, c3 7, c4 -15, c5 6, c6 0/;

positive variables
e_plus(ALLI) "auxiliary variables",
e_minus(ALLI) "auxiliary variables";

free variables
x(ALLJ) "variables",
ztotdev "total errors",
zminmax "min max error";

equations
eq_mintotal_dev "total errors to be minimized",
eq_minmax_dev(ALLI) "zminmax greater than all single errors",
eq_abv_cons(ALLI) "Set absolute value constraints";

eq_mintotal_dev..
ztotdev =e= sum(I, e_plus(I) + e_minus(I));

eq_minmax_dev(I)..
zminmax =g= e_plus(I) + e_minus(I);

eq_abv_cons(I)..
e_plus(I) - e_minus(I) =e= sum(J, x(J)*A(I,J))-b(I);

model prob2_1 /eq_mintotal_dev, eq_abv_cons/;
solve prob2_1 using lp minimizing ztotdev;
TotalDevSmall = ztotdev.L ;
xValSmall(J) = x.L(J);
display TotalDevSmall;
display xValSmall;

model prob2_2 /eq_minmax_dev, eq_abv_cons/;
solve prob2_2 using lp minimizing zminmax;
MinMaxDevSmall = zminmax.L;
display MinMaxDevSmall;

*Reset sets
I(ALLI) = yes;
J(ALLJ) = yes;

option seed = 666 ;
A(I,J) = uniform(-10,10) ;
b(I) = uniform(-100,100) ;

model prob2_3 /eq_mintotal_dev, eq_abv_cons/;
solve prob2_3 using lp minimizing ztotdev;
TotalDevBig = ztotdev.L;
display TotalDevBig;

model prob2_4 /eq_minmax_dev, eq_abv_cons/;
solve prob2_4 using lp minimizing zminmax;
MinMaxDevBig = zminmax.L;
display MinMaxDevBig;