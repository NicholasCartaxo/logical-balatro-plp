suit(X) :- (X == spade, !); (X == heart, !); (X == diamond, !); (X == club, !);

suitStr(spade,"\x2660"). %unicode characters for suits
suitStr(heart,"\x2665").
suitStr(diamond,"\x2666").
suitStr(club,"\x2663").

rank(X) :- (integer(X), X >= 2, X =< 10, !); (X == j, !); (X == q, !); (X == k, !); (X == a, !).

rankStr(j,"J") :- !.
rankStr(q,"Q") :- !.
rankStr(k,"K") :- !.
rankStr(a,"A") :- !.
rankStr(X,R) :- rank(X), number_string(X,R).

rankValue(a,11) :- !.
rankValue(j,10) :- !.
rankValue(q,10) :- !.
rankValue(k,10) :- !.
rankValue(X,X) :- rank(X).

card([Rank,Suit]) :- rank(Rank), suit(Suit).

cardStr([Rank,Suit],R) :- card([Rank,Suit]), rankStr(Rank,RankS), suitStr(Suit,SuitS), string_concat(RankS,SuitS,R).