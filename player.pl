/* File : Player.pl */
/* Store player information and the inventory */

/* Set dynamc predicates */
:- dynamic(pokemon_inventory/2).
:- dynamic(pokemon_health/1).

/* Utility function for inserting pokemon at end of list */
insert_back(X, [], [X]) :- !.
insert_back(X, [H|Tail1], [H|Tail2]):-insert_back(X,Tail1, Tail2).

/* Utility function for deleting nth pokemon of the list */
delete_nth(1, [_|T], T) :- !.
delete_nth(N, [H|Tail1], [H|Tail2]) :- N1 is N-1, delete_nth(N1, Tail1, Tail2).

/* Utility function to get nth item of list */
nth_item([H|_],1, H) :- !.
nth_item([_|T],N, X) :- N1 is N-1, nth_item(T, N1, X).

/* Utility function to set nth item of list */
set_nth_item([_|T], 1, X, [X|T]).
set_nth_item([H|T1], N, X, [H|T2]):-N1 is N-1, set_nth_item(T1, N1, X, T2).


/* ------------------------------------------------------------------- */

/* Procedure to add pokemon to inventory*/
insert_pokemon(PokeId) :- 
    pokemon_inventory(PokeList,PokeCount),
    pokemon_health(PokeHealthList),

    NewPokeCount is PokeCount+1,
    health(PokeId, PokeHealth),
    insert_back(PokeId, PokeList, NewPokeList),
    insert_back(PokeHealth, PokeHealthList, NewPokeHealthList),

    assertz(pokemon_inventory(NewPokeList, NewPokeCount)),
    assertz(pokemon_health(NewPokeHealthList)),
    retract(pokemon_inventory(PokeList, PokeCount)),
    retract(pokemon_health(PokeHealthList)), !.

/* Procedure to remove pokemon from inventory */
delete_pokemon(SlotId) :-
    pokemon_inventory(PokeList,PokeCount),
    pokemon_health(PokeHealthList),

    NewPokeCount is PokeCount-1,
    delete_nth(SlotId, PokeList, NewPokeList),
    delete_nth(SlotId, PokeHealthList, NewPokeHealthList),

    assertz(pokemon_inventory(NewPokeList, NewPokeCount)),
    assertz(pokemon_health(NewPokeHealthList)),
    retract(pokemon_inventory(PokeList, PokeCount)),
    retract(pokemon_health(PokeHealthList)), !.


/* Print nth slot status */
print_nth_slot(N):-
    pokemon_inventory(PokeList, _),
    pokemon_health(PokeHealthList),
    nth_item(PokeList, N, NthId),
    nth_item(PokeHealthList, N, NthHealth),

    poke_name(NthId, PokeName),
    write(PokeName), nl,

    write('Health : '),
    write(NthHealth), nl,
    
    attack(NthId, PokeAttack),
    write('Attack : '),
    write(PokeAttack), nl,
    
    type(NthId, PokeType),
    write('Type : '),
    write(PokeType), nl, nl.

/* Print all slot */
print_all_slot:-
    pokemon_inventory(_, Count),
    Count > 0,
    !,
    write('Your Pokemons:\n'),
    print_nth_slot(1),
    print_nth_slot(2),
    print_nth_slot(3),
    print_nth_slot(4),
    print_nth_slot(5),
    print_nth_slot(6).