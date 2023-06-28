--[[
to delay or add any wait() you would have to use tick() or os.time()

@start() a new loop

@fill() insert a new function inside
@sparam requires a given name index space to clear the function later.
@fparam requires a function to fill the loop to run through

@get() returns the table of function table to index and remove them later on.

@terminate() Ends the loop.

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
    self.Connection = nil
    
    setmetatable(self, KiroLoop)

    return self
end

function KiroLoop:Fill(give_name: string | number?, fn)
    assert(give_name ~= nil, "give_name can't be nil!")
    assert(type(fn) == "function", "Fn isn't a function!")

    self._func[give_name] = fn
end

function KiroLoop:Get()
    return self._func
end

function KiroLoop:Terminate()
    self.Connection:Disconnect()
    self.Connection = nil
end

function KiroLoop:Start()
    self.Connection = RunService.Heartbeat:Connect(function()
        for _, fn in self._func do
            if typeof(fn) == "function" then
                fn()
            end
        end
    end)
end

return KiroLoop
