:- module(jokers, [
  joker/1,
  allJokers/1,
  jokerStr/2,
  jokerDescription/2,
  applyJoker/5
]).

allJokers([
  multSpades, multDiamonds, pirate, seven, twoDucks, flush, 
  three, house, sixtySeven, fiftyOne, sport, theBite
]).

joker(multSpades).
joker(multDiamonds).
joker(pirate).
joker(seven).
joker(twoDucks).
joker(flush).
joker(three).
joker(house).
joker(sixtySeven).
joker(fiftyOne).
joker(sport).
joker(theBite).

jokerStr(multSpades,"Duelo de espadas").
jokerStr(multDiamonds,"Devolvam nossos ouros").
jokerStr(pirate,"O pirata").
jokerStr(seven,"Sorte a nossa").
jokerStr(twoDucks,"Dois patinhos na lagoa").
jokerStr(flush,"Vaso sanitário").
jokerStr(three,"Três é demais").
jokerStr(house,"Quatro paredes").
jokerStr(sixtySeven,"Seis sete").
jokerStr(fiftyOne,"Uma boa ideia").
jokerStr(sport,"É do Sport").
jokerStr(theBite,"A mordida").

jokerDescription(multSpades,"Cada carta de espadas pontuada dá +5 MULTI").
jokerDescription(multDiamonds,"Cada carta de ouros pontuada dá +5 MULTI").
jokerDescription(pirate,"Se a mão pontuar exatamente dois 9 dá +27 MULTI").
jokerDescription(seven,"Para cada 7 pontuado dá +7 MULTI"). 
jokerDescription(twoDucks,"Se a mão pontuar pelo menos dois 2 dá x2 MULTI").
jokerDescription(flush,"Se a mão for um flush dá x2 MULTI").
jokerDescription(three,"Se a mão for uma trinca dá x3 MULTI").
jokerDescription(house,"Se a mão for um full house dá x4 MULTI").
jokerDescription(sixtySeven,"Se a mão pontuar um 6 e um 7 dá +67 FICHAS").
jokerDescription(fiftyOne,"Se a mão pontuar um 5 e um Ás dá +51 FICHAS").
jokerDescription(sport,"Se a mão pontuar um 8 e um 7 dá +87 FICHAS").
jokerDescription(theBite,"Se a mão pontuar um 8 e um 3 dá +83 FICHAS, mas isso é só uma teoria").

numOfSuit(_, [], 0).
numOfSuit(Suit, [[_, Suit] | Tail], R) :-
  numOfSuit(Suit, Tail, S),
  R is S+1,!.
numOfSuit(Suit, [_ | Tail], R) :-
  numOfSuit(Suit, Tail, R).

numOfRank(_, [], 0).
numOfRank(Rank, [[Rank, _] | Tail], R) :-
  numOfRank(Rank, Tail, S),
  R is S+1,!.
numOfRank(Rank, [_ | Tail], R) :-
  numOfRank(Rank, Tail, R).

hasRank(Rank, Hand) :- member([Rank, _], Hand).


applyJoker(multSpades, [C, M], _, ScoredHand, [C, NewM]) :-
  numOfSuit(spade, ScoredHand, Count),
  NewM is M + (5 * Count).

applyJoker(multDiamonds, [C, M], _, ScoredHand, [C, NewM]) :-
  numOfSuit(diamond, ScoredHand, Count),
  NewM is M + (5 * Count).

applyJoker(pirate, [C, M], _, ScoredHand, [C, NewM]) :-
  numOfRank(9, ScoredHand, Count),
  (Count =:= 2 -> NewM is M + 27 ; NewM is M).

applyJoker(seven, [C, M], _, ScoredHand, [C, NewM]) :-
  numOfRank(7, ScoredHand, Count),
  NewM is M + (7 * Count).

applyJoker(twoDucks, [C, M], _, ScoredHand, [C, NewM]) :-
  numOfRank(2, ScoredHand, Count),
  (Count >= 2 -> NewM is M * 2 ; NewM is M).

applyJoker(flush, [C, M], PokerHand, _, [C, NewM]) :-
  (PokerHand == flush -> NewM is M * 2 ; NewM is M).

applyJoker(three, [C, M], PokerHand, _, [C, NewM]) :-
  (PokerHand == threeOfAKind -> NewM is M * 3 ; NewM is M).

applyJoker(house, [C, M], PokerHand, _, [C, NewM]) :-
  (PokerHand == fullHouse -> NewM is M * 4 ; NewM is M).

applyJoker(sixtySeven, [C, M], _, ScoredHand, [NewC, M]) :-
  (hasRank(6, ScoredHand), hasRank(7, ScoredHand) -> NewC is C + 67 ; NewC is C).

applyJoker(fiftyOne, [C, M], _, ScoredHand, [NewC, M]) :-
  (hasRank(5, ScoredHand), hasRank(a, ScoredHand) -> NewC is C + 51 ; NewC is C).

applyJoker(sport, [C, M], _, ScoredHand, [NewC, M]) :-
  (hasRank(8, ScoredHand), hasRank(7, ScoredHand) -> NewC is C + 87 ; NewC is C).

applyJoker(theBite, [C, M], _, ScoredHand, [NewC, M]) :-
  (hasRank(8, ScoredHand), hasRank(3, ScoredHand) -> NewC is C + 83 ; NewC is C).