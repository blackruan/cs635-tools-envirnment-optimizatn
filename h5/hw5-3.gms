set year /1*5/;
set plant /p1*p4/;

parameter reqCap(year) "in million Kwh" /
        1       80
	2       100
	3       120
	4       140
	5       160
/;

set dfields /
           genCap  generating capacity in Million Kwh
           cCost   construction cost in Million $
           opCost  annual operating cost in Million $
/;

table data(plant,dfields)
           genCap  cCost   opCost
   p1      70      20      1.5
   p2      50      16      0.8
   p3      60      18      1.3
   p4      40      14      0.6 ;

binary variables
    c(year, plant) "1 if the plant is constructed in the year; otherwise, 0",
    op(year, plant) "1 if the plant is operating in the year; otherwise, 0";

free variable totCost "total cost to meet the capacity requirements";
alias(year, Y);

equations
    def_totCost "equation of total cost",
    eq_opLim(year, plant) "a plant can be operating only if it has been constructed in previous years",
    eq_capReq(year) "capacity requirements of every year",
    eq_construLim(plant) "each plant only needs to be constructed at most once";

def_totCost..
    totCost =e= sum((year, plant), data(plant, "cCost")*c(year, plant)
                + data(plant, "opCost")*op(year, plant));

* Assume that once a plant is constructed, it is operating in every following year.
eq_opLim(year, plant)..
    sum(Y$(ord(Y) le ord(year)), c(Y, plant)) =e= op(year, plant);

eq_capReq(year)..
    sum(plant, data(plant, "genCap")*op(year, plant)) =g= reqCap(year);

eq_construLim(plant)..
    sum(year, c(year, plant)) =l= 1;

model prob3_1 /def_totCost, eq_opLim, eq_capReq, eq_construLim/;
option optcr = 0, optca = 0;
solve prob3_1 using mip minimizing totCost;
display totCost.l, c.l, op.l;


set action /reopen,shutdown/;
table costs(plant,action) in Million $
      reopen  shutdown
p1    1.9     1.7
p2    1.5     1.2
p3    1.6     1.3
p4    1.1     0.8 ;

binary variables
    re(year, plant) "1 if the plant is reopened at the beginning of the year, otherwise, 0",
    sh(year, plant) "1 if the plant is shut down at the beginning of the year, otherwise, 0";

equations
    def_totCost_2 "equation of total cost",
    eq_opUpdate(year, plant) "relation equation between two continuous years for each plant",
    eq_actionLim(year, plant) "in each year a plant can reopen, shut down or do nothing";

def_totCost_2..
    totCost =e= sum((year, plant), costs(plant, "reopen")*re(year, plant) +
	costs(plant, "shutdown")*sh(year, plant) + data(plant, "opCost")*op(year, plant));

eq_opUpdate(year, plant)..
    op(year, plant) =e= 1$(ord(year) eq 1) + op(year-1, plant)$(ord(year) gt 1) +
                    re(year, plant) - sh(year, plant);

eq_actionLim(year, plant)..
    re(year, plant) + sh(year, plant) =l= 1;

model prob3_2 /def_totCost_2, eq_opUpdate, eq_actionLim, eq_capReq/;
solve prob3_2 using mip minimizing totCost;
display totCost.l, re.l, sh.l;
    
