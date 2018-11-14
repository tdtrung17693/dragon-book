-module (failure_fun).
-export ([failure_func/1]).

failure_func([ First | Rest ]) ->
    io:format("~p~n", [[First]]),

    failure_func(Rest, [ First ], [ First ], 0, [0]).

failure_func([], _Tracks,  FormerChars, _T, FFs) -> FFs;
failure_func([ NextChar | Rest ], [ NextChar | Track ], FormerChars, T, FFs) ->
    failure_func(Rest, Track ++ [ NextChar ], FormerChars ++ [ NextChar ], T + 1, [ T+1 | FFs ]);
failure_func([ NextChar | Rest ], [ Other | Track ], [ NextChar | FormerChars ], T, FFs) ->
    failure_func(Rest, FormerChars ++ [ NextChar] , [ NextChar | FormerChars ] ++ [ NextChar ], 1, [ 1 | FFs ]);
failure_func([ NextChar | Rest ], [ Other | Track ], FormerChars, T, FFs) ->
    io:format("~p~n", [FormerChars]),
    failure_func(Rest, FormerChars ++ [ NextChar] , FormerChars ++ [ NextChar ], 0, [ 0 | FFs ]).
