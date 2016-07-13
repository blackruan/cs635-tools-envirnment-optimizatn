$title CS635 hw10 problem4  Jin Ruan

$ontext
"largest area polygon on n-vertices inscribed in the unit circle"
$offtext

$if not set n1 $set n1 15
$if not set n2 $set n2 25
$if not set n3 $set n3 35

set alli /1 * %n3%/;
set i(alli) /1 * %n1%/;

positive variables beta(alli) "radius angle of side i in radians";
free variable area "total area";

equations
    def_area,
    eq_angle_lim;

def_area..
    area =e= sum(i, 0.5 * sin(beta(i)));

eq_angle_lim..
    sum(i, beta(i)) =e= 2 * pi;

beta.up(i) = pi;

* calculate for n = 15
model prob4 /all/;
solve prob4 using nlp maximizing area;
display area.l, beta.l;

* calculate for n = 25
i(alli)$(ord(alli) <= %n2%) = yes;
solve prob4 using nlp maximizing area;
display area.l, beta.l;

* calculate for n = 35
i(alli) = yes;
solve prob4 using nlp maximizing area;
display area.l, beta.l;