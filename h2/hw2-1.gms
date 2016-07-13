option limrow=0, limcol=0;

* SET AND DEFINITIONS

set Ad "media for advertising" /TV, Magazine, Radio/;

scalars
Budget "budget given by company" /1000000/,
MinTV "minimum minutes on TV" /10/,
MaxWeek "maximum wizard-weeks available" /100/,
MinMgz "minimum pages of magazines to sign up" /2/,
MaxRadio "maximum minites of radio" /120/;

parameters
Cost(Ad) "cost per unit of advertisement" /"TV" 20000, "Magazine" 10000, "Radio" 2000/,
Customer(Ad) "customers reached per unit of advertisement" /"TV" 1800000, "Magazine" 1000000, "Radio" 250000/,
Week(Ad) "weeks per unit of advertisement" /"TV" 1, "Magazine" 3, "Radio" [1/7]/;

* VARIABLE AND EQUATION DECLARATIONS

positive variables x(Ad) "amount of each kind of advertisement";

free variable audience "amount of audience";

equations
aud_obj "audiences reached by advertisement",
radio_ign "ignore the factor of radio"
budget_limit "limited amount of budget",
week_limit "maximum amount of available wizard-weeks",
mgz_limit "minimum amount of magazines",
radio_limit "maximum amount of radio";

* EQUATION DEFINITION

aud_obj..
audience =e= sum(Ad, Customer(Ad)*x(Ad));

radio_ign..
x("Radio") =e= 0;

budget_limit..
sum(Ad, Cost(Ad)*x(Ad)) =l= Budget;

week_limit..
sum(Ad, Week(Ad)*x(Ad)) =l= MaxWeek;

mgz_limit..
x("Magazine") =g= MinMgz;

radio_limit..
x("Radio") =l= MaxRadio;

* VARIABLE BOUNDS
x.lo("TV") = MinTV;

* Problem 1.1

model prob1_1 /aud_obj, budget_limit, radio_ign/;
solve prob1_1 using lp maximizing audience;

* Problem 1.2
model prob1_2 /aud_obj, budget_limit, week_limit, radio_ign/;
solve prob1_2 using lp maximizing audience;

* Problem 1.3
model prob1_3 /aud_obj, budget_limit, week_limit/;
solve prob1_3 using lp maximizing audience;

* Problem 1.4
model prob1_4 /aud_obj, budget_limit, week_limit, mgz_limit, radio_limit/;
solve prob1_4 using lp maximizing audience;