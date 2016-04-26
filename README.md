crdb
=====

A simple project for testing out fork of epgsql against cockroachdb.

This is _only_ testing squery (simple query), no queries with bindings

Build
-----

    $ rebar3 compile
    $ rebar3 escriptize
    
    Requires a test database named 'test' with a single table
    ```
    CREATE TABLE test (test_id integer PRIMARY KEY, test_value text);
    ```
    
    The build will create a single executable at _build/default/bin/crdb
    
    Example Usage:
    
    _build/default/bin/crdb --host=localhost --port=26258 --db=test --user=testuser --pass=testpass
    
    Expected results:
    
    ```
    INSERT: {ok,1}
    SELECT: Columns: [{column,<<"test_id">>,int8,8,0,0},
                  {column,<<"test_value">>,text,-1,0,0}] Values: [{<<"1">>,
                                                                   <<"TEST">>}]
    COUNT: Cols: [{column,<<"COUNT(*)">>,int8,8,0,0}] Values: [{<<"1">>}]
    DELETE: {ok,1}
    ```


