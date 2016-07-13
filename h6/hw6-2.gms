set I /1*5/;
alias(I, J);

binary variable x(I, J) "number of clicks for each cell";
integer variable d(I, J);

free variable turns "turns needed to turn out all the lights";

equations
    def_turns,
    eq_const(I, J);

def_turns..
    turns =e= sum((I, J), x(I, J));

eq_const(I, J)..
    x(I, J-1) + x(I, J+1) + x(I-1, J) + x(I, J) + x(I+1, J) =e= 2*d(I, J) + 1;

model prob2_1 /def_turns, eq_const/;
solve prob2_1 using mip minimizing turns;


integer variable y(I, J) "number of clicks for each cell";

equations
    def_turns2,
    eq_high_const(I, J),
    eq_medium_const(I, J),
    eq_low_const(I, J);

def_turns2..
    turns =e= sum((I, J), y(I, J));

eq_high_const(I, J)..
    y(I, J-1) + y(I, J+1) + y(I-1, J) + y(I, J) + y(I+1, J) =e= 4*d(I, J) + 1;

eq_medium_const(I, J)..
    y(I, J-1) + y(I, J+1) + y(I-1, J) + y(I, J) + y(I+1, J) =e= 4*d(I, J) + 2;

eq_low_const(I, J)..
    y(I, J-1) + y(I, J+1) + y(I-1, J) + y(I, J) + y(I+1, J) =e= 4*d(I, J) + 3;

option optcr=0;
set threeWay /high, medium, low/;
parameter numOfClicks(threeWay);

model prob2_2_high /def_turns2, eq_high_const/;
solve prob2_2_high using mip minimizing turns;
numOfClicks("high") = turns.l;

model prob2_2_medium /def_turns2, eq_medium_const/;
solve prob2_2_medium using mip minimizing turns;
numOfClicks("medium") = turns.l;

model prob2_2_low /def_turns2, eq_low_const/;
solve prob2_2_low using mip minimizing turns;
numOfClicks("low") = turns.l;

display numOfClicks;

$ontext
numOfClicks: high   39.000,    medium 30.000,    low    29.000
According to the result, turning them off when they're all on low
is easiest.
$offtext