-module (lex).
-export ([lex/0, test/0]).

reserved_keywords() ->
    [ {true, "true"}, {false, "false"} ].

initialize_dict(Dict, []) -> Dict;
initialize_dict(Dict, [{Tag, Keyword} | ReservedKeywords]) ->
    initialize_dict(dict:append(Keyword, {Tag, Keyword}, Dict), ReservedKeywords).

get_char() ->
    case io:get_chars('', 1) of
        eof -> eof;
        Char ->
            [ C | _ ] = Char,
            C
    end.

lex() ->
    Dict = initialize_dict(dict:new(), reserved_keywords()),

    Line = 1,
    lex(Dict, get_char(), "").

lex(Dict, $/, Word) ->
    case get_char() of
        % Check for single-line comment
        $/ -> io:get_line(''), lex(Dict, $\s, Word);
        % Check for comment block
        $* ->
            lex(Dict, get_char(), "/*"),
            lex(Dict, $\s, Word);
        eof -> lex(Dict, $\s, Word);
        Peak -> lex(Dict, Peak, Word)
    end;
lex(Dict, $*, [ $/, $* | Chars]) ->
    case get_char() of
        $/ -> lex(Dict, get_char(), "");
        eof -> {};
        Peak -> lex(Dict, Peak, [ $/, $* | Chars])
    end;
lex(Dict, eof, "") -> [{}, Dict];
lex(Dict, Peak, "") when Peak =:= $\s orelse Peak =:= $\t orelse Peak =:= $\n -> lex(Dict, get_char(), "");
lex(Dict, Peak, "") -> lex(Dict, get_char(), [Peak]);
lex(Dict, Peak, [ FirstChar | Chars ]) when (Peak =:= $\s orelse Peak =:= $\t orelse Peak =:= $\n) andalso FirstChar >= $0 andalso FirstChar =< $9 ->
    case string:chr([ FirstChar | Chars ], $.) of
        Idx when Idx =:= 0 ->
            {Number,_} = string:to_integer([ FirstChar | Chars ]);
        Idx when Idx > 0 ->
            {Number,_} = string:to_float([ FirstChar | Chars ])
    end,
    Token = token_new(num, Number),
    [Token, Dict];
lex(Dict, Peak, [ $. | Chars ]) when (Peak =:= $\s orelse Peak =:= $\t orelse Peak =:= $\n) ->
    {Number,_} = string:to_float([ $0, $. | Chars ]),
    Token = token_new(num, Number),
    [Token, Dict];
lex(Dict, Peak, [ FirstChar | Chars ]) when (Peak =:= $\s orelse Peak =:= $\t orelse Peak =:= $\n) andalso (FirstChar < $0 orelse FirstChar > $9) ->
    case dict:is_key([ FirstChar | Chars ], Dict) of
        true ->
            [Token | _] = dict:fetch([ FirstChar | Chars ], Dict),
            [Token, Dict];
        false ->
            Token = token_new(id, [ FirstChar | Chars ]),
            [Token, Dict]
    end;
lex(Dict, Peak, [ FirstChar | Chars ]) when Peak =:= $. andalso (FirstChar >= $0 andalso FirstChar =< $9) ->
    case string:chr([ FirstChar | Chars ], $.) of
        Idx when Idx =:= 0 ->
            lex(Dict, get_char(), string:concat([ FirstChar | Chars ], [Peak]));
        Idx when Idx > 0 ->
            erlang:error(invalid_token)
    end;

lex(_Dict, Peak, [ FirstChar | _Chars ]) when (Peak < $0 orelse Peak > $9) andalso (FirstChar >= $0 andalso FirstChar =< $9) ->
    erlang:error(invalid_token);
lex(Dict, Peak, Word) when (Peak >= $a andalso Peak =< $z) orelse (Peak >= $A andalso Peak =< $Z) orelse (Peak >= $0 andalso Peak =< $9) orelse Peak =:= $_ ->
    lex(Dict, get_char(), string:concat(Word, [Peak])).
lex(Dict, Peak, "") when Peak =:= $> orelse Peak =:= $< orelse Peak =:= $! orelse Peak =:= $= ->
    case get_char() of
        $= -> [{[Peak, $=]}, Dict];
        Peak -> 

token_new(Tag, Value) -> {Tag, Value}.



test() ->
    [ Token | _ ] = try lex()
        catch
            error:invalid_token -> io:put_chars("Invalid Token"), init:stop()
        end,
    io:format("~p~n", [Token]).

