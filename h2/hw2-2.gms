option limrow=0, limcol=0;

* SET AND DEFINITIONS

sets
    method "melting methods" /method_1, method_2/,
    class "classes of grades" /defective, grade_1, grade_2, grade_3, grade_4/,
    subClass(class) "classes of grades can be refired" /defective, grade_1, grade_2, grade_3/;

scalars
    capacity "furnace capacity of transistors" /20000/;

table melting(class, method) "percentage of germanium produced by the melting"
             method_1    method_2
defective    0.3         0.2
grade_1      0.3         0.2
grade_2      0.2         0.25
grade_3      0.15        0.2
grade_4      0.05        0.15  ;

table refire(subClass, class) "results of the refiring process"
            defective   grade_1   grade_2   grade_3   grade_4 
defective    0.3         0.25     0.15      0.2       0.1
grade_1      0           0.3      0.3       0.2       0.2
grade_2      0           0        0.4       0.3       0.3
grade_3      0           0        0         0.5       0.5  ;

parameters
    demand(class) "monthly demands for transistors" /"grade_1" 3000, "grade_2" 3000, "grade_3" 2000, "grade_4" 1000/;

* VARIABLE AND EQUATION DECLARATIONS

positive variables
    x(method, class) "amount of transistors per class produced by the melting of each method",
    y(method) "amount of transistors used to process by each method",
    z(subClass) "amount of transistors used to refire";

free variable total_cost "total cost of melting and refiring";

equations
    cost_obj "cost of germanium processing",
    demand_req_1 "demand requirement of transistors for grade 1",
    demand_req_2 "demand requirement of transistors for grade 2",
    demand_req_3 "demand requirement of transistors for grade 3",
    demand_req_4 "demand requirement of transistors for grade 4",
    capacity_req "capacity requirement of furnace",
    xy_eq(method, class) "relation of x and y",
    maxRefire_req(subClass) "maxmimum amount of transistors can be refired";

* EQUATION DEFINITION

cost_obj..
total_cost =e= 50*y("method_1") + 70*y("method_2") + 25*sum(subClass, z(subClass));

demand_req_1..
sum(method, x(method, "grade_1")) - z("grade_1") + sum(subClass, z(subClass)*refire(subClass, "grade_1")) =g= demand("grade_1");

demand_req_2..
sum(method, x(method, "grade_2")) - z("grade_2") + sum(subClass, z(subClass)*refire(subClass, "grade_2")) =g= demand("grade_2");

demand_req_3..
sum(method, x(method, "grade_3")) - z("grade_3") + sum(subClass, z(subClass)*refire(subClass, "grade_3")) =g= demand("grade_3");

demand_req_4..
sum(method, x(method, "grade_4")) + sum(subClass, z(subClass)*refire(subClass, "grade_4")) =g= demand("grade_4");

capacity_req..
y("method_1") + y("method_2") + sum(subClass, z(subClass)) =l= capacity;

xy_eq(method, class)..
x(method, class) =e= y(method)*melting(class, method);

maxRefire_req(subClass)..
z(subClass) =l= sum(method, x(method, subClass));

model prob2 /all/;
solve prob2 using lp minimizing total_cost;