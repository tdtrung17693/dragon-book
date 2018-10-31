-module (parser).
-export ([parse/2]).

parse(ex1, Source) ->
    case length(s1(string:strip(Source))) of
        L when L > 0 -> erlang:error(invalid_expr);
        _ -> { ok }
    end;
parse(ex2, Source) ->
    case length(s2(string:strip(Source))) of
        L when L > 0 -> erlang:error(invalid_expr);
        _ -> { ok }
    end;
parse(ex3, Source) ->
    case length(s3(string:strip(Source))) of
        L when L > 0 -> erlang:error(invalid_expr);
        _ -> { ok }
    end;

% S -> + S S | - S S | num
% num -> num digit | digit

s1([ A | Source ]) when A =:= $+ ; A =:= $- ->
    R = s1(Source),

    Next = s1(R),
    Next;
s1([ A ]) when A =< $9, A >= $0 -> [];
s1([ A | Source ]) when A =< $9, A >= $0 ->
    [ NextA | _NSource ] = Source,
    case NextA of
        D when D =< $9 andalso D >= $0 -> s1(Source);
        _ -> Source
    end;

s1([ $\s | Source ]) ->
    s1(Source);

s1([]) -> erlang:error(invalid_expr);
s1([ _A | _ ]) -> erlang:error(invalid_expr).

% S -> S (S) S | epsilon
s2([ $( ]) -> erlang:error(invalid_expr);
s2([ $\s | Source ]) -> s2(Source);
s2([ $(, $) | Source ]) ->
    s2(Source);
s2([ $( | Source ]) ->
    io:format("Source ~p~n", [Source]),
    [ $) | Next ] = try  s2(Source)
    catch
        error:badmatch -> erlang:error(invalid_expr);
        _ -> erlang:error(unexpected_error)
    end,
    io:format("After: ~p~n", [Next]),
    s2(Next);
s2([ $) | Source ]) ->
    [ $) | Source ];
s2([]) -> [].

% S -> 0 S 1 | 0 1
s3([ $0, $1 | Source ]) -> Source;
s3([ $0 | Source ]) ->
    [ A | NSource ] = s3(Source),
    case A of
        $\s -> [ $1 | NSource2 ] = s3(NSource), NSource2;
        $1 -> NSource;
        _ -> erlang:error(invalid_expr)
    end;
s3([ $1 | Source ]) -> [ $1 | Source ];
s3([ $\s | Source ]) -> s3(Source);
s3([ _ | Source ]) -> erlang:error(invalid_expr);
s3([]) -> [].