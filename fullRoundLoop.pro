:- encoding(utf8).

:- module(fullRoundLoop, [
  fullRoundState/1,
  initialFullRoundState/1,
  nextFullRoundState/2,
  upgradedPokerHandFullRoundState/3,
  notFullJokerFullRoundState/4,
  fullJokerFullRoundState/5,
  changeJokerOrderFullRoundState/4,
  upgradedChipsMult/4
]).

:- use_module(library(lists)).
:- use_module('pokerHands.pro').
:- use_module('jokers.pro').

:- meta_predicate upgradedChipsMult(?, 2, ?, ?).

fullRoundState([CurrentTargetScore, CurrentRound, CurrentJokers, CurrentPokerHandChipsMult]) :-
  integer(CurrentTargetScore), CurrentTargetScore >= 0,
  integer(CurrentRound), CurrentRound > 0
  %CurrentJokers = [],
  %CurrentPokerHandChipsMult = PokerHand -> ChipsMult,
.

charToInt(Char, Int) :- integer(Char), Int = Char, !.
charToInt(Char, Int) :- atom_number(Char, Int).

initialFullRoundState([300, 1, [], getInitialPokerHandChipsMult]).

nextFullRoundState([Target, Round, Jokers, PokerHandChipsMult], [NewTarget, NewRound, Jokers, PokerHandChipsMult]) :-
  NewRound is Round + 1,
  NewTarget is floor(Target * 1.5).

upgradedChipsMult(PokerHand, OldPokerHandChipsMult, PokerHand, ChipsMult) :-
    !,
    call(OldPokerHandChipsMult, PokerHand, OldChipsMult),
    getUpgradedPokerHandChipsMult(PokerHand, OldChipsMult, ChipsMult).

upgradedChipsMult(_, OldPokerHandChipsMult, PokerHand, ChipsMult) :-
  call(OldPokerHandChipsMult, PokerHand, ChipsMult).

upgradedPokerHandFullRoundState(PokerHandUpgrade,
    [Target, Round, Jokers, PokerHandChipsMultIn],
    [Target, Round, Jokers, upgradedChipsMult(PokerHandUpgrade, PokerHandChipsMultIn)]
).

notFullJokerFullRoundState(IdxChar, AvailableJokers,
  [Target, Round, Jokers, PokerHandChipsMult],
  [Target, Round, [NewJoker | Jokers], PokerHandChipsMult]
) :-
  charToInt(IdxChar, Idx),
  nth1(Idx, AvailableJokers, NewJoker).

fullJokerFullRoundState(IdxNewChar, IdxOldChar, AvailableJokers,
  [Target, Round, Jokers, PokerHandChipsMult],
  [Target, Round, NewJokers, PokerHandChipsMult]
) :-
  charToInt(IdxNewChar, IdxNew),
  charToInt(IdxOldChar, IdxOld),
  nth1(IdxNew, AvailableJokers, NewJoker),
  replaceNth1(IdxOld, Jokers, NewJoker, NewJokers).

changeJokerOrderFullRoundState(Idx1Char, Idx2Char,
  [Target, Round, Jokers, PokerHandChipsMult],
  [Target, Round, SwappedJokers, PokerHandChipsMult]
) :-
  charToInt(Idx1Char, Idx1),
  charToInt(Idx2Char, Idx2),
  swapElements(Idx1, Idx2, Jokers, SwappedJokers).

replaceNth1(1, [_ | Tail], Elem, [Elem | Tail]) :- !.
replaceNth1(N, [Head | Tail], Elem, [Head | Rest]) :-
  N > 1, N1 is N - 1,
  replaceNth1(N1, Tail, Elem, Rest).

swapElements(I, I, List, List) :- !.
swapElements(I, J, List, Swapped) :-
  I > J, !, swapElements(J, I, List, Swapped).
swapElements(I, J, List, Swapped) :-
  nth1(I, List, ElemI),
  nth1(J, List, ElemJ),
  replaceNth1(I, List, ElemJ, Temp),
  replaceNth1(J, Temp, ElemI, Swapped).