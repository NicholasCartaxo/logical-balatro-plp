:- encoding(utf8).

:- use_module('./fullRoundLoop.pro').
:- use_module('./gameLoop.pro').
:- use_module('./jokers.pro').
:- use_module('./my_random.pro').
:- use_module('./cards.pro').
:- use_module('./pokerHands.pro').
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
        line(["[", IS, "]"])
    ).

render_jokers(Jokers) :-
    render_joker_slot(1, Jokers),
    render_joker_slot(2, Jokers),
    render_joker_slot(3, Jokers),
    render_joker_slot(4, Jokers),
    render_joker_slot(5, Jokers).

switch_jokers_position(State, NewState) :-
    State = [_, _, Jokers, _],
    length(Jokers, N),

    ( N < 2 ->
        NewState = State
    ;
        writeln(""),
        writeln("Deseja trocar a ordem dos coringas?"),
        writeln("Pressione qualquer letra para continuar sem trocar."),
        render_jokers(Jokers),

        write("Joker 1: "),
        get_char_and_clean(C1),
        
        ( charToInt(C1, I1),I1 >= 1, I1 =< N ->
            write("Joker 2: "),
            get_char_and_clean(C2),
             ( charToInt(C2, I2), I2 >= 1, I2 =< N ->

            changeJokerOrderFullRoundState(I1, I2, State, TempState),
            switch_jokers_position(TempState, NewState)
        ;
            writeln("Slot inválido! Tente novamente."),
            switch_jokers_position(State, NewState)
        )
    ;
        ( charToInt(C1, _) ->
            writeln("Slot inválido! Tente novamente."),
            switch_jokers_position(State, NewState)
        ;
            NewState = State
        )
    )
    ).

render_current_hand(State) :-
    playedPokerHandAndChipsMult(State, PokerHand, [Chips, Mult]),
    pokerHandStr(PokerHand, Name),
    to_s(Chips, ChipsS),
    to_s(Mult, MultS),

    write("Mão atual: "),
    writeln(Name),
    line(["FICHAS x MULTI: ", ChipsS, " x ", MultS]).


print_poker_hands_table(State) :-
    State = [_,_,_,_,_,_,_,PHCM],
    allHands(Hands),
    print_poker_hand_options(1, Hands, PHCM).

% =========================================================
% UI /- PrintGameState
% =========================================================

print_game_state(State) :-
    clear_terminal,
    State = [Hands, Discards, Hand, _, Score, Target, Jokers, _],
    writeln("===================================="),
    writeln("              BALATRO               "),
    writeln("===================================="),
    writeln("OBJETIVO"),
    writeln("===================================="),
    writeln("Jogue mãos de poker para pontuar fichas"),
    writeln("Descarte cartas para tentar formar mãos melhores"),
    writeln("Cada mão possui uma pontuação base"),
    writeln("Cada carta pontua fichas com base em seu valor"),
    writeln("Melhore suas mãos poker e ganhe coringas"),
    writeln("Para pontuar mais fichas"),
    writeln("===================================="),
    writeln(" MÃOS DE PÔQUER"),
    writeln("===================================="),
    print_poker_hands_table(State),
    writeln("===================================="),
    writeln(" CORINGAS"),
    writeln("===================================="),
    render_jokers(Jokers),
    writeln("===================================="),
    writeln(" MÃO ATUAL"),
    writeln("===================================="),
    render_hand(Hand),
    writeln("------------------------------------"),
    to_s(Score, ScoreS),
    to_s(Target, TargetS),
    line(["Fichas: ", ScoreS, " / ", TargetS]),
    render_current_hand(State),
    writeln(" "),
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
    State = [_,_,_,_,Score,Target,_,_],
    Score >= Target.

is_out_of_moves(State) :-
    State = [Hands,_,_,_,_,_,_,_],
    Hands =< 0.

