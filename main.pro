:- use_module('./fullRoundLoop.pro').
:- use_module('./gameLoop.pro').
:- use_module(library(readutil)).

clear_terminal :- write('\n\033[2J\033[H').

get_char_and_clean(Char) :-
    get_char(Char),
    read_line_to_string(user_input, _).

% Transforma a maioria dos termos e variaveis que utilizamos em String, pra facilitar o trabalho.
to_s(X, S) :-
    ( string(X) -> S = X
    ; number(X) -> number_string(X, S)
    ; atom(X)   -> atom_string(X, S)
    ; term_string(X, S)
    ).

%% Esse Line facilita nos prints, principalmente quanod a gente utiliza variaveis de fora. O prolog nao presta pra esse tipo de coisa
%% e acabei achando uma biblioteca, ou sla o que seja isso, que basicmanete pega as informações que voce quer juntar em uma lista, e ele
%% retorna uma String concatenando todos esses elementos que voce colocou (lista, delimitador, resultado)
line(Parts) :-
    atomic_list_concat(Parts, "", A),
    writeln(A).

% =========================================================
% Gets para facilitar o acesso as variaveis do estadoo
% =========================================================

gs_get([H,_,_,_,_,_,_,_], hands, H).
gs_get([_,D,_,_,_,_,_,_], discards, D).
gs_get([_,_,Hand,_,_,_,_,_], hand, Hand).
gs_get([_,_,_,Deck,_,_,_,_], deck, Deck).
gs_get([_,_,_,_,Score,_,_,_], score, Score).
gs_get([_,_,_,_,_,Target,_,_], target, Target).
gs_get([_,_,_,_,_,_,Jokers,_], jokers, Jokers).
gs_get([_,_,_,_,_,_,_,PHCM], phcm, PHCM).

% =========================================================
% Cores dos nipes
% =========================================================

color_code(heart, "\e[31m").
color_code(spade, "\e[34m").
color_code(club, "\e[32m").
color_code(diamond, "\e[33m").

reset_code("\e[0m").

% =========================================================
% Renderização das cartas;mao;joker
% ========================================================

render_card(Index, card(Value,Suit), Selected, String) :-
    color_code(Suit, Color),
    reset_code(Reset),
    ( Selected == true -> Mark = " *" ; Mark = "" ),
    to_s(Index, IndexS),
    to_s(Value, ValueS),
    atomic_list_concat(["[", IndexS, "] ", Color, ValueS, Reset, Mark], "", Atom),
    atom_string(Atom, String).

render_hand(Hand) :- render_hand_(Hand, 1).
render_hand_([], _) :- !.
render_hand_([[Card, Selected]|T], I) :-
    ( Selected == true -> Mark = " *" ; Mark = "" ),
    to_s(I, IS),
    to_s(Card, CardS),
    line(["[", IS, "] ", CardS, Mark]),
    I2 is I + 1,
    render_hand_(T, I2).


% > TO DO - A gente precisa implkementar a renderização dos jokers, nao sei como faz esse babado


% =========================================================
% UI /- PrintGameState
% =========================================================

print_game_state(State) :-
    clear_terminal,
    writeln("===================================="),
    writeln("              BALATRO               "),
    writeln("===================================="),
    writeln(" CORINGAS"),
    writeln("===================================="),
    %renderizacao dos jokers
    writeln("===================================="),
    writeln(" MÃO ATUAL"),
    writeln("===================================="),
    gs_get(State, hand, Hand),
    render_hand(Hand),

    gs_get(State, score, Score),
    gs_get(State, target, Target),
    to_s(Score, ScoreS),
    to_s(Target, TargetS),
    line(["Fichas: ", ScoreS, " / ", TargetS]),

    gs_get(State, hands, Hands),
    gs_get(State, discards, Discards),
    to_s(Hands, HandsS),
    to_s(Discards, DiscardsS),
    line(["Jogadas: ", HandsS, "    Descartes: ", DiscardsS]).

%% > TO DO - Verificar como as ações estão sendo feitas. Tentei fazer já uns testes e percebi que ele esta com uns erros na selecao das cartas

is_win(State) :-
    gs_get(State, score, Score),
    gs_get(State, target, Target),
    Score >= Target.

is_out_of_moves(State) :-
    gs_get(State, hands, Hands),
    Hands =< 0.

game_loop(State, Result) :-
    print_game_state(State),
    ( is_win(State) ->
        Result = true
    ; is_out_of_moves(State) ->
        Result = false
    ;
        write("Escolha uma ação: "),
        get_char_and_clean(Action),
        updateRoundGameState(Action, State, NewState),
        game_loop(NewState, Result)
    ).

full_round_loop(FullState) :-
    initialRoundGameState(FullState, RoundState),
    game_loop(RoundState, Result),
    ( Result = true ->
        nextFullRoundState(FullState, NextState),
        full_round_loop(NextState)
    ;
        % FullState tem esses atributos;valore [TargetScore, Round, Jokers, PokerHandChipsMult]
        FullState = [CurrentTarget, _, _, _],
        to_s(CurrentTarget, TargetS),
        line(["Fim de jogo! Você perdeu. Target era ", TargetS]),
        true
    ).

main_screen :-
    clear_terminal,
    initialFullRoundState(State),
    full_round_loop(State).

main :- main_screen, !.

%Tem que colcoar o UTF-8 pro windows rodar sem corrupção de caracteres também.