$title CS635 hw10 problem2  Jin Ruan

scalar W / 15 /, b1 /2/, b2 /3/, b3 /0.5/, b4 /1/;
scalar s /1/;

positive variables
    d "average tube diameter",
    t "tube thickness",
    h "truss height";
free variable weight;

equations
    def_weight,
    eq_space_lim,
    eq_ratio_lim,
    eq_comp_stress_lim,
    eq_tube_buckle,
    eq_thick_up,
    eq_thick_lo;

* According to what Prof. Ferris mentioned in the Piazza, we should
* consider d as "outer diameter". So according to the area formula of
* the ring, pi*(R^2 - r^2), in our case:
* R = d/2; r = d/2 - t.
def_weight..
    weight =e= pi*(sqr(d/2) - sqr(d/2-t)) * sqrt(sqr(h)+sqr(s)) * 2;

eq_space_lim..
    h =l= b1;

eq_ratio_lim..
    d / t =l= b2;

eq_comp_stress_lim..
    W * sqrt(sqr(s) + sqr(h)) =l= b3*d*t*h;

eq_tube_buckle..
    W * (sqr(s) + sqr(h))**(3/2) =l= b4*d*h*(sqr(d)+sqr(t));

eq_thick_up..
    2*t =l= d;

eq_thick_lo..
    t =g= 0.0001;

model prob2 /all/;

sets
    itr /1*5/,
    var /"d", "t", "h", "weight"/,
    solver /"conopt", "ipopt"/;

parameter result(itr, var, solver);

loop( itr,
    h.l = uniform(0,b1);
    d.l = uniform(0,1);
    t.l = d.l / uniform(2,b2);

    option nlp = conopt;
    solve prob2 using nlp minimizing weight;
    result(itr, "d", "conopt") = d.l;
    result(itr, "t", "conopt") = t.l;
    result(itr, "h", "conopt") = h.l;
    result(itr, "weight", "conopt") = weight.l;
);

loop( itr,
    h.l = uniform(0,b1);
    d.l = uniform(0,1);
    t.l = d.l / uniform(2,b2);

    option nlp = ipopt;
    solve prob2 using nlp minimizing weight;
    result(itr, "d", "ipopt") = d.l;
    result(itr, "t", "ipopt") = t.l;
    result(itr, "h", "ipopt") = h.l;
    result(itr, "weight", "ipopt") = weight.l;
);

display result;