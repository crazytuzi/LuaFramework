require "Core.Module.Pattern.Notification"

ModuleManager = {
    canGotoSameModule = false
};

ModuleManager._currentModule = nil;
ModuleManager._additionalModules = { };

function ModuleManager.GetCurrentModule()
    return ModuleManager._currentModule;
end

function ModuleManager.GotoModule(theModule, data)
    if ModuleManager._currentModule ~= nil then
        if ModuleManager.canGotoSameModule and ModuleManager._currentModule:GetModuleName() == theModule:GetModuleName() then
            Error("Don't goto the same module twice when the value of canGotoSameModule is false !");
            return;
        end
        ModuleManager._currentModule:Destroy();
    end

    ModuleManager._currentModule = theModule;
    ModuleManager._currentModule:Init(data);
end

function ModuleManager.ExistAdditionalModule(moduleName)
    for i, v in ipairs(ModuleManager._additionalModules) do
        if v:GetModuleName() == moduleName then
            return true;
        end
    end
    return false;
end
local insert = table.insert

function ModuleManager.AddAdditionModule(theModule, data)
    if ModuleManager.ExistAdditionalModule(theModule:GetModuleName()) then
        Error("Don't add the same addtional module twice." .. theModule:GetModuleName());
        return;
    end
    insert(ModuleManager._additionalModules, theModule);
    theModule:Init(data, nil);
end

function ModuleManager.RemoveAdditionalModule(moduleName)
    for i, v in ipairs(ModuleManager._additionalModules) do
        if v:GetModuleName() == moduleName then
            v:Destroy();
            table.remove(ModuleManager._additionalModules, i);
            return;
        end
    end
    Error("Don't remove the not exist addtional module.");
end

function ModuleManager._Notify(notification)
    if ModuleManager._currentModule ~= nil then
        ModuleManager._currentModule:Notify(notification);
    end
    for i, v in ipairs(ModuleManager._additionalModules) do
        v:Notify(notification);
    end
end

function ModuleManager.SendNotification(notificationName, body, type)
    ModuleManager._Notify(Notification:New(notificationName, body, type));
end

function ModuleManager.RetrieveModule(moduleName)
    if ModuleManager._currentModule ~= nil and ModuleManager._currentModule:GetModuleName() == moduleName then
        return ModuleManager._currentModule;
    end
    for i, v in ipairs(ModuleManager._additionalModules) do
        if v:GetModuleName() == moduleName then
            return v;
        end
    end
    return nil;
end

function ModuleManager.RetrieveProxy(moduleName)
    local theModule = ModuleManager.RetrieveModule(moduleName);
    if theModule ~= nil then
        return theModule:GetProxy();
    end
    return nil;
end

function ModuleManager.RetrieveMediator(moduleName)
    local theModule = ModuleManager.RetrieveModule(moduleName);
    if theModule ~= nil then
        return theModule:GetMediator();
    end
    return nil;
end