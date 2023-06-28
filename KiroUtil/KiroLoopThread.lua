--[[
to delay or add any wait() you would have to use tick() or os.time()

@start() a new loop

@fill() insert a new function inside
@sparam requires a given name index space to clear the function later.
@fparam requires a function to fill the loop to run through

@get() returns the table of function table to index and remove them later on.

@remove() 
@snparam (give-name) indexes through self._func to search the given name when loop is attached.

@terminate() ends the loop.

example usage:
    Server or Client:
        local KiroLoop = require(KiroLoop).new()
        KiroLoop:Start()

        KiroLoop:Fill("any_name", function()
            print("loop 1")
        end)

        KiroLoop:Fill("any_name1", function()
            print("loop 2")
        end)
]]

local RunService = game:GetService("RunService")
local KiroLoop = {}
KiroLoop.__index = KiroLoop

function KiroLoop.new()
    local self = setmetatable({}, KiroLoop)

    self._func = {}
    self._cycle = nil
    self._isRunning = false
    self._dupes = 0

    print(getmetatable(self))
    return self
end

function KiroLoop:Start()
    if not self._isRunning  then
        self._connection = RunService.Heartbeat:Connect(function()
            self:Iterate()
        end)
    else
        warn(`{script.Name} :Start() cannot be called twice without destroying the old loop first.`)
    end
    self._isRunning = true
end

function KiroLoop:Fill(fn_name: string | number?, fn:() -> ())
    assert(fn_name ~= nil, "fn_name can't be nil!")
    assert(type(fn) == "function", "Fn isn't a function!")

    if self._func[fn_name] then
        self._dupes += 1
        self._func[`{fn_name}{self._dupes}`] = fn
    else
        self._func[fn_name] = fn
    end

    return self
end


function KiroLoop:terminateWait(num: number)
    task.delay(num, function()
        self:Terminate()
    end)
end

function KiroLoop:removeFunction(fn_name: string | number?)
    if self._func[fn_name] then
        self._func[fn_name] = nil
        self._dupes -= 1
    end

    return self
end

function KiroLoop:removeFunctionWait(fn_name: string | number?, num: number)
    task.delay(num, function()
        if self._func[fn_name] then
            self._func[fn_name] = nil
            self._dupes -= 1
        end
    end)
    
    return self
end

function KiroLoop:IsActive()
    return self._isRunning
end

function KiroLoop:Terminate()
    self._connection:Disconnect()
    self._connection = nil
    self._isRunning = false
    
    if self._cycle then
        coroutine.close(self._cycle)
        self._cycle = nil
    end
    
    table.clear(self._func)
    self = nil
end

function KiroLoop:Iterate()
    for _, _func in self._func do
        if typeof(_func) == "function" then
            self._cycle = coroutine.create(_func);
            coroutine.resume(self._cycle); coroutine.close(self._cycle);
            self._cycle = nil;
        end
    end
end

return KiroLoop
