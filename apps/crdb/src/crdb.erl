%%%-------------------------------------------------------------------
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(crdb).

%% API
-export([main/1]).

main(Help) when Help == ["-h"] orelse Help == ["--help"] ->
    help_message(),
    halt(0);
main([]) ->
    help_message(),
    halt(0);
main(Args0) ->
    ok = application:start(asn1),
    ok = application:start(crypto),
    ok = application:start(public_key),
    ok = application:start(ssl),
    ok = application:start(epgsql),
    Args = args_to_settings(Args0),
    {ok, Conn} = connect(Args),
    _ = pgsql:squery(Conn, "TRUNCATE test"),
    {ok, _} = InsertRes = pgsql:squery(Conn, "INSERT INTO test (test_id, test_value) VALUES (1::integer, 'TEST'::text)"),
    io:format("INSERT: ~p~n", [InsertRes]),
    {ok, SelCols, SelValues} = pgsql:squery(Conn, "SELECT * FROM test WHERE test_id = 1"),
    io:format("SELECT: Columns: ~p Values: ~p~n", [SelCols, SelValues]),
    {ok, CntCols, CntValues} = pgsql:squery(Conn, "SELECT COUNT(*) FROM test"),
    io:format("COUNT: Cols: ~p Values: ~p~n", [CntCols, CntValues]),
    {ok, _} = DelRes = pgsql:squery(Conn, "DELETE FROM test WHERE test_id = 1"),
    io:format("DELETE: ~p~n", [DelRes]),
    close(Conn),
    halt(0).

connect(Args) ->
    Opts = [{database, proplists:get_value(database, Args)},
            {port, proplists:get_value(port, Args)},
            {ssl, proplists:get_value(ssl, Args)}],
    case pgsql:connect(proplists:get_value(host, Args),
                        proplists:get_value(username, Args),
                        proplists:get_value(password, Args),
                        Opts) of
        {ok, Conn} ->
            {ok, Conn};
        {error, Error} ->
            io:format("Connection Error: ~p", [Error])
    end.

close(Conn) ->
    pgsql:close(Conn).

args_to_settings(Args) ->
    lists:foldl(
      fun(Arg, Acc) ->
              case Arg of
                  "--db=" ++ Database ->
                      [{database, Database} | Acc];
                  "--port=" ++ Port ->
                      [{port, list_to_integer(Port)} | Acc];
                  "--host=" ++ Host ->
                      [{host, Host} | Acc];
                  "--pass=" ++ Pass ->
                      [{password, Pass} | Acc];
                  "--user=" ++ Username ->
                      [{username, Username} | Acc];
                  "--ssl=required" ->
                      [{ssl, required} | Acc];
                  "--ssl=true" ->
                      [{ssl, true} | Acc];
                  "--ssl=false" ->
                      [{ssl, false} | Acc]
              end
      end, [], Args).

help_message() ->
    io:format("Usage: crdb --host=HOST --port=PORT --db=DATABASENAME --user=USERNAME --pass=PASSWORD~n").
