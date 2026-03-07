:- use_module('./fullRoundLoop.pro').
:- use_module('./gameLoop.pro').
:- use_module('./jokers.pro').
:- use_module('./my_random.pro').
:- use_module('./Cards.pro').
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



color_code(heart, "\e[31m").
color_code(spade, "\e[34m").
color_code(club, "\e[32m").
color_code(diamond, "\e[33m").

reset_code("\e[0m").


render_card(Index, [Rank, Suit], Selected) :-
    color_code(Suit, Color),
    reset_code(Reset),
    ( Selected == true -> Mark = " *" ; Mark = "" ),
    to_s(Index, IndexS),
    rankStr(Rank, RankS),
    suitStr(Suit, SuitS),
    line(["[", IndexS, "] ", Color, RankS, SuitS, Reset, Mark]).

render_hand(Hand) :- render_hand_(Hand, 1).
render_hand_([], _) :- !.
render_hand_([[Card, Selected]|T], I) :-
    render_card(I, Card, Selected),
    I2 is I + 1,
    render_hand_(T, I2).


render_joker_slot(I, Jokers) :-
    ( nth1(I, Jokers, Joker) ->
        jokerStr(Joker, Name),
        jokerDescription(Joker, Desc),
        to_s(I, IS),
        line(["[", IS, "] ", Name, " — ", Desc])
    ;
        to_s(I, IS),
        line(["[", IS, "] [ ]"])
    ).

render_jokers(Jokers) :-
    render_joker_slot(1, Jokers),
    render_joker_slot(2, Jokers),
    render_joker_slot(3, Jokers),
    render_joker_slot(4, Jokers),
    render_joker_slot(5, Jokers).

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
    gs_get(State, jokers, Jokers),
    render_jokers(Jokers),
    writeln("===================================="),
    writeln(" MÃO ATUAL"),
    writeln("===================================="),
    gs_get(State, hand, Hand),
    render_hand(Hand),
    writeln("------------------------------------"),
    gs_get(State, score, Score),
    gs_get(State, target, Target),
    to_s(Score, ScoreS),
    to_s(Target, TargetS),
    line(["Fichas: ", ScoreS, " / ", TargetS]),
    writeln(" "),
    gs_get(State, hands, Hands),
    gs_get(State, discards, Discards),
    to_s(Hands, HandsS),
    to_s(Discards, DiscardsS),
    line(["Jogadas: ", HandsS, "    Descartes: ", DiscardsS]),
    writeln("------------------------------------"),
    writeln("Comandos:"),
    writeln(" 1-8 = selecionar carta"),
    writeln(" q   = jogar mão"),
    writeln(" w   = descartar cartas"),
    writeln(" e   = ordenar por naipe"),
    writeln(" r   = ordenar por valor"),
    writeln(" x   = sair"),
    writeln("------------------------------------").

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
        writeln(""),
        writeln("🎉 Você atingiu a pontuação alvo!"),
        Result = true
    ; is_out_of_moves(State) ->
        writeln(""),
        writeln("❌ Acabaram as jogadas!"),
        writeln("Fim de jogo!"),
        Result = false
    ;
        write("Escolha uma ação: "),
        get_char_and_clean(Action),
        ( Action == x ->
            writeln("Saindo..."), Result = false
        ;
            updateRoundGameState(Action, State, NewState),
            game_loop(NewState, Result)
        )
    ).

print_available_jokers(_, []).
print_available_jokers(I, [J|Rest]) :-
jokerStr(J, Name),
jokerDescription(J, Desc),
to_s(I, IS),
line(["  ", IS, " - ", Name, " — ", Desc]),
I2 is I + 1,
print_available_jokers(I2, Rest).

% Exibe os jokers atualmente 
print_current_jokers(_, []).
print_current_jokers(I, [J|Rest]) :-
    jokerStr(J, Name),
    to_s(I, IS),
    line(["  ", IS, " - ", Name]),
    I2 is I + 1,
    print_current_jokers(I2, Rest).

