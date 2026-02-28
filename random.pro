:- module(random, [
    getRandomItem/2,
    getRandomItems/3,
    shuffle/2,
]).

getRandomItem([], []).
getRandomItem(Xs, R) :-
    length(Xs, Len),
    Max is Len-1,
    random_between(0, Max, RandIdx),
    nth0(RandIdx, Xs, R). 

getRandomItems(N, Xs, R) :- 
    shuffle(Xs, ListShuffled),
    take(N, ListShuffled, R).
    
take(_, [], []).
take(0, _, []).
take(N, [Head|Tail], [Head|Rest]) :-
    N > 0,
    N1 is N-1,
    take(N1, Tail, Rest).

shuffle([], []).          
shuffle(Xs, [Picked|ShuffledRest]) :-
    length(Xs, Len),
    Max is Len-1,
    random_between(0, Max, RandIdx),
    nth0(RandIdx, Xs, Picked, Rest),
    shuffle(Rest, ShuffledRest).

