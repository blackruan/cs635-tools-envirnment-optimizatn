set airport /MSN, ORD, DTW, MSP, SFO, IAH, DCA, MCO/,
     hub(airport) /ORD, DTW, MSP/,
     hub_delta(hub) /DTW, MSP/,
     des(airport) /SFO, IAH, DCA, MCO/,
     airline /United, Delta/,
     T "order of trips" /1*3/;

parameters
trvl_times(airport, airport) "travel times between various airport in minutes"
   /MSN.ORD 22, MSN.DTW 65, MSN.MSP 46,
   MSP.SFO 213, MSP.IAH 139, MSP.DCA 125, MSP.MCO 176,
   ORD.SFO 247, ORD.IAH 124, ORD.DCA  82, ORD.MCO 135,
   DTW.SFO 280, DTW.IAH 147, DTW.DCA  53, DTW.MCO 130/,
delay_times(airport, airport, T);

option seed = 666 ;
delay_times("ORD", des, T) = uniform(0, 180);
delay_times("DTW", des, T) = uniform(0, 90);
delay_times("MSP", des, T) = uniform(0, 120);

* 4.1 Problem
parameter average_time(airline) "average travelling time for a trip every year";

* As United Aireline only have one hub, we can calculate the average travelling time directly.

* United airline
average_time("United") = sum((des, T), trvl_times("MSN", "ORD") + delay_times("ORD", des, T)
                     + trvl_times("ORD", des)) / 12;

* Delta airline
positive variable x(hub_delta, des, T);
free variable average;

equations
def_obj,
eq_hub_chosen(des, T) "For delta airline, Prof. Wright can only transfer in exactly one hub per trip";

def_obj..
    average =e= sum((hub_delta, des, T), x(hub_delta, des, T)*trvl_times("MSN", hub_delta)
	    + x(hub_delta, des, T)*delay_times(hub_delta, des, T)
	    + x(hub_delta, des, T)*trvl_times(hub_delta, des)) / 12;

eq_hub_chosen(des, T)..
    sum(hub_delta, x(hub_delta, des, T)) =e= 1;

model prob4_1 /def_obj, eq_hub_chosen/;
solve prob4_1 using lp minimizing average;

average_time("Delta") = average.l;
display average_time;

* In problem 4.1, I choose average travelling time to deal with the uncertainty, because I think
* expectation is a basic and a good way to estimate which airline is better. And from the result,
* we can see that "United 242.780,    Delta  226.608", the average travelling time is shorter for
* delta airline compared to united aireline. Based on this reason, I suggest that Delta Airline is
* a better choice for Prof. Wright and he should switch to it.

* 4.2 Problem

* In this part, a constraint that Prof. Wright must always use the same hub is added. Thus, we can
* calculate the average travelling time for "DTW" and "MSP" cases directly. And select the smaller
* one as our average travelling time of Delta.

parameter average2(hub_delta);
average2(hub_delta) = sum((des, T), trvl_times("MSN", hub_delta) + delay_times(hub_delta, des, T)
	            + trvl_times(hub_delta, des)) / 12;
average_time("Delta") = smin(hub_delta, average2(hub_delta));
display average_time;

* From the result "United 242.780,    Delta  254.414", we can see that the average time of Delta becomes
* larger than the one of United in this case. Thus, it is wise to continue choosing United.

* 4.3 Problem
positive variable y(hub, des, T);
free variable average3;

equations
def_obj_p3,
eq_hub_chosen_p3(des, T);

def_obj_p3..
    average3 =e= sum((hub, des, T), y(hub, des, T)*trvl_times("MSN", hub)
	    + y(hub, des, T)*delay_times(hub, des, T) + y(hub, des, T)*trvl_times(hub, des)) / 12;

eq_hub_chosen_p3(des, T)..
    sum(hub, y(hub, des, T)) =e= 1;

model prob4_3 /def_obj_p3, eq_hub_chosen_p3/;
solve prob4_3 using lp minimizing average3;

* Result is shown in route_chosen.

parameter route_chosen(hub, des, T) "hub. destination. ord(trip)";
route_chosen(hub, des, T) = yes$(y.l(hub, des, T) > 0.1); 
option route_chosen:0:0:1;
display route_chosen;