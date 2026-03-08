:- module(gameLoop, [
    roundGameState/1,
    initialRoundGameState/2,
    updateRoundGameState/3,
    playedPokerHandAndChipsMult/3
]).

:- use_module(library(lists)).
:- use_module('Cards.pro'). 
:- use_module('pokerHands.pro').
:- use_module('jokers.pro').
:- use_module('fullRoundLoop.pro').
:- use_module('my_random.pro').

roundGameState([Hands, Discards, Hand, Deck, Score, TargetScore, Jokers, PokerHandChipsMult]) :- 
  integer(Hands), Hands >= 0,
  integer(Discards), Discards >= 0,
  %Hand = [[Card, Boolean]]
  %Deck = [Card]
  integer(Score), Score >= 0,
  integer(TargetScore), TargetScore >= 0.
  %Jokers = [Joker]
  %PokerHandChipsMult = PokerHand -> ChipsMult

initialRoundGameState(FullRoundState, [4, 3, Hand, RestDeck, 0, TargetScore, Jokers, PokerHandChipsMult]) :-
  FullRoundState = [TargetScore, _, Jokers, PokerHandChipsMult],
  fullDeck(Deck),
  shuffle(Deck, ShuffledDeck),

  length(InitialCards, 8),
  append(InitialCards, RestDeck, ShuffledDeck), 

  maplist(initUnselected, InitialCards, InitialHandUnsorted),
  sortByRank(InitialHandUnsorted, Hand).
  
initUnselected(Card, [Card, false]).

separateSelected([], [], []).
separateSelected([[Card, true] | Tail], [Card | SelTail], Unselected) :- separateSelected(Tail, SelTail, Unselected).
separateSelected([[Card, false] | Tail], Selected, [[Card, false] | UnsTail]) :- separateSelected(Tail, Selected, UnsTail).

toggleAtPos(Index, Hand, R) :-
  separateSelected(Hand, Selected, _),
  length(Selected, NumSelected),
  toggleNth(Index, Hand, NumSelected, R).

toggleNth(1, [[Card, false] | Tail], NumSelected, R) :-
  ((NumSelected >= 5) -> R = [[Card,false] | Tail]); R = [[Card,true] | Tail], !.

toggleNth(1, [[Card, false] | Tail], NumSelected, [[Card,true] | Tail]) :-
    NumSelected < 5, !.

toggleNth(1, [[Card, false] | Tail], NumSelected, [[Card,false] | Tail]) :-
    NumSelected >= 5, !.

toggleNth(1, [[Card, true] | Tail], _, [[Card,false] | Tail]) :- !.

toggleNth(Index, [Head | Tail], NumSelected, [Head | RTail]) :-
    Index > 1,
    I1 is Index - 1,
    toggleNth(I1, Tail, NumSelected, RTail).

drawNCards(N, HandIn, DeckIn, HandOut, DeckOut) :-
  length(DrawnCards, N),
  append(DrawnCards, DeckOut, DeckIn),

  maplist(initUnselected, DrawnCards, UnselectedDrawn),
  append(HandIn, UnselectedDrawn, NewHandUnsorted),
  sortByRank(NewHandUnsorted, HandOut).


compare_rank(Order, [[R1,S1],_], [[R2,S2],_]) :-
    rankOrd(R1,O1),
    rankOrd(R2,O2),
    ( O1 =:= O2 ->
        suitOrd(S1,SO1),
        suitOrd(S2,SO2),
        compare(Order,SO1,SO2)
    ;
        compare(Order,O1,O2)
    ).

sortByRank(Hand, Sorted) :- predsort(compare_rank, Hand, Sorted).

compare_suit(Order, [[R1,S1],_], [[R2,S2],_]) :-
    suitOrd(S1,O1),
    suitOrd(S2,O2),
    ( O1 =:= O2 ->
        rankOrd(R1,RO1),
        rankOrd(R2,RO2),
        compare(Order,RO1,RO2)
    ;
        compare(Order,O1,O2)
    ).

sortBySuit(Hand, Sorted) :- predsort(compare_suit, Hand, Sorted).


applyJokers([], ChipsMult, _, _, ChipsMult).
applyJokers([Joker | Tail], CurrentCM, PokerHand, ScoredHand, FinalCM) :-
  applyJoker(Joker, CurrentCM, PokerHand, ScoredHand, NextCM),
  applyJokers(Tail, NextCM, PokerHand, ScoredHand, FinalCM).

playedPokerHandAndChipsMult(State, PokerHand, ChipsMult) :-
  State = [_, _, Hand, _, _, _, Jokers, PokerHandChipsMult],
  separateSelected(Hand, SelectedHand, _),
  ( SelectedHand == [] -> 
    PokerHand = highCard, ChipsMult = [0, 0]
  ;   
    getPokerHandAndCards(SelectedHand, PokerHand, ScoredHand),
    getChipsMultOfHand(PokerHandChipsMult, SelectedHand, BaseChipsMult),
    applyJokers(Jokers, BaseChipsMult, PokerHand, ScoredHand, ChipsMult)
  ).

isValidDigit(C,Int) :-
  C @>= '1',
  C @=< '8',
  atom_number(C,Int).

updateRoundGameState(Action, StateIn, StateOut) :-
  StateIn = [Hands, Discards, Hand, Deck, Score, TargetScore, Jokers, PokerHandChipsMult], 
  ( 
    isValidDigit(Action, Index) ->  
    toggleAtPos(Index, Hand, NewHand),
    StateOut = [Hands, Discards, NewHand, Deck, Score, TargetScore, Jokers, PokerHandChipsMult]
  ;
    Action == q, Hands > 0,
    separateSelected(Hand, SelectedHand, RemainingHand),
    SelectedHand \= [] ->
    
    playedPokerHandAndChipsMult(StateIn, _, ChipsMult),
    getScore(ChipsMult, EarnedScore),
    NewScore is Score + EarnedScore,
    NewHands is Hands - 1,
    
    length(SelectedHand, N),
    drawNCards(N, RemainingHand, Deck, NextHand, NextDeck),
    StateOut = [NewHands, Discards, NextHand, NextDeck, NewScore, TargetScore, Jokers, PokerHandChipsMult]
  ;  
    Action == w, Discards > 0,
    separateSelected(Hand, SelectedHand, RemainingHand),
    SelectedHand \= [] ->
    
    NewDiscards is Discards - 1,
    length(SelectedHand, N),
    drawNCards(N, RemainingHand, Deck, NextHand, NextDeck),
    StateOut = [Hands, NewDiscards, NextHand, NextDeck, Score, TargetScore, Jokers, PokerHandChipsMult]
  ; 
    Action == e ->
    sortBySuit(Hand, SortedHand),
    StateOut = [Hands, Discards, SortedHand, Deck, Score, TargetScore, Jokers, PokerHandChipsMult]
  ;  
    Action == r ->
    sortByRank(Hand, SortedHand),
    StateOut = [Hands, Discards, SortedHand, Deck, Score, TargetScore, Jokers, PokerHandChipsMult]
  ;
    StateOut = StateIn
  ).