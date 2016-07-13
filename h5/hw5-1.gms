set activity "activities-on-arcs" /AB, AD, BC, BD, BE, CE, CG, DE, DF, EF, EG, EH, FH, GH/;

parameter d_up(activity) "duration at normal point"/AB 4, AD 3, BC 5, BD 5, BE 8, CE 6,
			CG 4, DE 7, DF 9, EF 10, EG 7, EH 3, FH 3, GH 5/;

alias (activity, I, J);

set pred(I, J) "I precedes J" /
    AB.(BC, BD, BE),
    AD.(DE, DF),
    BC.(CE, CG),
    BD.(DE, DF),
    BE.(EF, EG, EH),
    CE.(EF, EG, EH),
    CG.GH,
    DE.(EF, EG, EH),
    DF.FH,
    EF.FH,
    EG.GH/;

free variable projDur "project completion time";
positive variable t(I) "time activity starts";

equations incidence(I,J), endTime(I);

incidence(I,J)$pred(I,J)..
    t(J) =g= t(I) + d_up(I);

endTime(I)..
    projDur =g= t(I) + d_up(I);

model prob1_1 /incidence, endTime/;
solve prob1_1 using lp minimizing projDur;

set critical(activity) "critical activities";
critical(I) = yes$(smax(J$pred(J,I),incidence.m(J,I)) ge 1
            or smax(J$pred(I,J),incidence.m(I,J)) ge 1);
display critical, projDur.l;


scalars
    c_d_low "cost at crash point" /5/,
    c_d_up "cost at normal point" /3/,
    projDurReq "requirement of project completion time";

parameters
d_low(I) "duration at crash point" /AB 3, AD 2, BC 2, BD 4, BE 6, CE 5, CG 2,
		DE 5, DF 8, EF 6, EG 4, EH 2, FH 2, GH 4/;

positive variable d_chosen(I) "actual duration chosen";
free variable cost "total cost";

equations incidence2(I,J), def_cost, projDur_req(I);

incidence2(I,J)$pred(I,J)..
    t(J) =g= t(I) + d_chosen(I);

def_cost..
    cost =e= sum(I, (d_chosen(I)-d_up(I))*(c_d_low-c_d_up)/(d_low(I)-d_up(I)) + c_d_up);

projDur_req(I)..
    projDurReq =g= t(I) + d_chosen(I);

d_chosen.up(I) = d_up(I);
d_chosen.lo(I) = d_low(I);

projDurReq = 25;
model prob1_2_1 /incidence2, def_cost, projDur_req/;
solve prob1_2_1 using lp minimizing cost;

critical(I) = yes$(smax(J$pred(J,I),incidence2.m(J,I)) ge 0.5
            or smax(J$pred(I,J),incidence2.m(I,J)) ge 0.5);

Parameter t_crit(I) "start times of critical activities";
t_crit(critical) = t.l(critical) + EPS;
display critical, t_crit, cost.l;

projDurReq = 20;
model prob1_2_2 /incidence2, def_cost, projDur_req/;
solve prob1_2_2 using lp minimizing cost;

critical(I) = yes$(smax(J$pred(J,I),incidence2.m(J,I)) ge 2
          or smax(J$pred(I,J),incidence2.m(I,J)) ge 2);
t_crit(critical) = t.l(critical) + EPS;
display critical, t_crit, cost.l;


set time "time units" /0*30/;
alias(time, tt);

scalar
    max_wkr "maximum number of workers can be used at any given time" /8/,
    M "upper bound of sum of doact(I, time) over I" /14/;

parameter wkr_req(I) "workers required for each activity" /AB 3, AD 4, BC 2, BD 2, BE 3,
				   CE 2, CG 1, DE 3, DF 1, EF 1, EG 1, EH 1, FH 1, GH 1/;

binary variables
    doact(I, time) "1 if activity is being doing at time; otherwise, 0",
    startact(I, time) "1 if activity starts at time; otherwise, 0",
    endact(I, time) "1 if activity ends at time; otherwise, 0",
    doProj(time) "1 if project is being doing at time; otherwise, 0";

free variable makespan "time needed to finish all activities";

equations
    def_makespan "equation of makespan",
    eq_doact(time) "judge whether all activities are done",
    eq_actDurLim(I) "limit of activity duration",
    eq_workerLim(time) "limit of total workers number",
    eq_actUpdate(I, time) "relation equation between two continuous time steps for each activity",
    eq_startLim(I) "limit of start number",
    eq_endLim(I) "limit of end number",
    eq_precedence(I,J,time) "keep orders of activities";

def_makespan..
    makespan =e= sum(time, doProj(time));

eq_doact(time)..
    sum(I, doact(I, time)) =l= M*doProj(time);

eq_actDurLim(I)..
    sum(time, doact(I, time)) =e= d_up(I);

eq_workerLim(time)..
    sum(I, doact(I, time)*wkr_req(I)) =l= max_wkr;

eq_actUpdate(I, time)..
    doact(I, time) =e= doact(I, time-1) + startact(I, time) - endact(I, time);

eq_startLim(I)..
    sum(time, startact(I, time)) =e= 1;

eq_endLim(I)..
    sum(time, endact(I, time)) =e= 1;

eq_precedence(I,J,time)$pred(I,J)..
    startact(J, time) =l= sum(tt$(ord(tt) le ord(time)), endact(I, tt));

model prob1_3 /def_makespan, eq_doact, eq_actDurLim, eq_workerLim,
	       eq_actUpdate, eq_startLim, eq_endLim, eq_precedence/;
option optcr = 0, optca = 0;
solve prob1_3 using mip minimizing makespan;
display makespan.l, doact.l, doProj.l, startact.l, endact.l;