--!nonstrict

--[[

    -@kiro-event-wrapper
    -@authored by: Kiro
    -@class: Kiraps

    GLOBALS:
        addGlobal -- adds another function to the given **name_space**
            - Goes to globalTable
            - Actives in Event

        deleteGlobal -- removes a function to the given **name_space** and **name_thread**
            - Goes to globalTable
            - Actives in Event

        Disconnect -- Destroys an event when **name_space** is given
            - Goes to connectionTable
            - Actives in Event

    INIT:
        Event -- starts the event
            - Starts an Event

        delete -- auto-matically deletes a function
            - Goes to _0functiontbl
            - Actives in Event

        Fill -- auto-matically adds a function inside **Event**
            - Goes to _0functiontbl
            - Actives in Event

        Destroy -- Destroy all of the event itself and cleans up the functions.
            - Goes to connectionTable
            - Actives in Event

        Disconnect -- Destroys an event auto-matically
            - Goes to connectionTable
            - Actives in Event
]]

local connectionTable = {} :: {RBXScriptSignal | RBXScriptConnection}

local globalTableF = {} :: {() -> ()}

local Kiraps = {} :: {}
Kiraps.__index = Kiraps

function Kiraps.new(name_space: string | number, con: RBXScriptSignal) : ()
    assert(typeof(con) == "RBXScriptSignal", `{con} isn't a signal!`)

    if connectionTable[name_space] == nil then
        if connectionTable[name_space] then
            return error("Cannot have the same name")
        end

        connectionTable[name_space] = con
    end

    return setmetatable(
        {
        _0functiontbl = {} :: {},
        _0namespace = name_space :: string or nil,
        _0connection = connectionTable[name_space] :: RBXScriptSignal,
        _0isUsing = nil :: RBXScriptSignal | nil
        },Kiraps
    )
end

function Kiraps:addGlobal(name_space: string | number, name_thread: string, fn: () -> ())
    assert(name_thread ~= nil, "name_thread cannot be nil!")

    if connectionTable[name_space] == nil then
        return
    end

    if globalTableF[name_space] == nil then
        globalTableF[name_space] = {}
        globalTableF[name_space]._0globaltbl = {}
        globalTableF[name_space]._0globaltbl[name_thread] = fn

        print(globalTableF)
        return
    end

    if globalTableF[name_space][name_thread] == nil then
        globalTableF[name_space]._0globaltbl[name_thread] = fn
        print(globalTableF)
        return
    end

    return self
end

function Kiraps:deleteGlobal(name_space: string | number, name_thread : string)
    if globalTableF[name_space] ~= nil then
        globalTableF[name_space]._0globaltbl[name_thread] = nil
    end

    return self
end

function Kiraps:delete()
    if self._0functiontbl[self._0namespace] ~= nil then
        if self._currentfunction ~= nil then
            self._0functiontbl[self._0namespace][self._currentfunction] = nil
            print(self._0functiontbl)
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

function Kiraps:returnFunction(types: boolean)
    if types ~= nil then
        print(globalTableF)

        return
    end

    print(self._0functiontbl)
end

function Kiraps:Event(fn:() -> ()) : ()
    assert(type(fn) == "function", `{fn} is not a function!`)

    if connectionTable[self._0namespace] ~= nil and typeof(connectionTable[self._0namespace]) == "RBXScriptSignal" then

        --[[if connectionTable[self._0namespace] and connectionTable[self._0namespace].Connected then
            return error("Cannot connect more than one Event.")
        end]]
        
        connectionTable[self._0namespace] = connectionTable[self._0namespace]:Connect(function(...)
            fn(...)

            self:_tableFunc(self._0functiontbl[self._0namespace], ...)
            self:_tableFunc(globalTableF[self._0namespace]._0globaltbl, ...)
        end)
    end

    return self
end

function Kiraps:Fill(fn:() -> ()): ()
    if self._0functiontbl[self._0namespace] == nil then
        self._0functiontbl[self._0namespace] = {}
    end

    self._currentfunction = fn
    self._0functiontbl[self._0namespace][self._currentfunction] = fn
    return self
end

function Kiraps:Disconnect(name_space: string | number)
    if name_space ~= nil then
        print(connectionTable[name_space])
        connectionTable[name_space]:Disconnect()
        connectionTable[name_space] = nil
        globalTableF[name_space] = nil

        print(connectionTable, globalTableF)
        
        return
    end

    connectionTable[self._0namespace]:Disconnect()
    connectionTable[self._0namespace] = nil
    globalTableF[self._0namespace] = nil
    self._0functiontbl[self._0namespace] = nil

    return self
end

function Kiraps:Destroy(): ()
    if self == nil then
        return
    end

    connectionTable[self._0namespace]:Disconnect();
    connectionTable[self._0namespace] = nil;

    globalTableF[self._0namespace] = nil;

    connectionTable[self._0namespace] = nil;
    self._0functiontbl[self._0namespace] = nil;
    self._0namespace = nil;
    
    table.clear(self)
    return self
end

return Kiraps
