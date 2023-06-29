--[[
to delay or add any wait() you would have to use tick() or os.time()

@startLoop() a new loop

@fill() insert a new function inside
@sparam requires a given name index space to clear the function later.
@fparam requires a function to fill the loop to run through

@removeFunction() 
@snparam (give-name) indexes through self._func to search the given name when loop is attached.

@terminate() ends the loop.
@num has 1 paramater that takes a number to declare when will the loop will be gone.
example usage:
    Server or Client:
        local KiroThread = require(KiroThread).new()
        KiroThread:startLoop()

        KiroThread:fill("any_name", function()
            print("loop 1")
        end)

        KiroThread:fill("any_name1", function()
            print("loop 2")
        end)
]]

local RunService = game:GetService("RunService")
local KiroThread = {}
KiroThread.__index = KiroThread

function KiroThread.new()
    local self = setmetatable({}, KiroThread)

    self._func = {}
    self._threadfunc = {}
    self._isRunning = false
    self._dupes = 0

    return self
end

function KiroThread:startLoop()
    if not self._isRunning  then
        self._connection = RunService.Heartbeat:Connect(function()
            self:_iterate()
        end)
    else
        warn(`{script.Name} :Start() cannot be called twice without destroying the old loop first.`)
    end
    self._isRunning = true;

    return
end

-- // _private

function KiroThread:_disconnect(fn_name)
    assert(typeof(fn_name) == "string" or "number", "num must be a number!")

    if self._func[fn_name] then
        self._func[fn_name] = nil;
        self._dupes -= 1;
    end
end

function KiroThread:_destroy()
    if self._connection then
        self._connection:Disconnect()
        self._connection = nil
    end

    self._isRunning = false;
    
    table.clear(self._func);
    self = nil;
end

function KiroThread:_add(fn_name, fn)
    self._dupes += 1;
    if self._func[fn_name] then
        self._func[`{fn_name}{self._dupes}`] = fn
    else
        self._func[fn_name] = fn
    end
end

function KiroThread:_iterate()
    for _, _func:() -> () in self._func do
        if typeof(_func) == "function" then
            self:once(_func)
        end
    end
end

--==============================================================================

function KiroThread:terminate(num: number)
    if not self._isRunning then
        warn(`{script.Name} self:terminate() can't be used unless -> KiroThread: startLoop() is called`)
    end

    if num then
        assert(type(num) == "number", "num isn't a number!")
        task.delay(num, function()
            self:_destroy()
        end)

        return
    end
    

    self:_destroy()
end

function KiroThread:removeFunction(fn_name: string | number?, num: number)
    if num then
        assert(type(num) == "number", "num isn't a number!")

        task.delay(num, function()
            self:_disconnect(fn_name)
            print(self)
        end)

        return
    end

    self:_disconnect(fn_name)
    return self
end

function KiroThread:fill(fn_name: string | number?, fn:() -> ())
    assert(fn_name ~= nil, "fn_name can't be nil!")
    assert(type(fn) == "function", "Fn isn't a function!")
    self:_add(fn_name, fn)

    if not self._isRunning then
        warn(`{script.Name} self:fill() can't be used unless -> KiroThread: startLoop() is called`)
    end

    return self
end

function KiroThread:addThread(fn:() -> ())
    local createC = coroutine.create(fn);
    
    return createC
end

function KiroThread:once(fn:() -> ())
    local thread = self:addThread(fn); coroutine.resume(thread);
    self:closeThread(thread); thread = nil;

    return self
end

function KiroThread:closeThread(fn_or_thread: any)
    return coroutine.close(fn_or_thread)
end

return KiroThread
