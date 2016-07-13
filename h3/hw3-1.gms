option limrow=0, limcol=0;

sets
    Lot "wagon load number" /1*11/,
    Timeslot "total time period to process" /1*4/;

parameters
    Loss(Lot) "loss for each lot (kg/h)" /"1" 43, "2" 26, "3" 37, "4" 38, "5" 13, "6" 54, "7" 62, "8" 49, "9" 19, "10" 28, "11" 30/,
    Lifespan(Lot) "life span for each lot (h)";

Lifespan(Lot) = 8$(not ord(Lot) eq 3 and not ord(Lot) eq 5) + 2$(ord(Lot) eq 3) + 4$(ord(Lot) eq 5);

positive variables x(Timeslot, Lot) "1 indicates lot j was processed in timeslot i";

free variable total_loss "total loss";

equations
    loss_obj "total loss equation",
    prodline_cons(Timeslot) "at most three lot processed each timeslot",
    lot_cons(Lot) "each lot processed exactly once",
    lifespan_cons(Lot) "each lot processed before it expires";

loss_obj..
    total_loss =e= sum((Timeslot, Lot), Loss(Lot)*x(Timeslot, Lot)*2*ord(Timeslot));

prodline_cons(Timeslot)..
    sum(Lot, x(Timeslot, Lot)) =l= 3;

lot_cons(Lot)..
    sum(Timeslot, x(Timeslot, Lot)) =e= 1;
    
lifespan_cons(Lot)..
    sum(Timeslot, x(Timeslot, Lot)*2*ord(Timeslot)) =l= Lifespan(Lot);

model prob1 /all/;
solve prob1 using lp minimizing total_loss;

parameter eachLoss(Timeslot, Lot) "display format: (Timeslot).(Lot) (Loss)";
eachLoss(Timeslot, Lot) = Loss(Lot)*x.L(Timeslot, Lot)*2*ord(Timeslot);
option eachLoss:0:0:1;

display total_loss.L;
display eachLoss;