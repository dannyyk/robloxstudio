--!nonstrict

--[[

    -@kiro-event-wrapper
    -@authored by: Kiro
    -@class: Events

    The usage of this Module is to lower too much usage of RBXScriptSignal / Event.
    The way this works is when you construct this module .new()
    It will create a RBXScriptSignal/Event and calls all the function by using one-event
    
    This is an alternate version of using ConnectParallel but you need an Actor to use it.

    With my Module you won't need an Actor to use it.

    GLOBALS:
        FillGlobal -- adds another function to the given **event_name**
            - Goes to globalTable
            - Actives in Event

        DeleteGlobal -- removes a function to the given **event_name** and **name_thread**
            - Goes to globalTable
            - Actives in Event
            - Has call-back (global_function, globalTableF)
                * The call back are for bug research

        Disconnect -- Destroys an event when **event_name** is given
            - Goes to connectionTable
            - Actives in Event

    INIT:
        Connect -- starts the event
            - Starts an Event

        Fill -- auto-matically adds a function inside **Event**
            - Goes to _0functiontbl
            - Actives in Event    

        Delete -- auto-matically deletes a function
            - Goes to _0functiontbl
            - Actives in Event
            - Has call-back (init_function, _0functiontbl)
                * The call back are for bug research

        Disconnect -- Destroys an event auto-matically
            - Goes to connectionTable
            - Actives in Event
            - Has call-back (table of connection)
]]

local connectionTable = {} :: {RBXScriptSignal | RBXScriptConnection}

local globalTableF = {} :: {() -> ()}

local Kiraps = {} :: {}
Kiraps.__index = Kiraps

function Kiraps.new(event_name: string | number, con: RBXScriptSignal) : ()
    assert(typeof(con) == "RBXScriptSignal", `{con} isn't a signal!`)

    if connectionTable[event_name] == nil then
        if connectionTable[event_name] then
            return error("Cannot have the same name")
        end

        connectionTable[event_name] = con
    end

    return setmetatable(
        {
        _0functiontbl = {} :: {},
        _0event_name = event_name :: string or nil,
        },Kiraps
    )
end

function Kiraps:FillGlobal(event_name: string | number, name_thread: string, fn: () -> ())
    assert(name_thread ~= nil, "name_thread cannot be nil!")

    if connectionTable[event_name] == nil then
        return error("No connection was found.")
    end

    if globalTableF[event_name] == nil then
        globalTableF[event_name]= {}
        globalTableF[event_name][name_thread] = fn

        return
    end

    if globalTableF[event_name][name_thread] == nil and globalTableF[event_name] ~= nil then
        globalTableF[event_name][name_thread] = fn

        return
    end

    return self
end

function Kiraps:Fill(fn:() -> ()): ()
    if self._0event_name == nil or connectionTable[self._0event_name] == nil then
        return error("No namespace in the constructor or no connection was found.")
    end

    if self._0functiontbl[self._0event_name] == nil then
        self._0functiontbl[self._0event_name] = {}
    end

    self._currentfunction = fn
    self._0functiontbl[self._0event_name][self._currentfunction] = fn

    return self
end

function Kiraps:DeleteGlobal(event_name: string | number, name_thread : string, fn: (...any)->(...any)) : ()
    assert(event_name ~= nil, "event_name cannot be nil!")

    if globalTableF[event_name] ~= nil then
        globalTableF[event_name][name_thread] = nil

        if fn then
            fn(globalTableF)
        end
    end

    return self
end

function Kiraps:Delete(fn: (...any)->(...any)) : ()
    if self._0event_name == nil then
        return
    end

    if self._0functiontbl[self._0event_name] ~= nil then
        if self._currentfunction ~= nil then
            self._0functiontbl[self._0event_name][self._currentfunction] = nil

            if fn then
                fn(self._0functiontbl)
            end

        end
    end

    return self
end

function Kiraps:_tableFunc(table: {}, ...)
    if table == nil then
        return
    end

    for _, _0functiontbl in table do
        if _0functiontbl then
            _0functiontbl(...)
        end
    end
end

--[[function Kiraps:returnFunction(types: boolean)
    if types ~= nil then
        print(globalTableF)

        return
    end

    print(self._0functiontbl)
end]]

function Kiraps:Connect(fn:() -> ()) : ()
    assert(type(fn) == "function", `{fn} is not a function!`)

    if self._0event_name == nil then
        return
    end

    if connectionTable[self._0event_name] ~= nil and typeof(connectionTable[self._0event_name]) == "RBXScriptSignal" then
        connectionTable[self._0event_name] = connectionTable[self._0event_name]:Connect(function(...)
            fn(...)

            self:_tableFunc(self._0functiontbl[self._0event_name], ...)

            if globalTableF[self._0event_name] then
                self:_tableFunc(globalTableF[self._0event_name], ...)
            end
            
        end)
    else
        error("Cannot use Event once this event is connected.")
    end

    return self
end

function Kiraps:Disconnect(event_name_or_callback: string | number | (...any)->(...any), fn: (...any)->(...any))
    if event_name_or_callback ~= nil then
        connectionTable[event_name_or_callback]:Disconnect()
        connectionTable[event_name_or_callback] = nil
        globalTableF[event_name_or_callback] = nil

        if fn then
            fn(connectionTable)
        end
    end

    if self._0event_name ~= nil then
        connectionTable[self._0event_name]:Disconnect()
        connectionTable[self._0event_name] = nil
        globalTableF[self._0event_name] = nil
        self._0functiontbl[self._0event_name] = nil

        if typeof(event_name_or_callback) == "function" then
            event_name_or_callback(connectionTable)
        end

    end

    return self
end

--[[function Kiraps:Destroy(): ()
    if self == nil then
        return
    end

    for _, connections in connectionTable do
        connections:Disconnect()
        connections = nil
    end

    self._0functiontbl = nil;
    self._0event_name = nil;

    table.clear(globalTableF)
    table.clear(connectionTable)
    table.clear(self)
    
    return self
end]]

return Kiraps
