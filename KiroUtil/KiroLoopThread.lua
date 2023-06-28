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
        local KiroLoop = require(KiroLoop)
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
    local self = {}
    self._func = {}
    self._connection = nil
    self._cycle = nil
    self._isRunning = false
    
    setmetatable(self, KiroLoop)

    return self
end

function KiroLoop:Fill(give_name: string | number?, fn)
    assert(give_name ~= nil, "give_name can't be nil!")
    assert(type(fn) == "function", "Fn isn't a function!")

    self._func[give_name] = fn
end

function KiroLoop:Remove(give_name: string | number?)
    if self._func[give_name] then
        self._func[give_name] = nil
    end
end

function KiroLoop:Get()
    return self._func
end

function KiroLoop:Terminate()
    self._connection:Disconnect()
    self._connection = nil
    self._isRunning = false
    
    coroutine.close(self._cycle)

    self._cycle = nil
    table.clear(self._func)
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

function KiroLoop:Start()
    if self._isRunning then return end
    self._isRunning = true
    self._connection = RunService.Heartbeat:Connect(function()
        self:Iterate()
    end)
end

return KiroLoop
