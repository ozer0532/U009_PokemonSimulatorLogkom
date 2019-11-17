% Untuk memulai battle, run init_battle
% Command yang dibuka untuk player ada pada prosedur yang bersangkutan

:- include('pokemon.pl').
:- include('player_status.pl').
:- include('pokemon_status.pl').

% selected_pokemon(IdSlot)
:- dynamic(selected_pokemon/1).

:- dynamic(enemy_pokemon/1).

:- dynamic(enemy_health/1).

% Ada bila player sedang battle
:- dynamic(in_battle/0).

% Inisialisasi selected_pokemon
selected_pokemon(0).

% attack_multiplier(AttackType, DefendType, Multiplier)
attack_multiplier(fire, fire, 1).
attack_multiplier(fire, water, 0.5).
attack_multiplier(fire, grass, 1.5).
attack_multiplier(water, fire, 1.5).
attack_multiplier(water, water, 1).
attack_multiplier(water, grass, 0.5).
attack_multiplier(grass, fire, 0.5).
attack_multiplier(grass, water, 1.5).
attack_multiplier(grass, grass, 1).

% Melakukan inisialisasi battle
init_battle :-
    assertz(in_battle).

% Menghitung besar damage yang dikena musuh
calc_damage(AttackerId, DefenderId, Result) :-
    type(AttackerId, AtkType),
    type(DefenderId, DefType),
    attack(AttackerId, AtkVal),
    attack_multiplier(AtkType, DefType, Mult),
    Res is (AtkVal * Mult),
    Result is round(Res).

% Menghitung besar special damage yang dikena musuh
calc_special_damage(AttackerId, DefenderId, Result) :-
    type(AttackerId, AtkType),
    type(DefenderId, DefType),
    special(AttackerId, AtkVal),
    attack_multiplier(AtkType, DefType, Mult),
    Res is (AtkVal * Mult),
    Result is round(Res).

% Menyelesaikan battle saat musuh sudah kalah
check_death :-
    enemy_health(X),
    X =< 0,
    retract(in_battle).

% Ignore bila musuh belum mati
check_death :-
    enemy_turn.

check_player_lose :-
    pokemon_count(0),
    write('YOU LOSE :(').

check_player_lose :- !.

check_player_death :-
    selected_pokemon(SelPoke),
    pokemon_health(SelPoke, Health),
    Health =< 0, !,
    del_pokemon(SelPoke),
    check_player_lose.

check_player_death :-
    enemy_turn.

% Pokemon musuh menyerang pemain
enemy_turn :- !,
    selected_pokemon(SelPoke),
    pokemon_slot(SelPoke, PokeId),
    pokemon_health(SelPoke, Health),
    retract(pokemon_health(SelPoke, Health)),
    enemy_pokemon(EnemyId),
    calc_damage(EnemyId, PokeId, Atk),
    New is Health - Atk,
    assertz(pokemon_health(SelPoke, New)),
    check_player_death.

% Success Result: Mengubah selected_pokemon menjadi X
pick(X) :-
    in_battle,
    X > 0,
    X =< 6, !, 
    retract(selected_pokemon(AnyOne)),
    assertz(selected_pokemon(X)).

% Fail Condition: Tidak dalam battle
pick(X) :-
    (\+ in_battle), !,
    write('Wrong command jancug...'), nl,
    write('You are currently not in a battle').

% Fail Condition: Angka slot tidak benar
pick(X) :-
    !,
    write('Wrong parameter jancug...'), nl,
    write('Usage: pick(1..6)').

% Success Result: Darah musuh berkurang
attack :-
    in_battle, !,
    enemy_health(X),
    retract(enemy_health(X)),
    selected_pokemon(SelPoke),
    pokemon_slot(SelPoke, PokeId),
    enemy_pokemon(EnemyId),
    calc_damage(PokeId, EnemyId, Atk),
    NewX is X - Atk,
    assertz(enemy_health(NewX)),
    check_death.

% Fail Condition: Tidak dalam battle
attack :-
    !,
    write('Wrong command jancug...'), nl,
    write('You are currently not in a battle').

attack :-
    selected_pokemon(0), !,
    write('Wrong command jancug...'), nl,
    write('You have not picked a pokémon yet').

% Success Result: Darah musuh berkurang
special_attack :-
    in_battle, !,
    enemy_health(X),
    retract(enemy_health(X)),
    selected_pokemon(SelPoke),
    pokemon_slot(SelPoke, PokeId),
    enemy_pokemon(EnemyId),
    calc_special_damage(PokeId, EnemyId, Atk),
    NewX is X - Atk,
    assertz(enemy_health(NewX)).

% Fail Condition: Tidak dalam battle
special_attack :-
    !,
    write('Wrong command jancug...'), nl,
    write('You are currently not in a battle').

special_attack :-
    selected_pokemon(0), !,
    write('Wrong command jancug...'), nl,
    write('You have not picked a pokémon yet').