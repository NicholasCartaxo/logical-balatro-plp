:- module(gameLoop, [
    roundGameState/1,
    initialRoundGameState/2,
    updateRoundGameState/3,
    playedPokerHandAndChipsMult/3
]).

:- use_module(library(lists)).
:- use_module('cards.pro'). 
:- use_module('hands.pro').
:- use_module('jokers.pro').

roundGameState([Hands, Discards, Hand, Deck, Score, TargetScore, Jokers, PokerHandChipsMult]) :- 
  integer(Hands), Hands >= 0,
  integer(Discards), Discards >= 0,
  %Hand = [[Card, Boolean]]
  %Deck = [Card]
  integer(Score), Score >= 0,
  integer(TargetScore), TargetScore >= 0,
  %Jokers = [Joker]
  chipsMult(PokerHandChipsMult).

initialRoundGameState(FullRoundState, [
  4,
  3,
  Hand,
  Deck,
  0,
  TargetScore,
  Jokers,
  PokerHandChipsMult
]).

initUnselected(Card, [Card, false]).

isValidDigit(C) :-
    C @>= '1',
    C @=< '8'.

separateSelected([], [], []).
separateSelected([[Card, true] | Tail], [Card | SelTail], Unselected) :- separateSelected(Tail, SelTail, Unselected).
separateSelected([[Card, false] | Tail], Selected, [[Card, false] | UnsTail]) :- separateSelected(Tail, Selected, UnsTail).

toggleAtPos(Index, Hand, R) :-
  separateSelected(Hand, Selected, _),
  length(Selected, NumSelected),
  toggleNth(Index, Hand, NumSelected, R).

toggleNth(1, [[Card, false] | Tail], NumSelected, R) :-
  ((NumSelected > 5) -> R = [[Card,false] | Tail]); R = [[Card,true] | Tail], !.

toggleNth(1, [[Card, true] | Tail], _, R) :- R = [[Card,false] | Tail], !.

toggleNth(Index, [Head | Tail], NumSelected, [Head | RTail]) :-
  NextIndex is Index+1,
  toggleNth(NextIndex, Tail, NumSelected, RTail).


drawNCards(N, HandIn, DeckIn, HandOut, DeckOut) :-
  length(DrawnCards, N),
  append(DrawnCards, DeckOut, DeckIn),

  maplist(initUnselected, DrawnCards, UnselectedDrawn),
  append(HandIn, UnselectedDrawn, NewHandUnsorted),
  sortByRank(NewHandUnsorted, HandOut).


compare_rank(Order, [[R1, _], _], [[R2, _], _]) :-
    rankOrd(R1, O1), rankOrd(R2, O2),
    compare(Order, O1, O2).

sortByRank(Hand, Sorted) :- predsort(compare_rank, Hand, Sorted).

compare_suit(Order, [[_, S1], _], [[_, S2], _]) :-
    suitOrd(S1, O1), suitOrd(S2, O2),
    compare(Order, O1, O2).

sortBySuit(Hand, Sorted) :- predsort(compare_suit, Hand, Sorted).