% Exibe as maos de poker com os valores atuais de chips/mult
print_poker_hand_options(_, [], _).
print_poker_hand_options(I, [H|Rest], PHCM) :-
    pokerHandStr(H, Name),
    call(PHCM, H, [Chips, Mult]),
    to_s(I, IS),
    to_s(Chips, ChipsS),
    to_s(Mult, MultS),
    line(["  ", IS, " - ", Name, "  (", ChipsS, " fichas x ", MultS, " mult)"]),
    I2 is I + 1,
    print_poker_hand_options(I2, Rest, PHCM).


joker_shop(FullState, NewFullState) :-
    FullState = [_, _, CurrentJokers, _],
    allJokers(AllJokers),
    getRandomItems(3, AllJokers, OfferedJokers),

    writeln(""),
    writeln("--- Coringas disponíveis ---"),
    print_available_jokers(1, OfferedJokers),
    writeln(""),

    length(CurrentJokers, NumJokers),
    ( NumJokers < 5 ->
        write("Escolha um coringa (1-3): "),
        get_char_and_clean(IdxChar),
        notFullJokerFullRoundState(IdxChar, OfferedJokers, FullState, NewFullState)
    ;
        writeln("Seus slots de coringas estão cheios!"),
        writeln(""),
        writeln("Escolha qual coringa NOVO você quer:"),
        write("Índice do novo coringa (1-3): "),
        get_char_and_clean(IdxNewChar),
        writeln(""),
        writeln("Escolha qual coringa ATUAL substituir:"),
        print_current_jokers(1, CurrentJokers),
        write("Índice do coringa a substituir (1-5): "),
        get_char_and_clean(IdxOldChar),
        fullJokerFullRoundState(IdxNewChar, IdxOldChar, OfferedJokers, FullState, NewFullState)
    ).

% upgrade de mao
hand_upgrade_shop(FullState, NewFullState) :-
    FullState = [_, _, _, PHCM],
    AllHands = [straightFlush, fourOfAKind, fullHouse, flush,
                straight, threeOfAKind, twoPair, pair, highCard],

    writeln(""),
    writeln("--- Mãos de poker disponíveis ---"),
    print_poker_hand_options(1, AllHands, PHCM),
    writeln(""),

    write("Escolha uma mão para melhorar (1-9): "),
    get_char_and_clean(IdxChar),
    charToInt(IdxChar, Idx),
    nth1(Idx, AllHands, ChosenHand),
    upgradedPokerHandFullRoundState(ChosenHand, FullState, NewFullState).

% Menu da "loja"
pick_joker_or_increase_poker_hand(FullState, NewFullState) :-
    writeln(""),
    writeln("=== Bônus da rodada ==="),
    writeln(""),
    writeln("Para a próxima fase você pode escolher um dos bônus:"),
    writeln("  1 - Receber um Coringa aleatório"),
    writeln("  2 - Melhorar uma mão de poker"),
    writeln(""),
    write("Escolha (1-2): "),
    get_char_and_clean(Choice),
    ( Choice == '1' ->
        joker_shop(FullState, NewFullState)
    ; Choice == '2' ->
        hand_upgrade_shop(FullState, NewFullState)
    ;
        writeln("Opção inválida, tente novamente."),
        pick_joker_or_increase_poker_hand(FullState, NewFullState)
    ).

full_round_loop(FullState) :-
    initialRoundGameState(FullState, RoundState),
    game_loop(RoundState, Result),
    ( Result = true ->
        nextFullRoundState(FullState, NextState),
        full_round_loop(NextState)
    ;
        
        FullState = [CurrentTarget, _, _, _],
        to_s(CurrentTarget, TargetS),
        line(["Fim de jogo! Você perdeu. Target era ", TargetS]),
        true
    ).

main_screen :-
    clear_terminal,
    writeln("=== BALATRO - Card Game ==="),
    initialFullRoundState(State),
    full_round_loop(State).

main :- main_screen, !.

%Tem que colcoar o UTF-8 pro windows rodar sem corrupção de caracteres também.