option limrow=0, limcol=0;

sets region /A, B/,
     cost /lowcost, highcost/,
     type "types of raw milk" /raw, highfat, lowfat/,
     separated(type) "separated milk" /highfat, lowfat/,
     product /cream, milk/;

table butterfat(region, type) "% of butterfat"
    raw    highfat    lowfat
A   25     41         12
B   15     43         5  ;

table costMilk(region, cost) "normal cost of raw milk and cost after excess (cents)"
    lowcost    highcost
A   54         58
B   38         42  ;

table supply(region, cost) "supply limit in each cost level (gallons)"
    lowcost    highcost
A   500        +inf
B   700        +inf  ;

parameters costSp(region) "cost of separation per gallon (cents)" /"A" 5, "B" 7/,
	   bfReq(product) "minimum requirement: % of butterfat" /"cream" 40, "milk" 20/,
	   maxDem(product) "maximum volume of demand (gallons)" /"cream" 250, "milk" 2000/,
	   price(product) "selling price (cents/gallon)" /"cream" 150, "milk" 70/;

positive variables x(region, cost) "supply of raw milk each region and each cost level",
		   y(product, region, type) "supply of raw or separated milk each region each product",
		   z(product) "volume of products produced";

free variable profit;

equations
    profit_eq "sales value minus cost",
    bf_req(product) "butterfat requirements",
    bf_content(region) "butterfat content is conserved after separation",
    prod_eq(product) "products produced less than all raw milk purchased (free disposal)",
    supply_eq(region) "supply of milk equals the usage of milk";

profit_eq..
    profit =e= sum(product, price(product)*z(product))
    - sum((region, cost), costMilk(region, cost)*x(region, cost))
    - sum(region, costSp(region)*(sum(cost, x(region, cost)) - sum(product, y(product, region, "raw"))));

bf_req(product)..
     bfReq(product)*sum((region, type), y(product, region, type)) =l=
     sum((region, type), y(product, region, type)*butterfat(region, type));

bf_content(region)..
    butterfat(region, "raw")*sum((product, separated), y(product, region, separated)) =e=
    sum((product, separated), butterfat(region, separated)*y(product, region, separated));

prod_eq(product)..
    z(product) =l= sum((region, type), y(product, region, type));

supply_eq(region)..
    sum(cost, x(region, cost)) =e= sum((product, type), y(product, region, type));

x.up(region, cost) = supply(region, cost);

z.up(product) = maxDem(product);

model HMD /all/;
solve HMD using lp maximizing profit;
