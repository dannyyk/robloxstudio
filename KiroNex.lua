--[[
    API:
    >> function: {
        
        self:init(TABLE, SELECTOR) 
            -- FILLS THE CLIENT TABLE MODULE /  SERVER TABLE MODULE
                * TABLE: [any]
                    -- Path or a Folder or a Class to path to.
                * SELECTOR: [INDEXER]
                 -- must select through
                    -- Util
                    -- Script
                    -- Unknown
        self:load(TABLE, PATTERN)
            -- REQUIRES ALL THE MODULESCRIPTS
                * TABLE: [any] :: TABLE
                    -- Path or a Folder or a table to path to.
                * PATTERN: [any] :: TABLE
                    -- A table to match the pattern string names of the ModuleScript that was filled.

        EXAMPLES:
            self:init(ServerScriptService.Folder, "Script"):load("Script", {"Stuff_folder", "load_folder"})

            self:init(ServerScriptService.Folder, "Util")
    }
]]
local KiroNet = {
    Modules = {
        Util = {},
        Script = {},
        Unknown = {}
    }
}

function KiroNet:init(Table : any, Select : string)
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

function KiroNet:load(Select : string, pattern : any)

    for _, Modules in self.Modules[Select] do
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
