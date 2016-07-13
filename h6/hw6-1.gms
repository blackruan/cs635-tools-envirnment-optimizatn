sets
    glass "types of glass" /wine, beer, champagne, whiskey/,
    resource "types of resources" /moldingTime, packagingTime, glassAmount/;

parameters
    resourceAvail(resource) "amount of resources available" /moldingTime 600, packagingTime 400, glassAmount 500/,
    price(glass) "selling price" /wine 6, beer 10, champagne 9, whiskey 20/;

table req(glass, resource) "resources required to make each type of glass"
              moldingTime      packagingTime      glassAmount
wine               4                 1                3
beer               9                 1                4
champagne          7                 3                2
whiskey           10                40                1  ;

positive variable x(glass) "amount of each type of glass produced";
free variable revenue;

equations
    def_revenue "Objective function for revenue",
    eq_resource_lim(resource) "limits of amount of resources available";

def_revenue..
    revenue =e= sum(glass, price(glass)*x(glass));

eq_resource_lim(resource)..
    sum(glass, x(glass)*req(glass, resource)) =l= resourceAvail(resource);

model prob1_1 /def_revenue, eq_resource_lim/;
solve prob1_1 using lp maximizing revenue;
display revenue.l;


positive variable pi(resource) "dual variables of resource";
free variable dual_revenue "dual variable of revenue";

equations
    def_dual_revenue "objective function for dual of revenue",
    dual_price_eq(glass) "constraints for the dual problem";

def_dual_revenue..
    dual_revenue =e= sum(resource, resourceAvail(resource)*pi(resource));

dual_price_eq(glass)..
    sum(resource, pi(resource)*req(glass, resource)) =g= price(glass);

model prob1_2 /def_dual_revenue, dual_price_eq/;
solve prob1_2 using lp minimizing dual_revenue;
display dual_revenue.l;


$ontext
The marginals of the constraints in Problem 1.1 are equal to the levels of the
variables in Problem 1.2. The marginals of the constraints in Problem 1.2 are
equal to the levels of the variables in Problem 1.1.
$offtext

display eq_resource_lim.m, pi.l;
display dual_price_eq.m, x.l;