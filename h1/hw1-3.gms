option limrow=0, limcol=0;

set material /Malt, Hops, Yeast/;
set beer /Light, Dark/;

table a(beer,material)
        Malt	  Hops	  Yeast
Light	2	  3	  2
Dark	3	  1	  1.667 ;

parameter max_supplies(material) /"Malt" 90, "Hops" 40, "Yeast" 80/;

parameter profit(beer) /"Light" 2, "Dark" 1/;

free variable total_profit  objective value;

positive variables x(beer) number of each type of beer to produce;

equations
    profit_eqn  Define objective,
    max_supplies_eqn(material)  Supplies limit;

profit_eqn..
    total_profit =e= sum(beer, profit(beer)*x(beer));

max_supplies_eqn(material)..
    sum(beer,a(beer,material)*x(beer)) =l= max_supplies(material);

model prob3 /all/;
solve prob3 using lp maximizing total_profit;

