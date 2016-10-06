
% Dale Heuser
% This is an agent to naviate wumpusworld, it uses a 
% depth first search to go to all squares that it knows are safe

%to debug spy(run_agent).
%then evaluate_agent(1,X,Y).

% Percept = [Stench,Breeze,Glitter,Bump,Scream,NLHint,Image]
% The first five are either 'yes' or 'no'.  

% 0 for north, 1 for east, 2 for south, 3 for west
:-dynamic ([face/1]).
% set of squares that are safe
:-dynamic ([safe/2]).
% form of X,Y,D, at square X,Y, D is the way to face to get back
:-dynamic ([back/3]).
% set of squares that I have been to
:-dynamic ([visited/2]).
% where I am right now
:-dynamic ([here/2]).
%if a square has been used on update_safe it is in here
:-dynamic ([updated/2]).

%this will set up the dynamic facts

init_agent :- 
	retractall(face(_)),
	retractall(safe(_,_)),
	retractall(here(_,_)),
	retractall(visited(_,_)),
	retractall(updated(_,_)),
	retractall(back(_,_,_)),
	assert(face(1)),
	assert(safe(1,1)),
	assert(here(1,1)),
	assert(visited(1,1)),
	%if back D is 5 then if is the exit
	assert(back(1,1,5)).
	
restart_agent :-
	retractall(face(_)),
	retractall(safe(_,_)),
	retractall(here(_,_)),
	retractall(visited(_,_)),
	retractall(updated(_,_)),
	retractall(back(_,_,_)).

%looks at the 4 adjacent squares, if a square safe and not 
%already known to be safe it is added
update_safe(Percept) :-
	here(X,Y),
	not(updated(X,Y)),
	Percept=[no,no|_],
	((X<8,NewX is X+1, not(safe(NewX,Y)), 				 		   assert(safe(NewX,Y)));true),
	((X>1,NewX is X-1, not(safe(NewX,Y)), 
	   assert(safe(NewX,Y)));true),
	((Y<8,NewY is Y+1, not(safe(X,NewY)), 
	   assert(safe(X,NewY)));true),
	((Y>1,NewY is Y-1, not(safe(X,NewY)), 
	   assert(safe(X,NewY)));true),
	assert(updated(X,Y)).

%udate_safe needs to always be true, this make that the case
update_safe(Percept) :- true.

%take gold if it is there
run_agent(Percept,Action) :-
	Percept=[_,_,yes|_], Action=grab.

%if square ahead is safe and unvisited go to it
run_agent(Percept,Action) :-
	update_safe(Percept), 
	face(Dir),
	here(X,Y), 
	goforward(X,Y,Dir),
	Action=goforward.

%see if left square is safe and unvisited
run_agent(Percept,Action) :-
	update_safe(Percept),
	face(Dir),
	here(X,Y),
	turnleft(X,Y,Dir),
	Action=turnleft.

%see if right square is safe and unvisited
run_agent(Percept,Action) :-
	update_safe(Percept),
	face(Dir),
	here(X,Y),
	turnright(X,Y,Dir),
	Action=turnright.

%nothing is safe and unvisited so go back
% want to go back at exit so climb
run_agent(Percept,Action) :-
	here(1,1), 
	Action=climb.
	
%want to go back and are facing the right way
run_agent(Percept,Action) :-
	update_safe(Percept),
	here(X,Y),
	face(Dir),
	back(X,Y,WantDir),
	WantDir=:=Dir,
	goforwardalways(X,Y,Dir), 
	Action=goforward.
	
%want to go back but not facing right way so turn	
run_agent(Percept,Action) :-
	update_safe(Percept),
	here(X,Y),
	face(Dir),
	back(X,Y,WantDir),
	WantDir=\=Dir, 
	Action=turnleft,
	NewDir is (Dir-1) mod 4,
	retract(face(_)),
	assert(face(NewDir)). 

%will see what way agent is facing to go forward
goforward(X,Y,Dir) :-
	(Dir=:=0, gonorth(X,Y));
	(Dir=:=1, goeast(X,Y));
	(Dir=:=2, gosouth(X,Y));
	(Dir=:=3, gowest(X,Y)).

%used in backtacking, will go forward no matter what
goforwardalways(X,Y,Dir) :-
	(Dir=:=0, gonorthalways(X,Y));
	(Dir=:=1, goeastalways(X,Y));
	(Dir=:=2, gosouthalways(X,Y));
	(Dir=:=3, gowestalways(X,Y)).

%turns the agent left
turnleft(X,Y,Dir) :-
	(Dir=:=0, northleft(X,Y,Dir));
	(Dir=:=1, eastleft(X,Y,Dir));
	(Dir=:=2, southleft(X,Y,Dir));
	(Dir=:=3, westleft(X,Y,Dir)).

