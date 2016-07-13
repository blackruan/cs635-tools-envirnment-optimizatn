set
P "sets of places" /"Hogwarts", "Godric's Hollow", "Little Whinging", "Shell Cottage", "The Leaky Cauldron",
                    "Ollivander's", "Zonko's Joke Shop", "Dervish and Banges", "Little Hangleton",
		    "Weasley's Wizard Wheezes"/,
Send(P) "sets of places sending out brooms",
Receive(P) "sets of places receiving brooms";

scalar
UnitCost "Cost of transportation per km (galleon)" /0.5/;

parameters
Coor_x(P) "X-coordinate of places" /"Hogwarts" 0, "Godric's Hollow" 20, "Little Whinging" 18, "Shell Cottage" 30,
          "The Leaky Cauldron" 35, "Ollivander's" 33, "Zonko's Joke Shop" 5, "Dervish and Banges" 5, "Little Hangleton" 11,
	  "Weasley's Wizard Wheezes" 2/,
Coor_y(P) "Y-coordinate of places" /"Hogwarts" 0, "Godric's Hollow" 20, "Little Whinging" 10, "Shell Cottage" 12,
          "The Leaky Cauldron" 0, "Ollivander's" 25, "Zonko's Joke Shop" 27, "Dervish and Banges" 10, "Little Hangleton" 0,
	  "Weasley's Wizard Wheezes" 15/,
Br_req(P) "Number of brooms required in place P" /"Hogwarts" 10, "Godric's Hollow" 6, "Little Whinging" 8, "Shell Cottage" 11,
          "The Leaky Cauldron" 9, "Ollivander's" 7, "Zonko's Joke Shop" 15, "Dervish and Banges" 7, "Little Hangleton" 9,
	  "Weasley's Wizard Wheezes" 12/,
Br_cur(P) "Number of brooms currently stored in place P" /"Hogwarts" 8, "Godric's Hollow" 13, "Little Whinging" 4,
          "Shell Cottage" 8, "The Leaky Cauldron" 12, "Ollivander's" 2, "Zonko's Joke Shop" 14, "Dervish and Banges" 11,
	  "Little Hangleton" 15, "Weasley's Wizard Wheezes" 7/,
Dist(P, P) "Euclidean distance between places";

Send(P) = yes$(Br_cur(P) gt Br_req(P));
Receive(P) = yes$(Br_cur(P) lt Br_req(P));
Dist(Send, Receive) = sqrt(sqr(Coor_x(Send)-Coor_x(Receive))+sqr(Coor_y(Send)-Coor_y(Receive)));

positive variables
flow(P, P) "Number of brooms sent between places";

free variables
cost "total transportation cost";

equations
def_cost "Minimize the total transaction cost",
balance_rec_node(P) "balance equation of receiving node",
balance_send_node(P) "balance equation of sending node";

def_cost..
cost =e= UnitCost * sum((Send, Receive), Dist(Send, Receive)*flow(Send, Receive));

balance_rec_node(Receive)..
sum(Send, flow(Send, Receive)) =e= Br_req(Receive) - Br_cur(Receive);

balance_send_node(Send)..
sum(Receive, flow(Send, Receive)) =e= Br_cur(Send) - Br_req(Send);

model prob3 /all/;
option lp = cplex;
solve prob3 using lp minimizing cost;

parameter transportCost ;
transportCost = cost.L;
display transportCost;

set not_from_closest(P);
parameters
closest_dist(P) "Closest distance of places P",
not_from_closest_pair(P, P) "Places J that require extra brooms but do not receive any from their closest location I";

alias(P, ALLI, ALLJ);
Dist(ALLI, ALLJ) = sqrt(sqr(Coor_x(ALLI)-Coor_x(ALLJ))+sqr(Coor_y(ALLI)-Coor_y(ALLJ)));

closest_dist(ALLJ) = smin(ALLI$(ord(ALLI)<>ord(ALLJ)), Dist(ALLI, ALLJ));
not_from_closest_pair(ALLI, Receive) = yes$((Dist(ALLI, Receive) = closest_dist(Receive)) and (flow.l(ALLI, Receive) = 0));
not_from_closest(Receive)=yes$(sum(ALLI, not_from_closest_pair(ALLI, Receive)) > 0);
option not_from_closest:0:0:1;
display not_from_closest;