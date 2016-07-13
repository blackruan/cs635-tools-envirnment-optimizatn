option limrow=0, limcol=0;

set player /Harry_Potter, Ron_Weasley, Fred_Weasley, George_Weasley,
            Oliver_Wood, Angelina_Johnson, Ginny_Weasley, Hermione_Granger,
            Neville_Longbottom, Seamus_Finnegan, Dean_Thomas,
            Romilda_Vane, Colin_Creevy, Dennis_Creevy, Lavender_Brown,
            Alicia_Spinnet, Katie_Bell, Cormac_McLaggen,
            Demelza_Robinson /,
    position  /seeker, chaser, beater, keeper/ ;

parameter quality(player, position) ;
   option seed = 42;
   quality(player, "seeker") = uniform(32,36);
   quality(player, "chaser") = uniform(38,41);
   quality(player, "beater") = uniform(30,35);
   quality(player, "keeper") = uniform(28,38);
   quality("Harry_Potter", "seeker") = 42 ;

parameter num(position) "number of players for each position" /"seeker" 1, "chaser" 3, "beater" 2, "keeper" 1/;


positive variables x(player, position) "1 indicates player i plays in position j";

free variable teamQuality;

equations
    quality_obj "team quality equation",
    player_cons(player) "one player can at most play in one position",
    number_cons(position) "each position needs exactly one player";

quality_obj..
    teamQuality =e= sum((player, position), x(player, position)*quality(player, position));

player_cons(player)..
    sum(position, x(player, position)) =l= 1;

number_cons(position)..
    sum(player, x(player, position)) =e= num(position);

model prob2 /all/;
solve prob2 using lp maximizing teamQuality;

parameters houseScore;
housescore = teamQuality.L;

set Gryffindor_team(player,position) ;
Gryffindor_team(player,position) = yes$(x.L(player,position) > 0.001) ;
option Gryffindor_team:0:0:1;

display houseScore;
display Gryffindor_team ;
