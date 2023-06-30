--!nonstrict
local Connection = newproxy(true)
local connectionTable = getmetatable(Connection)

local globalFunction = newproxy(true)
local globalTableF = getmetatable(globalFunction)

local Kiraps = {} :: {}
Kiraps.__index = Kiraps

function Kiraps.new(name_space: string | number, con: RBXScriptSignal) : ()
    assert(typeof(con) == "RBXScriptSignal", `{con} isn't a signal!`)

    if connectionTable[con] == nil then
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
        _0old = nil :: RBXScriptSignal | nil
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
        return
    end

    if globalTableF[name_space][name_thread] == nil then
        globalTableF[name_space]._0globaltbl[name_thread] = fn
        return
    end

    return self
end

function Kiraps:deleteGlobal(name_space: string | number, name_thread : string)
    if globalTableF[name_space] ~= nil then
        if globalTableF[name_space]._0globaltbl[name_thread] then
            globalTableF[name_space]._0globaltbl[name_thread] = nil
            print(globalTableF)
        end
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

function Kiraps:_tableFunc(table: {})
    for _, _0functiontbl in table do
        if _0functiontbl then
            _0functiontbl()
        end
    end
end

function Kiraps:Event(fn:() -> ()) : ()
    assert(type(fn) == "function", `{fn} is not a function!`)

    if self._0connection and typeof(self._0connection) == "RBXScriptSignal" then

        if self._0old and self._0old.Connected then
            return error("Cannot connect more than one Event.")
        end
        
        self._0old = connectionTable[self._0namespace]:Connect(function(...)
            fn(...)
            if self._0functiontbl[self._0namespace] == nil then return end
            self:_tableFunc(self._0functiontbl[self._0namespace])
            self:_tableFunc(globalTableF[self._0namespace]._0globaltbl)
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

function Kiraps:Destroy(): ()
    self._0old:Disconnect();
    self._0old = nil;
    self._0connection = nil;

    if globalTableF[self._0namespace] then
        for _, threads in globalTableF[self._0namespace]._0globaltbl do
            coroutine.close(threads)
        end
        globalTableF[self._0namespace] = nil;
    end

    connectionTable[self._0namespace] = nil;
    self._0functiontbl[self._0namespace] = nil;
    self._0namespace = nil;

    return self
end

return Kiraps
