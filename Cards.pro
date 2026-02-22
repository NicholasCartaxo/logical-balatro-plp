:- module(cards, [
    suit/1,
    suitStr/2,
    rank/1,
    rankStr/2,
    rankValue/2,
    rankOrd/2,
    getRanksOrds/2,
    card/1,
    cardStr/2,
    fullDeck/1
]).

suit(X) :- (X == spade,!); (X == heart,!); (X == diamond,!); (X == club,!).

suitStr(spade,"\x2660"). %unicode characters for suits
suitStr(heart,"\x2665").
suitStr(diamond,"\x2666").
suitStr(club,"\x2663").

rank(X) :- (integer(X), X >= 2, X =< 10,!); (X == j,!); (X == q,!); (X == k,!); (X == a,!).

rankStr(j,"J") :- !.
rankStr(q,"Q") :- !.
rankStr(k,"K") :- !.
rankStr(a,"A") :- !.
rankStr(X,R) :- number_string(X,R).

rankValue(a,11) :- !.
rankValue(j,10) :- !.
rankValue(q,10) :- !.
rankValue(k,10) :- !.
rankValue(X,X).

rankOrd(X,X) :- integer(X),X >= 2,X =< 10.
rankOrd(j,11).
rankOrd(q,12).
rankOrd(k,13).
rankOrd(a,14).

getRanksOrds([],[]).
getRanksOrds([[Rank,_] | Tail],[Ord | OrdsTail]) :-
  rankOrd(Rank,Ord),
  getRanksOrds(Tail,OrdsTail).

card([Rank,Suit]) :- rank(Rank),suit(Suit).

cardStr([Rank,Suit],R) :- card([Rank,Suit]), rankStr(Rank,RankS), suitStr(Suit,SuitS), string_concat(RankS,SuitS,R).

fullDeck([[2,spade],[2,heart],[2,diamond],[2,club],
  [3,spade],[3,heart],[3,diamond],[3,club],
  [4,spade],[4,heart],[4,diamond],[4,club],
  [5,spade],[5,heart],[5,diamond],[5,club],
  [6,spade],[6,heart],[6,diamond],[6,club],
  [7,spade],[7,heart],[7,diamond],[7,club],
  [8,spade],[8,heart],[8,diamond],[8,club],
  [9,spade],[9,heart],[9,diamond],[9,club],
  [10,spade],[10,heart],[10,diamond],[10,club],
  [j,spade],[j,heart],[j,diamond],[j,club],
  [q,spade],[q,heart],[q,diamond],[q,club],
  [k,spade],[k,heart],[k,diamond],[k,club],
  [a,spade],[a,heart],[a,diamond],[a,club]]).