%turns the agent right
turnright(X,Y,Dir) :-
	(Dir=:=0, northright(X,Y,Dir));
	(Dir=:=1, eastright(X,Y,Dir));
	(Dir=:=2, southright(X,Y,Dir));
	(Dir=:=3, westright(X,Y,Dir)).
	
%if forward square is safe, univisited, and in the world 
%then go to it 
gonorth(X,Y) :-
	Y<8, NewY is Y+1, safe(X,NewY), not(visited(X,NewY)),
	face(Dir),
	NewDir is (Dir+2) mod 4,
	retract(here(_,_)), 
	assert(here(X,NewY)),
	assert(visited(X,NewY)),
	assert(back(X,NewY,NewDir)).
	
goeast(X,Y) :-
	X<8, NewX is X+1, safe(NewX,Y), not(visited(NewX,Y)),
	face(Dir),
	NewDir is (Dir+2) mod 4,
	retract(here(_,_)), 
	assert(here(NewX,Y)),
	assert(visited(NewX,Y)),
	assert(back(NewX,Y,NewDir)).

gosouth(X,Y) :-
	Y>1, NewY is Y-1, safe(X,NewY), not(visited(X,NewY)),
	face(Dir),
	NewDir is (Dir+2) mod 4,
	retract(here(_,_)), 
	assert(here(X,NewY)),
	assert(visited(X,NewY)),
	assert(back(X,NewY,NewDir)).

gowest(X,Y) :-
	X>1, NewX is X-1, safe(NewX,Y), not(visited(NewX,Y)),
	face(Dir),
	NewDir is (Dir+2) mod 4,
	retract(here(_,_)), 
	assert(here(NewX,Y)),
	assert(visited(NewX,Y)),
	assert(back(NewX,Y,NewDir)).

% go forward no matter what, used to backtrack 
gonorthalways(X,Y) :-
	NewY is Y+1,
	retract(here(_,_)), 
	assert(here(X,NewY)),
	assert(visited(X,NewY)),
	assert(back(X,NewY,X,Y)).

goeastalways(X,Y) :-
	NewX is X+1,
	retract(here(_,_)), 
	assert(here(NewX,Y)),
	assert(visited(NewX,Y)),
	assert(back(NewX,Y,X,Y)).

gosouthalways(X,Y) :-
	NewY is Y-1,
	retract(here(_,_)), 
	assert(here(X,NewY)),
	assert(visited(X,NewY)),
	assert(back(X,NewY,X,Y)).

gowestalways(X,Y) :-
	NewX is X-1,
	retract(here(_,_)), 
	assert(here(NewX,Y)),
	assert(visited(NewX,Y)),
	assert(back(NewX,Y,X,Y)).

%check that square to the left is safe and unvisited, 
%if it is face it
northleft(X,Y,Dir) :-
	X>1, NewX is X-1, safe(NewX,Y), not(visited(NewX,Y)),
	NewDir is (Dir-1) mod 4,
	retract(face(_)),
	assert(face(NewDir)).

eastleft(X,Y,Dir) :-
	Y<8, NewY is Y+1, safe(X,NewY), not(visited(X,NewY)),
	NewDir is (Dir-1) mod 4,
	retract(face(_)),
	assert(face(NewDir)).

southleft(X,Y,Dir) :-
	X<8, NewX is X+1, safe(NewX,Y), not(visited(NewX,Y)),
	NewDir is (Dir-1) mod 4,
	retract(face(_)),
	assert(face(NewDir)).
westleft(X,Y,Dir) :-
	Y>1, NewY is Y-1, safe(X,NewY), not(visited(X,NewY)),
	NewDir is (Dir-1) mod 4,
	retract(face(_)),
	assert(face(NewDir)).

%check that square to the right is safe and unvisited, 
%if it is face it
northright(X,Y,Dir) :-
	X<8, NewX is X+1, safe(NewX,Y), not(visited(NewX,Y)),
	NewDir is (Dir+1) mod 4,
	retract(face(_)),
	assert(face(NewDir)).

eastright(X,Y,Dir) :-
	Y>1, NewY is Y-1, safe(X,NewY), not(visited(X,NewY)),
	NewDir is (Dir+1) mod 4,
	retract(face(_)),
	assert(face(NewDir)).

southright(X,Y,Dir) :-
	X>1, NewX is X-1, safe(NewX,Y), not(visited(NewX,Y)),
	NewDir is (Dir+1) mod 4,
	retract(face(_)),
	assert(face(NewDir)).
westright(X,Y,Dir) :-
	Y<8, NewY is Y+1, safe(X,NewY), not(visited(X,NewY)),
	NewDir is (Dir+1) mod 4,
	retract(face(_)),
	assert(face(NewDir)).

