:- module(hands, [
    pokerHand/1,
    pokerHandStr/2,
    getPokerHandAndCards/3,
    chipsMult/1,
    getScore/2,
    getInitialPokerHandChipsMult/2,
    getUpgradedPokerHandChipsMult/3,
    getChipsMultOfHand/3
]).

:- meta_predicate getChipsMultOfHand(2, ?, ?).
:- use_module('cards.pro').

pokerHand(X) :-
  (X == straightFlush,!); (X == fourOfAKind,!); (X == fullHouse,!);
  (X == flush,!); (X == straight,!); (X == threeOfAKind,!);
  (X == twoPair,!); (X == pair,!); (X == highCard,!).

pokerHandStr(straightFlush,"Straight Flush").
pokerHandStr(fourOfAKind,"Quadra").
pokerHandStr(fullHouse,"Full House").
pokerHandStr(flush,"Flush").
pokerHandStr(straight,"Sequência").
pokerHandStr(threeOfAKind,"Trinca").
pokerHandStr(twoPair,"Dois Pares").
pokerHandStr(pair,"Par").
pokerHandStr(highCard,"Carta Alta").

getStraight(Cards,R) :-
  length(Cards,5),
  getRanksOrds(Cards,Ords),
  sort(Ords,SortedOrds),
  length(SortedOrds,5),
  straightLoop(SortedOrds),
  R = Cards,!.

straightLoop([_]).
straightLoop([5,14]).
straightLoop([X,Y | Tail]) :-
  Y =:= X + 1,
  straightLoop([Y | Tail]).

getFlush(Cards,R) :-
  length(Cards,5),
  flushLoop(Cards),
  R = Cards,!.

flushLoop([_]).
flushLoop([[_,Suit],[_,Suit] | Tail]) :-
  flushLoop([[_,Suit] | Tail]).

getNRepeats(N,Cards,R) :-
  member([Rank,_],Cards),
  findall([Rank,Suit], member([Rank,Suit],Cards), FilteredCards),
  length(FilteredCards,N),
  R = FilteredCards,!.

getFourOfAKind(Cards,R) :- getNRepeats(4,Cards,R).

getFullHouse(Cards,R) :-
  getNRepeats(3,Cards,_),
  getNRepeats(2,Cards,_),
  R = Cards.

getThreeOfAKind(Cards,R) :- getNRepeats(3,Cards,R).

getTwoPair(Cards,R) :-
  member([Rank1,_],Cards),
  member([Rank2,_],Cards),
  Rank1 @> Rank2,
  
  findall([Rank1,Suit1],member([Rank1,Suit1],Cards),Pair1),
  findall([Rank2,Suit2],member([Rank2,Suit2],Cards),Pair2),
  
  length(Pair1,2),
  length(Pair2,2),
  append(Pair1,Pair2,R),!.

getPair(Cards,R) :- getNRepeats(2,Cards,R).

getHighCard(Cards,R) :-
  member([Rank,Suit],Cards),
  rankOrd(Rank,Ord),
  \+ (
    member([Rank2,_],Cards),
    rankOrd(Rank2,Ord2),
    Ord2 > Ord
  ),
  R = [[Rank,Suit]],!.

getPokerHandAndCards(Cards,PokerHand,R) :-
  (getStraight(Cards,_),getFlush(Cards,R),PokerHand = straightFlush,!);
  (getFourOfAKind(Cards,R),PokerHand = fourOfAKind,!);
  (getFullHouse(Cards,R),PokerHand = fullHouse,!);
  (getFlush(Cards,R),PokerHand = flush,!);
  (getStraight(Cards,R),PokerHand = straight,!);
  (getThreeOfAKind(Cards,R),PokerHand = threeOfAKind,!);
  (getTwoPair(Cards,R),PokerHand = twoPair,!);
  (getPair(Cards,R),PokerHand = pair,!);
  (getHighCard(Cards,R),PokerHand = highCard,!).

chipsMult([Chips,Mult]) :- integer(Chips), integer(Mult), Chips >= 0, Mult >= 0.

getScore([Chips,Mult],R) :- R is Chips*Mult.

getInitialPokerHandChipsMult(straightFlush, [100, 8]).
getInitialPokerHandChipsMult(fourOfAKind, [60, 7]).
getInitialPokerHandChipsMult(fullHouse, [40, 4]).
getInitialPokerHandChipsMult(flush, [35, 4]).
getInitialPokerHandChipsMult(straight, [30, 4]).
getInitialPokerHandChipsMult(threeOfAKind, [30, 3]).
getInitialPokerHandChipsMult(twoPair, [20, 2]).
getInitialPokerHandChipsMult(pair, [10, 2]).
getInitialPokerHandChipsMult(highCard, [5, 1]).

getUpgradedPokerHandChipsMult(straightFlush, [Chips, Mult], R) :- C is Chips+40, M is Mult+4, R = [C, M].
getUpgradedPokerHandChipsMult(fourOfAKind, [Chips, Mult], R) :- C is Chips+30, M is Mult+3, R = [C, M].
getUpgradedPokerHandChipsMult(fullHouse, [Chips, Mult], R) :- C is Chips+25, M is Mult+2, R = [C, M].
getUpgradedPokerHandChipsMult(flush, [Chips, Mult], R) :- C is Chips+15, M is Mult+2, R = [C, M].
getUpgradedPokerHandChipsMult(straight, [Chips, Mult], R) :- C is Chips+30, M is Mult+3, R = [C, M].
getUpgradedPokerHandChipsMult(threeOfAKind, [Chips, Mult], R) :- C is Chips+20, M is Mult+2, R = [C, M].
getUpgradedPokerHandChipsMult(twoPair, [Chips, Mult], R) :- C is Chips+20, M is Mult+1, R = [C, M].
getUpgradedPokerHandChipsMult(pair, [Chips, Mult], R) :- C is Chips+15, M is Mult+1, R = [C, M].
getUpgradedPokerHandChipsMult(highCard, [Chips, Mult], R) :- C is Chips+10, M is Mult+1, R = [C, M].

sumCardValues([[Rank, _]|Tail], R) :-
  rankValue(Rank, V),
  sumCardValues(Tail, S),
  R is V+S.
sumCardValues([], 0).

getChipsMultOfHand(PokerHandsChipsMult, Hand, R) :-
  getPokerHandAndCards(Hand, PokerHand, ScoredHand),
  call(PokerHandsChipsMult, PokerHand, [Chips, Mult]),
  sumCardValues(ScoredHand, SumCards),
  FinalChips is Chips + SumCards,
  R = [FinalChips, Mult].