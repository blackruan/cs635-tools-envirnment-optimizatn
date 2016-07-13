$if not set K $set K 100
$if not set U $set U 10
$if not set theta1 $set theta1 0.4
$if not set theta2 $set theta2 0.2
$if not set T0 $set T0 1.

option limrow=20, limcol=0, solprint=off;

set stages /0 * %K%/;
set states /1*4/;
set inputs /1/;

alias (states,n); alias (inputs,m);

parameter
    R(inputs, inputs) Hessian wrt inputs
    A(states, states) state transition matrix in continuous formulation
    B(states, inputs) input transition matrix in continuous formulation
    Xinitial(states) initial X  /1 %theta1%, 3 %theta2%/;

scalar Ubound /%U%/
       deltaT;

deltaT = %T0% / %K%;

variable
    x(stages,states) state variables
    u(stages,inputs) input variables (controls)
    cost objective function;

table R
     1
1    1;

table A
    1    2    3    4
1   0    1    0    0
2  10    0  -12    0
3   0    0    0    1
4 -10    0   10    0;

table B
   1
1  0
2 -1
3  0
4  0;

equations
        state(stages, states) state transition equation
        objective cost function;

state(stages, states)$(ord(stages) < card(stages))..
    (x(stages+1, states) - x(stages, states)) / deltaT
        =e= sum(n, A(states, n)*x(stages,n))
           +sum(m, B(states, m)*u(stages,m));

objective..
    cost =e= sum(stages$(ord(stages) < card(stages)),
	         sum((inputs,m), u(stages,inputs)*R(inputs,m)*u(stages,m)));

x.fx('0',states) = Xinitial(states);

x.fx('%K%',states) = 0;

u.up(stages, inputs) =  Ubound; u.lo(stages, inputs) = -Ubound;

u.fx(stages, inputs)$(ord(stages) eq card(stages)) = 0;

model prob3 /all/;

solve prob3 using qcp minimizing cost;

display Ubound; display cost.l; display x.l, u.l;

$ontext

At first, the control is input along the forward direction and
the absolute value of input becomes smaller and smaller. And then
after passing zero value, the control is input along the backward
direction, the absolute value becomes bigger and bigger. After
some point, the absolute value begins to become smaller and smaller.
At last, the control is input along the forward direction again and
the absolute value grows.

It is safe to imply that the control swings within a range.

Solution: u(stages, inputs)
              1

0        10.000
1        10.000
2        10.000
3        10.000
4        10.000
5        10.000
6        10.000
7         9.846
8         9.001
9         8.195
10        7.428
11        6.697
12        6.001
13        5.338
14        4.708
15        4.108
16        3.538
17        2.996
18        2.481
19        1.992
20        1.527
21        1.087
22        0.670
23        0.275
24       -0.099
25       -0.453
26       -0.787
27       -1.103
28       -1.400
29       -1.680
30       -1.944
31       -2.191
32       -2.424
33       -2.641
34       -2.844
35       -3.033
36       -3.208
37       -3.371
38       -3.521
39       -3.660
40       -3.786
41       -3.902
42       -4.006
43       -4.100
44       -4.184
45       -4.258
46       -4.322
47       -4.376
48       -4.422
49       -4.458
50       -4.486
51       -4.505
52       -4.515
53       -4.517
54       -4.511
55       -4.497
56       -4.475
57       -4.445
58       -4.408
59       -4.363
60       -4.310
61       -4.249
62       -4.181
63       -4.106
64       -4.022
65       -3.932
66       -3.833
67       -3.727
68       -3.613
69       -3.491
70       -3.362
71       -3.224
72       -3.078
73       -2.924
74       -2.761
75       -2.590
76       -2.410
77       -2.221
78       -2.022
79       -1.814
80       -1.596
81       -1.368
82       -1.130
83       -0.881
84       -0.621
85       -0.349
86       -0.066
87        0.230
88        0.538
89        0.860
90        1.195
91        1.545
92        1.909
93        2.289
94        2.685
95        3.097
96        3.527
97        3.975
98        4.441
99        4.928
$offtext