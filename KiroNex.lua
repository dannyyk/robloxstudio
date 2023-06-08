--[[
    API:
    >> function: {
        self:init() 
            -- FILLS THE CLIENT TABLE MODULE /  SERVER TABLE MODULE
    }
]]
local KiroNet = {
    Modules = {
        Util = {},
        Script = {},
        Unknown = {}
    }
}

function KiroNet:init(Table : Folder, Select : string)
    if Select == nil then
        Select = "Unknown"
    end

    for _, Modules in Table:GetDescendants() do
        local IsModuleScript = Modules:IsA("ModuleScript")

        if IsModuleScript then
            self.Modules[Select][Modules.Name] = Modules
        end
    end

    return self
end

function KiroNet:load(Table, pattern)

    for _, Modules in Table do
        task.spawn(function()
            for _, Array in pattern do
                if table.find(pattern, Modules.Name:match(`{Array}$`)) then
                    if typeof(require(Modules)) == "table" then
                        require(Modules)
            
                    elseif typeof(require(Modules)) == "function" then
                        require(Modules)()
                    end
                end
            end
        end)
    end
    
    return self
end

return KiroNet
