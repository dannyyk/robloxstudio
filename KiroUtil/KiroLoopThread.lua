local RunService = game:GetService("RunService")
local KiroLoop = {}

function KiroLoop:Fill(give_name: string | number?, fn)
    assert(give_name ~= nil, "give_name can't be nil!")
    assert(type(fn) == "function", "Fn isn't a function!")

    if self._func == nil then
        self._func = {}
        self._func[give_name] = fn
    end

    self._func[give_name] = fn
end

function KiroLoop:Get()
    return self._func
end

function KiroLoop:Start()
    self._func = {}
    self.Connection = RunService.Heartbeat:Connect(function()
        for _, fn in self._func do
            if typeof(fn) == "function" then
                fn()
            end
        end
    end)
end

return KiroLoop
