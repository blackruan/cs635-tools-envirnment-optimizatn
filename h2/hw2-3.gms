option limrow=0, limcol=0;

* SET AND DEFINITIONS

sets
    wands "two types of wands can be produced" /Hufflepuff, Gryffindor/,
    components "types of magical components" /feather, wood/;

scalar max_Gryffindor "maximum amount of Gryffindor can be made" /60/;

table a(wands, components) "magical components requirement for each type of wand"
              feather    wood
Hufflepuff    1          2
Gryffindor    3          2   ;

parameters
disposal(components) "components available to use" /"feather" 200, "wood" 300/,
magic(wands) "magic each type of wand brings" /"Hufflepuff" 1, "Gryffindor" 2/;

* VARIABLE AND EQUATION DECLARATIONS

positive variables x(wands) "amount of each type of wands to produce";

free variable total_magic "the total magic to be maximized";

equations
magic_obj "define the objective function",
comp_limit(components) "limit for each type of components";

* EQUATION DEFINITION

magic_obj..
total_magic =e= sum(wands, magic(wands)*x(wands));

comp_limit(components)..
sum(wands, a(wands, components)*x(wands)) =l= disposal(components);

* VARIABLE BOUNDS
x.up("Gryffindor") = max_Gryffindor;

model prob3 /all/;
solve prob3 using lp maximizing total_magic;