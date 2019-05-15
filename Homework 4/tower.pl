basic_row_and_col_restrictions(GridSize,RowOrCol) :-
    length(RowOrCol,GridSize), % each list in T is of length N
    fd_domain(RowOrCol,1,GridSize), % each list in T contains integers from 1 to N
    fd_all_different(RowOrCol). % each list in T contains distinct integers


% N is a nonnegative integer specifying the size of the square grid
% T, a list of N lists, represents each row of the square grid
% each row is a list of N distinct integers from 1 to N (same with columns)
% C is a structure with function symbol counts and arity 4
% C's arguments are lists of N integers, representing the
% tower counts for top, bottom, left, right respectively

tower(N,T,C) :-
    N >= 0, % N is a nonnegative integer
    length(T,N), % T must contain N lists

    maplist(basic_row_and_col_restrictions(N),T), % impose basic restrictions upon the rows
    transpose(T,T_transpose),
    maplist(basic_row_and_col_restrictions(N),T_transpose), % impose basic restrictions upon the columns

    maplist(fd_labeling,T),
    maplist(fd_labeling,T_transpose),

    C = counts(Top,Bottom,Left,Right), % check the counts on the edges
    check_forward(Left,T),
    check_backward(Right,T),
    check_forward(Top,T_transpose),
    check_backward(Bottom,T_transpose).



/* RULES TO CHECK TOWER COUNT */

check_forward([],[]).

check_forward([LeftHead|LeftTail],[CurrRow|OtherRows]) :-
    tower_count(CurrRow,0,LeftHead),
    check_forward(LeftTail,OtherRows).

check_backward(Right,T) :-
    maplist(reverse,T,RevT),
    check_forward(Right,RevT).

/* END RULES TO CHECK TOWER COUNT */


/* TOWER COUNT IMPLEMENTATION */
% tower_count(Row, Default Max Height = 0, Number of Visible Towers)

% base case for tower_count
tower_count([],_,0).

% rule for when the current tower is greater than all previous towers
tower_count([Front|Back],MaxHeight,NumVisible) :-
    Front #> MaxHeight,
    NumVisMinusOne #= NumVisible - 1,
    tower_count(Back,Front,NumVisMinusOne),!.

% rule for when the current tower is not greater than the current max height
tower_count([Front|Back],MaxHeight,NumVisible) :-
    Front #< MaxHeight,
    tower_count(Back,MaxHeight,NumVisible),!.

/* END TOWER COUNT IMPLEMENTATION */




/* STACK OVERFLOW MATRIX TRANSPOSITION IMPLEMENTATION */

% transpose implementation taken from https://stackoverflow.com/questions/4280986/how-to-transpose-a-matrix-in-prolog
transpose([], []).

transpose([F|Fs], Ts) :-
    transpose(F, [F|Fs], Ts).

transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
    lists_firsts_rests(Ms, Ts, Ms1),
    transpose(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
    lists_firsts_rests(Rest, Fs, Oss).

/* END STACK OVERFLOW MATRIX TRANSPOSITION IMPLEMENTATION */




/*
% my own implementation of transpose(X,Y) that is sadly not as efficient as the one on stack overflow

% true if the 2nd parameter contains the heads of all of the lists that the 1st parameter contains
get_all_list_heads([],[]).
get_all_list_heads([[FirstListHead|_]|OtherLists], [FirstHead|OtherHeads]) :-
    FirstListHead = FirstHead,
    get_all_list_heads(OtherLists,OtherHeads).

% true if the 2nd parameter contains the tails of all of the lists that the 1st parameter contains
get_all_list_tails([],[]).
get_all_list_tails([[_|FirstListTail]|OtherLists],[FirstTail|OtherTails]) :-
    FirstListTail = FirstTail,
    get_all_list_tails(OtherLists,OtherTails).

emptyList([]).

% this case is necessary because the last recursive call for transpose
% will look something like the following: transpose([[],[]],[])
transpose(X,[]) :-
    maplist(emptyList,X),!. % included a cut because it kept asking for more results

transpose(X,[Y_head|Y_tail]) :-
    get_all_list_heads(X,X_heads),
    X_heads = Y_head,
    get_all_list_tails(X,X_tails),
    transpose(X_tails,Y_tail).
*/






% starting plain_tower --------------------------------

unique_decreasing_list([],0).

unique_decreasing_list([H|T],N) :-
    H = N,
    N_decremented is N - 1,
    unique_decreasing_list(T,N_decremented).

% from TA Kimmo's slides

elements_between([],_,_).
elements_between([H|T],Min,Max) :-
    between(Min,Max,H),
    elements_between(T,Min,Max).

all_unique([]).
all_unique([H|T]) :- member(H,T),!,fail.
all_unique([_|T]) :- all_unique(T).


/*

% list L has unique elements between 1 and N
unique_list(N,L) :-
    length(L,N), % each list in T is of length N
    elements_between(L,1,N), % each list in T contains integers from 1 to N
    all_unique(L),!. % each list in T contains distinct integers

*/


% list L has unique elements between 1 and N
unique_list(N,L) :-
    unique_decreasing_list(DecreasingList,N),!,
    permutation(DecreasingList,L).


length_with_parameters_reversed(N,L) :- length(L,N).


/* one list between Min and Max: L
maplist(between(Min,Max),


*/

lbetween(L,Min,Max) :-
    maplist(between(Min,Max),L).

lolbetween(T,Min,Max) :-
    maplist(maplist(between(Min,Max)),T).




% NEW PLAIN TOWER
%                     LE       RowOrCol
% plain_check_forward([3,1,2],[[1,2,3],[3,1,2],[2,3,1]]).

idk(UniqueList,N,RowOrCol,LeftElement) :-
    permutation(UniqueList,RowOrCol),
    between(1,N,LeftElement),
    plain_tower_count(RowOrCol,0,LeftElement).




plain_tower(N,T,C) :-
    N >= 0, % N is a nonnegative integer
    length(T,N), % T must contain N lists

    %lets just start with all rows are of length n
    %maplist(length_with_parameters_reversed(N),T),

    %now all rows contain values between 1 and n
    %maplist(maplist(between(1,N)),T),

    %for now well try adding the unique constraint
    %maplist(all_unique,T),

    %transpose(T,T_transpose),

    %for the columns, we should only have to check uniqueness
    %maplist(all_unique,T_transpose),


    length(UniqueList,N),
    unique_decreasing_list(UniqueList,N), % basic unique list, ex: [4,3,2,1]


    C = counts(Top,Bottom,Left,Right), % check the counts on the edges
    length(Left,N),
    length(Right,N),
    length(Top,N),
    length(Bottom,N),

    maplist(idk(UniqueList,N),T,Left),

    maplist(reverse,T,RevT),

    maplist(idk(UniqueList,N),RevT,Right),

    transpose(T,T_transpose),

    maplist(idk(UniqueList,N),T_transpose,Top),

    maplist(reverse,T_transpose,RevT_transpose),

    maplist(idk(UniqueList,N),RevT_transpose,Bottom).

    /*
    plain_check_forward(Left,T,N),
    plain_check_backward(Right,T,N),
    plain_check_forward(Top,T_transpose,N),
    plain_check_backward(Bottom,T_transpose,N).
    */


/* OLD IMPLEMENTATION

plain_tower(N,T,C) :-
    N >= 0, % N is a nonnegative integer
    length(T,N), % T must contain N lists


    unique_decreasing_list(UniqueList,N),!, % basic unique list, ex: [4,3,2,1]

    maplist(permutation(UniqueList),T), % try every possible permutation of the unique list

    transpose(T,T_transpose),
    maplist(unique_list(N),T_transpose), % make sure the columns are valid as well



    C = counts(Top,Bottom,Left,Right), % check the counts on the edges
    length(Left,N),
    length(Right,N),
    length(Top,N),
    length(Bottom,N),


    %elements_between(Left,1,N),
    %elements_between(Right,1,N),
    %elements_between(Top,1,N),
    %elements_between(Bottom,1,N),




    plain_check_forward(Left,T,N),
    plain_check_backward(Right,T,N),
    plain_check_forward(Top,T_transpose,N),
    plain_check_backward(Bottom,T_transpose,N).

*/


% plain tower count

plain_tower_count([],_,0).

% rule for when the current tower is greater than all previous towers
plain_tower_count([Front|Back],MaxHeight,NumVisible) :-
    Front > MaxHeight,
    NumVisMinusOne is NumVisible - 1,
    plain_tower_count(Back,Front,NumVisMinusOne),!.

% rule for when the current tower is not greater than the current max height
plain_tower_count([Front|Back],MaxHeight,NumVisible) :-
    Front < MaxHeight,
    plain_tower_count(Back,MaxHeight,NumVisible),!.


% plain_check_forward([3,1,2],[[1,2,3],[3,1,2],[2,3,1]]).

plain_check_forward([],[],_).

plain_check_forward([LeftHead|LeftTail],[CurrRow|OtherRows],N) :-
    between(1,N,LeftHead),
    plain_tower_count(CurrRow,0,LeftHead),
    plain_check_forward(LeftTail,OtherRows,N).

plain_check_backward(Right,T,N) :-
    maplist(reverse,T,RevT),
    plain_check_forward(Right,RevT,N).
