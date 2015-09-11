-module(tachyon_kstat).
-behaviour(ensq_channel_behaviour).
-record(state, {host, port, connections = #{}}).
-export([init/0, response/2, message/3, error/2]).
init() ->
    {ok, {Host, Port}} = application:get_env(tachyon, ddb_ip),
    {ok, #state{host = Host, port = Port}}.
response(_Msg, State) ->
    {ok, State}.
error(_Msg, State) ->
    {ok, State}.
message(M, _, State) ->
    match(M, State).
putb(Bucket, Metric, Time, Value,
     State = #state{host = H, port = P, connections = Cs}) ->
    C1 = case maps:find(Bucket, Cs) of
             {ok, C} ->
                 C;
             error ->
                 {ok, CN0} = ddb_tcp:connect(H, P),
                 {ok, CN1} = ddb_tcp:stream_mode(Bucket, 2, CN0),
                 CN1
         end,
    tachyon_mps:send(),
    tachyon_mps:provide(),
    tachyon_mps:handle(),
    Metric2 = dproto:metric_from_list(Metric),
    case ddb_tcp:send(Metric2, Time, mmath_bin:from_list([Value]), C1) of
        {ok, C2} ->
            Cs1 = maps:put(Bucket, C2, Cs),
            {ok, State#state{connections = Cs1}};
        {error, _, C2} ->
            Cs1 = maps:put(Bucket, C2, Cs),
            {ok, State#state{connections = Cs1}}
    end.
do_ignore(ignore) -> true;
do_ignore(_) -> false.

match(<<_hostSize:32/integer, _host:_hostSize/binary,
        _uuidSize:32/integer, _uuid:_uuidSize/binary,
        _SnapTime:64/integer,
        _nameSize:32/integer, _name:_nameSize/binary,
        _moduleSize:32/integer, _module:_moduleSize/binary,
        _classSize:32/integer, _class:_classSize/binary,
        _Instance:64/integer,
        6:32/integer, "crtime",
        _/binary>>, State) ->
    tachyon_mps:provide(),
    {ok, State};

match(<<_hostSize:32/integer, _host:_hostSize/binary,
        _uuidSize:32/integer, _uuid:_uuidSize/binary,
        _SnapTime:64/integer,
        _nameSize:32/integer, _name:_nameSize/binary,
        _moduleSize:32/integer, _module:_moduleSize/binary,
        _classSize:32/integer, _class:_classSize/binary,
        _Instance:64/integer,
        8:32/integer, "snaptime",
        _/binary>>, State) ->
    tachyon_mps:provide(),
    {ok, State};

match(<<_hostSize:32/integer, _host:_hostSize/binary,
        _uuidSize:32/integer, _uuid:_uuidSize/binary,
        _SnapTime:64/integer,
        _nameSize:32/integer, _name:_nameSize/binary,
        _moduleSize:32/integer, _module:_moduleSize/binary,
        _classSize:32/integer, _class:_classSize/binary,
        _Instance:64/integer,
        8:32/integer, "zonename",
        _/binary>>, State) ->
    tachyon_mps:provide(),
    {ok, State};

match(<<_hostSize:32/integer, _host:_hostSize/binary,
        _uuidSize:32/integer, _uuid:_uuidSize/binary,
        _SnapTime:64/integer,
        _nameSize:32/integer, _name:_nameSize/binary,
        _moduleSize:32/integer, _module:_moduleSize/binary,
        _classSize:32/integer, _class:_classSize/binary,
        _Instance:64/integer,
        5:32/integer, "class",
        _/binary>>, State) ->
    tachyon_mps:provide(),
    {ok, State};

match(<<_HostSize:32/integer, Host:_HostSize/binary,
        6:32/integer, "global",
        SnapTime:64/integer,
        _nameSize:32/integer, _name:_nameSize/binary,
        2:32/integer, "ip",
        _classSize:32/integer, _class:_classSize/binary,
        _Instance:64/integer,
        _KeySize:32/integer, Key:_KeySize/binary,
        $i, V:64/integer>>, State) ->
    putb(<<"server">>, [Host, <<"ip">>, Key], SnapTime, V, State);

match(<<_HostSize:32/integer, Host:_HostSize/binary,
        6:32/integer, "global",
        SnapTime:64/integer,
        8:32/integer, "arcstats",
        3:32/integer, "zfs",
        _classSize:32/integer, _class:_classSize/binary,
        _Instance:64/integer,
        _KeySize:32/integer, Key:_KeySize/binary,
        $i, V:64/integer>>, State) ->
    putb(<<"server">>, [Host, <<"arc">>, Key], SnapTime, V, State);

match(<<_HostSize:32/integer, Host:_HostSize/binary,
        6:32/integer, "global",
        SnapTime:64/integer,
        _nameSize:32/integer, _name:_nameSize/binary,
        2:32/integer, "sd",
        _classSize:32/integer, _class:_classSize/binary,
        Instance:64/integer,
        _KeySize:32/integer, Key:_KeySize/binary,
        $i, V:64/integer>>, State) ->
    putb(<<"server">>, [Host, <<"disk">>, integer_to_binary(Instance), <<"metrics">>, Key], SnapTime, V, State);

match(<<_HostSize:32/integer, Host:_HostSize/binary,
        6:32/integer, "global",
        SnapTime:64/integer,
        _nameSize:32/integer, _name:_nameSize/binary,
        5:32/integer, "sderr",
        _classSize:32/integer, _class:_classSize/binary,
        Instance:64/integer,
        11:32/integer, "Hard Errors",
        $i, V:64/integer>>, State) ->
    putb(<<"server">>, [Host, <<"disk">>, integer_to_binary(Instance), <<"errors">>, <<"hard">>], SnapTime, V, State);

match(<<_HostSize:32/integer, Host:_HostSize/binary,
        6:32/integer, "global",
        SnapTime:64/integer,
        _nameSize:32/integer, _name:_nameSize/binary,
        5:32/integer, "sderr",
        _classSize:32/integer, _class:_classSize/binary,
        Instance:64/integer,
        11:32/integer, "Soft Errors",
        $i, V:64/integer>>, State) ->
    putb(<<"server">>, [Host, <<"disk">>, integer_to_binary(Instance), <<"errors">>, <<"soft">>], SnapTime, V, State);

match(<<_HostSize:32/integer, Host:_HostSize/binary,
        6:32/integer, "global",
        SnapTime:64/integer,
        _nameSize:32/integer, _name:_nameSize/binary,
        5:32/integer, "sderr",
        _classSize:32/integer, _class:_classSize/binary,
        Instance:64/integer,
        16:32/integer, "Transport Errors",
        $i, V:64/integer>>, State) ->
    putb(<<"server">>, [Host, <<"disk">>, integer_to_binary(Instance), <<"errors">>, <<"transport">>], SnapTime, V, State);

match(<<_HostSize:32/integer, Host:_HostSize/binary,
        6:32/integer, "global",
        SnapTime:64/integer,
        _nameSize:32/integer, _name:_nameSize/binary,
        5:32/integer, "sderr",
        _classSize:32/integer, _class:_classSize/binary,
        Instance:64/integer,
        27:32/integer, "Predictive Failure Analysis",
        $i, V:64/integer>>, State) ->
    putb(<<"server">>, [Host, <<"disk">>, integer_to_binary(Instance), <<"errors">>, <<"predicted_failures">>], SnapTime, V, State);

match(<<_HostSize:32/integer, Host:_HostSize/binary,
        6:32/integer, "global",
        SnapTime:64/integer,
        _nameSize:32/integer, _name:_nameSize/binary,
        5:32/integer, "sderr",
        _classSize:32/integer, _class:_classSize/binary,
        Instance:64/integer,
        15:32/integer, "Illegal Request",
        $i, V:64/integer>>, State) ->
    putb(<<"server">>, [Host, <<"disk">>, integer_to_binary(Instance), <<"errors">>, <<"illegal">>], SnapTime, V, State);

match(<<_HostSize:32/integer, Host:_HostSize/binary,
        6:32/integer, "global",
        SnapTime:64/integer,
        _nameSize:32/integer, _name:_nameSize/binary,
        8:32/integer, "cpu_stat",
        _classSize:32/integer, _class:_classSize/binary,
        Instance:64/integer,
        _KeySize:32/integer, Key:_KeySize/binary,
        $i, V:64/integer>>, State) ->
    putb(<<"server">>, [Host, <<"cpu">>, integer_to_binary(Instance), Key], SnapTime, V, State);

match(<<_HostSize:32/integer, Host:_HostSize/binary,
        6:32/integer, "global",
        SnapTime:64/integer,
        18:32/integer, "IP_NIC_EVENT_QUEUE",
        4:32/integer, "unix",
        _classSize:32/integer, _class:_classSize/binary,
        _Instance:64/integer,
        _KeySize:32/integer, Key:_KeySize/binary,
        $i, V:64/integer>>, State) ->
    putb(<<"server">>, [Host, <<"ip_nic_event_queue">>, Key], SnapTime, V, State);

match(<<_HostSize:32/integer, Host:_HostSize/binary,
        6:32/integer, "global",
        SnapTime:64/integer,
        _NameSize:32/integer, Name:_NameSize/binary,
        4:32/integer, "unix",
        _classSize:32/integer, _class:_classSize/binary,
        _Instance:64/integer,
        _KeySize:32/integer, Key:_KeySize/binary,
        $i, V:64/integer>>, State) ->
    putb(<<"server">>, [Host, <<"cache">>, Name, Key], SnapTime, V, State);

match(<<_HostSize:32/integer, Host:_HostSize/binary,
        6:32/integer, "global",
        SnapTime:64/integer,
        4:32/integer, "bge0",
        4:32/integer, "link",
        _classSize:32/integer, _class:_classSize/binary,
        _Instance:64/integer,
        _KeySize:32/integer, Key:_KeySize/binary,
        $i, V:64/integer>>, State) ->
    case do_ignore(parse_iface(Name)) of
        true -> {ok, State};
        _ ->
            putb(<<"server">>, [Host, <<"net">>, parse_iface(Name), Key], SnapTime, V, State)
    end;

match(<<_hostSize:32/integer, _host:_hostSize/binary,
        6:32/integer, "global",
        _SnapTime:64/integer,
        _nameSize:32/integer, _name:_nameSize/binary,
        _moduleSize:32/integer, _module:_moduleSize/binary,
        _classSize:32/integer, _class:_classSize/binary,
        _Instance:64/integer,
        _keySize:32/integer, _key:_keySize/binary,
        _/binary>>, State) ->
    tachyon_mps:provide(),
    {ok, State};

match(<<_hostSize:32/integer, _host:_hostSize/binary,
        _UuidSize:32/integer, Uuid:_UuidSize/binary,
        SnapTime:64/integer,
        _NameSize:32/integer, Name:_NameSize/binary,
        4:32/integer, "caps",
        _classSize:32/integer, _class:_classSize/binary,
        _Instance:64/integer,
        _KeySize:32/integer, Key:_KeySize/binary,
        $i, V:64/integer>>, State) ->
    case do_ignore(zone_stat(Name)) of
        true -> {ok, State};
        _ ->
            putb(<<"zone">>, [Uuid, zone_stat(Name), Key], SnapTime, V, State)
    end;

match(<<_hostSize:32/integer, _host:_hostSize/binary,
        _UuidSize:32/integer, Uuid:_UuidSize/binary,
        SnapTime:64/integer,
        _NameSize:32/integer, Name:_NameSize/binary,
        4:32/integer, "link",
        _classSize:32/integer, _class:_classSize/binary,
        _Instance:64/integer,
        _KeySize:32/integer, Key:_KeySize/binary,
        $i, V:64/integer>>, State) ->
    case do_ignore(parse_iface(Name)) of
        true -> {ok, State};
        _ ->
            putb(<<"zone">>, [Uuid, <<"net">>, parse_iface(Name), Key], SnapTime, V, State)
    end;

match(<<_hostSize:32/integer, _host:_hostSize/binary,
        _UuidSize:32/integer, Uuid:_UuidSize/binary,
        SnapTime:64/integer,
        _nameSize:32/integer, _name:_nameSize/binary,
        8:32/integer, "zone_vfs",
        _classSize:32/integer, _class:_classSize/binary,
        _Instance:64/integer,
        _KeySize:32/integer, Key:_KeySize/binary,
        $i, V:64/integer>>, State) ->
    putb(<<"zone">>, [Uuid, <<"vfs">>, Key], SnapTime, V, State);

match(<<_hostSize:32/integer, _host:_hostSize/binary,
        _UuidSize:32/integer, Uuid:_UuidSize/binary,
        SnapTime:64/integer,
        _nameSize:32/integer, _name:_nameSize/binary,
        8:32/integer, "zone_zfs",
        _classSize:32/integer, _class:_classSize/binary,
        _Instance:64/integer,
        _KeySize:32/integer, Key:_KeySize/binary,
        $i, V:64/integer>>, State) ->
    putb(<<"zone">>, [Uuid, <<"zfs">>, Key], SnapTime, V, State);

match(_, State) ->
    tachyon_mps:provide(),
    {ok, State}.
zone_stat(<<"cpucaps_zone_", _/binary>>) -> <<"cpu">>;
zone_stat(<<"physicalmem_zone_", _/binary>>) -> <<"mem">>;
zone_stat(<<"swapresv_zone_", _/binary>>) -> <<"swap">>;
zone_stat(<<"nprocs_zone_", _/binary>>) -> <<"nprocs">>;
zone_stat(_) -> ignore.
parse_iface(<<$z, _, $_, IFace/binary>>) -> IFace;
parse_iface(<<$z, _, _, $_, IFace/binary>>) -> IFace;
parse_iface(O) -> parse_iface1(O).
parse_iface1(<<$_, IFace/binary>>) -> IFace;
parse_iface1(<<_, Rest/binary>>) -> parse_iface(Rest);
parse_iface1(<<>>) -> <<"net">>.