game_loop(State, Result) :-
    print_game_state(State),
    ( is_win(State) ->
        writeln(""),
        writeln("Você atingiu a pontuação alvo!"),
        Result = true
    ; is_out_of_moves(State) ->
        writeln(""),
        writeln("Acabaram as jogadas!"),
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
    line([Name, " - ", ChipsS, " x ", MultS]),
    I2 is I + 1,
    print_poker_hand_options(I2, Rest, PHCM).

charToInt(Char, Int) :-
    atom_number(Char, Int).

% Menu da "loja"
pick_joker_or_increase_poker_hand(FullState, NewFullState) :-
    allJokers(AllJokers),
    getRandomItems(2, AllJokers, OfferedJokers),

    allHands(AllHands),
    getRandomItem(AllHands, OfferedHand),

    get_joker_or_poker_hand(FullState, NewFullState, OfferedHand, OfferedJokers).


get_joker_or_poker_hand(FullState, NewFullState, OfferedHand, OfferedJokers) :-
    FullState = [_, _, CurrentJokers, PHCM],

    call(PHCM, OfferedHand, CurrentCM),
    getUpgradedPokerHandChipsMult(OfferedHand, CurrentCM, [NewChips, NewMult]),

    pokerHandStr(OfferedHand, HandName),

    to_s(NewChips, ChipsS),
    to_s(NewMult, MultS),

    writeln(""),
    writeln("=== Bônus da rodada ==="),
    writeln(""),
    writeln("Para a próxima fase você pode escolher um dos bônus:"),
    OfferedJokers = [J1,J2],
    jokerStr(J1, J1Name),
    jokerStr(J2, J2Name),
    line(["1: Joker ", J1Name]),
    line(["2: Joker ", J2Name]),
    line(["3: Melhoria de mão ", HandName, " - ", ChipsS, " x ", MultS]),
    writeln(""),
    write("Escolha (1-3): "),
    get_char_and_clean(Choice),
    ( Choice == '1' ->
        apply_joker_choice(1, OfferedJokers, FullState, NewFullState)
    ; Choice == '2' ->
        apply_joker_choice(2, OfferedJokers, FullState, NewFullState)
    ; Choice == '3' ->
        upgradedPokerHandFullRoundState(OfferedHand, FullState, NewFullState)
    ;
        writeln("Opção inválida."),
        get_joker_or_poker_hand(FullState, NewFullState, OfferedHand, OfferedJokers)
    ).

full_round_loop(FullState) :-
    initialRoundGameState(FullState, RoundState),
    game_loop(RoundState, Result),
    ( Result = true ->
        writeln(""),
        pick_joker_or_increase_poker_hand(FullState, RewardState),
        switch_jokers_position(RewardState, ReorderedState),
        nextFullRoundState(ReorderedState, NextState),
        full_round_loop(NextState)
    ;
        
        FullState = [CurrentTarget, _, _, _],
        to_s(CurrentTarget, TargetS),
        line(["Fim de jogo! Você perdeu. Target era ", TargetS]),
        true
    ).

apply_joker_choice(Idx, OfferedJokers, FullState, NewFullState) :-
    FullState = [_, _, CurrentJokers, _],
    length(CurrentJokers, NumJokers),

    number_string(Idx, IdxStr),

    ( NumJokers < 5 ->
        notFullJokerFullRoundState(IdxStr, OfferedJokers, FullState, NewFullState)
    ;
        writeln("Seus slots de coringas estão cheios."),
        writeln("Escolha qual coringa substituir:"),

        print_current_jokers(1, CurrentJokers),
        write("Índice do coringa a substituir (1-5): "),
        get_char_and_clean(IdxOldChar),

        fullJokerFullRoundState(IdxStr, IdxOldChar, OfferedJokers, FullState, NewFullState)
    ).


main_screen :-
    clear_terminal,
    writeln("=== BALATRO - Card Game ==="),
    initialFullRoundState(State),
    full_round_loop(State).

:- main_screen, !.

%Tem que colcoar o UTF-8 pro windows rodar sem corrupção de caracteres também.