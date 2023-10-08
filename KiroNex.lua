local KiroNex = {
    Modules = {},
}


function KiroNex.init(container, match : table)
    for _, module in container:GetDescendants() do
        local isModule = module:IsA("ModuleScript")
        for _, matched in match do
            if isModule and module.Name:match(`{matched}$`) then
                if KiroNex.Modules[module.Name] ~= nil then return end

                if (typeof(require(module)) == "table") then
                    KiroNex.Modules[module.Name] = require(module)
                elseif (typeof(require(module)) == "function") then
                    KiroNex.Modules[module.Name] = require(module)()
                end
            end
        end
    end
end

function KiroNex.add(container_or_file)
    if KiroNex.Modules[container_or_file.Name] ~= nil then return end
    if typeof(container_or_file) == 'table' then

        for _, module in container_or_file do
            local isModule = module:IsA("ModuleScript")

            if isModule then
                if KiroNex.Modules[module.Name] ~= nil then return end
                KiroNex.Modules[module.Name] = require(isModule)
            end
        end

        return;
    end
    KiroNex.Modules[container_or_file.Name] = require(container_or_file)
end

function KiroNex.use(ModuleName: string & 'Example: KiroNex:use("Hitbox")')
    if KiroNex.Modules[ModuleName] == nil then return end
    return KiroNex.Modules[ModuleName]
end

return KiroNex
