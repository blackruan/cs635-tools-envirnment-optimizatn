* Raw Data

set T /1*10/ ;
parameter d(T) / 1 50, 2 60, 3 80, 4 70, 5 50, 6 60, 7 90, 8 80, 9 50, 10 100 / ;

scalar
    alpha cost to buy a new napkin /200/,
    beta cost for fast cleaning services per napkin /75/,
    gamma cost for slow cleaning services per napkin /25/,
    q napkins are returned q days later in fast service /2/,
    p napkins are returned p days later in slow service /4/;
    

* Now build the network (independently)

set Nodes /Source, Sink, C1*C10, D1*D10/;
set Napkins(Nodes) /C1*C10, D1*D10/;
set Clean(Nodes) /C1*C10/;
set Dirty(Nodes) /D1*D10/;

set Arcs(Nodes, Nodes) ;

alias(Nodes, I, J) ;
alias(Napkins, N) ;

Arcs('Source', Clean) = yes;
Arcs(Clean, Clean + 1) = yes;
Arcs(Dirty, 'Sink') = yes;
Arcs(Dirty, Clean)$((ord(Clean) - ord(Dirty)) = q) = yes;
Arcs(Dirty, Clean)$((ord(Clean) - ord(Dirty)) = p) = yes;

option Arcs:0:0:1 ;
display Arcs;

parameters
  c(Nodes,Nodes),
  u(Nodes,Nodes),
  b(Nodes);

b(Clean) = -sum(T$(ord(T)=ord(Clean)), d(T));
b(Dirty) = sum(T$(ord(T)=ord(Dirty)), d(T));

c('Source', Clean) = alpha;
c(Dirty, Clean)$((ord(Clean) - ord(Dirty)) = q) = beta;
c(Dirty, Clean)$((ord(Clean) - ord(Dirty)) = p) = gamma;
u(Arcs) = +INF ;

* Now it is just a regular MCNF (using A,b,c,u)

positive variables x(I,J) ;
free variable total_cost;

equations
  obj_eq,
  flow_balance(I);

obj_eq..
  total_cost =E= sum(Arcs, c(Arcs)*x(Arcs)) ;

flow_balance(N)..
  sum(J$(Arcs(N,J)), x(N,J)) -  sum(J$(Arcs(J,N)), x(J,N)) =E= b(N) ;

x.up(Arcs) = u(Arcs) ;

model prob1 /all/;
solve prob1 using lp minimizing total_cost ;

Parameter Cost "Minimum cost required to meet demand",
	  NumEqu "Number of equations in the GAMS model",
	  NumBought "Total number of napkins purchased";

Cost = total_cost.l;
NumEqu = prob1.numEqu;
NumBought = sum(Clean, x.l("Source", Clean));

display Cost, NumEqu, NumBought;
