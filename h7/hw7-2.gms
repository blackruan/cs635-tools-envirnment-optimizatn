set  N  /1*9/;
alias (N,R,C,V);

* Block number ’n’ has (row,column) in it.
set B(N,R,C) /
1.(1*3).(1*3),
2.(1*3).(4*6),
3.(1*3).(7*9),
4.(4*6).(1*3),
5.(4*6).(4*6),
6.(4*6).(7*9),
7.(7*9).(1*3),
8.(7*9).(4*6),
9.(7*9).(7*9)
/;

table P1(R,C) given values
   1  2  3  4  5  6  7  8  9
1     6  7  8  5        3  4
2        4
3  3  1     2        9
4     9        3     8
5
6        6     1        7
7        3        7     4  8
8                    6
9  4  7        8  5  3  2
;

binary variable x(R,C,V) "1 if element(r,c) contains v; otherwise 0";
free variable obj "objective variable";

equations
    def_obj "dummy objective function",
    eq_col_lim(C,V) "each column can only have one v",
    eq_row_lim(R,V) "each row can only have one v",
    eq_block_lim(N,V) "each block can only have one v",
    eq_element_lim(R,C) "each position must have a value",
    eq_element_fix(R,C,V) "fix some positions to the value given in the table";

def_obj..
    obj =e= sum((R,C,V), 0*x(R,C,V));

eq_col_lim(C,V)..
    sum(R, x(R,C,V)) =e= 1;

eq_row_lim(R,V)..
    sum(C, x(R,C,V)) =e= 1;

eq_block_lim(N,V)..
    sum(B(N,R,C), x(R,C,V)) =e= 1;

eq_element_lim(R,C)..
    sum(V, x(R,C,V)) =e= 1;

eq_element_fix(R,C,V)$((P1(R,C) ne 0) and (ord(V) eq P1(R,C)))..
    x(R,C,V) =e= 1;

model prob2_1 /def_obj, eq_col_lim, eq_row_lim, eq_block_lim,
	       eq_element_lim, eq_element_fix/;
solve prob2_1 using mip minimizing obj;

parameter solution(R,C);
loop(V,
solution(R,C)$(x.L(R,C,V) > 0.5) = ord(V);
);
display solution;


set D(R,C) /1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9/;

free variable diagonal "sum of value on diagonal";

equations
    def_diag "definition of diagonal",
    eq_fixNum_lim "at least 24 values needed to be fixed according to the table";

def_diag..
    diagonal =e= sum((D(R,C),V), x(R,C,V)*ord(V));

eq_fixNum_lim..
    sum((R,C,V)$((P1(R,C) ne 0) and (ord(V) eq P1(R,C))), x(R,C,V)) =g= 24;

model prob2_2 /def_diag, eq_col_lim, eq_row_lim, eq_block_lim, eq_element_lim,
	       eq_fixNum_lim/;
solve prob2_2 using mip maximizing diagonal;

parameter solution(R,C);
loop(V,
solution(R,C)$(x.L(R,C,V) > 0.5) = ord(V);
);
display solution;
display diagonal.L;


scalar epsilon /1/;

binary variable sigma "1 if 2 or more '9's on the diagonal; otherwise 0";

equations
    eq_diagonal_lim1,
    eq_diagonal_lim2;

eq_diagonal_lim1..
    sum(D(R,C), x(R,C,"9")) - (7+epsilon)*sigma =l= 2-epsilon;

eq_diagonal_lim2..
    sum(D(R,C), x(R,C,"5")) =g= 3*sigma;

model prob2_3 /def_diag, eq_col_lim, eq_row_lim, eq_block_lim, eq_element_lim,
	       eq_fixNum_lim, eq_diagonal_lim1, eq_diagonal_lim2/;
solve prob2_3 using mip maximizing diagonal;

parameter solution(R,C);
loop(V,
solution(R,C)$(x.L(R,C,V) > 0.5) = ord(V);
);
display solution;
display diagonal.L;
