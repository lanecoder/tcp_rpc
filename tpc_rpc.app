{application, tcp_rpc, 
    [
     {description, "RPC server for Erlang and OTP action"},
     {vsn, "0.1.0"},
     {modules, 
        [
            tr_app,
            tr_sup,
            tr_server
        ]
     },
     {registered, [tr_sup, tr_server]},
     {application, [kernel, stdlib]},
     {mod, {tr_app, []}}
    ]}