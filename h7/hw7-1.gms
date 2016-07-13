set i /1*10/;
alias(i,j);

table clean(i,j)
   1  2  3  4  5  6  7  8   9  10
1     11 7  13 11 12 4  9   7  11
2  5     13 15 15 6  8  10  9  8
3  13 15    23 11 11 16 18  5  7
4  9  13 5     3  8  10 12  14 5
5  3  7  7  7     9  10 11  12 13
6  10 6  3  4  14    8  5   11 12
7  4  6  7  3  13 7     10  4  6
8  7  8  9  9  12 11 10     10 9
9  9  14 8  4  9  6  10 8      12
10 11 17 11 6  10 4  7  9   11
;

parameter dur(i) /1 40, 2 35, 3 45, 4 32, 5 50, 6 42, 7 44, 8 30, 9 33, 10 55/;

binary variable succ(i,j) "1 if batch j succeeds batch j; otherwise 0";
positive variable y(j) "position of batch j";
free variable obj "objective variable";

equations
    def_obj "objective function",
    assign1(j) "limit of only one successor",
    assign2(i) "limit of only one successor",
    mtz(i,j) "similar to the case of tsp";

def_obj..
    obj =e= sum((i,j), (clean(i,j)+dur(i)) * succ(i,j));

assign1(j)..
    sum(i$(not sameas(i,j)), succ(i,j)) =e= 1;

assign2(i)..
    sum(j$(not sameas(i,j)), succ(i,j)) =e= 1;

mtz(i,j)$(ord(i) ne 1 and ord(j) ne 1)..
    y(i) - y(j) + card(i) * succ(i,j) =L= card(i) - 1;

option optcr = 0;
model prob1 /all/;
solve prob1 using mip minimizing obj;

parameter batchlength;
batchlength = obj.L;
parameter order(i) ;
loop(j,
  order(i+1)$(abs(y.L(j) - ord(i)) < 0.5) = ord(j);
);
display batchlength;
display order;
