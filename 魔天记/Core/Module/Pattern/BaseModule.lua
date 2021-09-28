require "Core.Module.Pattern.Command";
require "Core.Module.Pattern.Mediator";
require "Core.Module.Pattern.Proxy";

BaseModule = {
    _moduleName = "BaseModule",
    -- string

    _data = nil,
    -- object

    _proxy = nil,
    -- Proxy
    _mediator = nil,
    -- Mediator
    _commands = nil-- table{commandName:Command}
};

function BaseModule:New()
    local o = { };
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function BaseModule._Start()
    Error("BaseModule._Start should be override !");
end

function BaseModule:Init(data)
    self._data = data;
    self:_Start();
end

function BaseModule:Init()
    self:_Start();
end

function BaseModule:_Dispose()
    Error("BaseModule._Dispose should be override !");
end

function BaseModule:Destroy()
    self:_Dispose();
    self._data = nil;
end

function BaseModule:_RegisterProxy(proxy)
    if proxy == nil then
        Error("Module:_RegisterProxy - proxy is null");
        return;
    end
    if self._proxy ~= nil then
        Error("Module:_RegisterProxy - _proxy already exist, Don't regist twice");
        return;
    end
    self._proxy = proxy;
    self._proxy:OnRegister();
end

function BaseModule:_RegisterMediator(mediator)
    if mediator == nil then
        Error("Module:_RegisterMediator - _mediator is null");
        return;
    end
    if self._mediator ~= nil then
        Error("Module:_RegisterMediator - _mediator already exist, Don't regist twice");
        return;
    end
    self._mediator = mediator;
    self._mediator:OnRegister();
end

function BaseModule:_RegisterCommand(notificationName, command)
    if self._commands[notificationName] ~= nil then
        Error("Module:_RegisterCommand - _commands already contains notification [" + notificationName + "]");
        return;
    end
    self._commands[notificationName] = command;
end

function BaseModule:_RemoveProxy()
    if self._proxy == nil then
        Error("Module:_RemoveProxy - _proxy not exist");
        return;
    end
    self._proxy:OnRemove();
    self._proxy = nil;
end

function BaseModule:_RemoveMediator()
    if self._mediator == nil then
        Error("Module:_RemoveMediator - _mediator not exist");
        return;
    end
    self._mediator:OnRemove();
    self._mediator = nil;
end

function BaseModule:_RemoveCommand(notificationName)
    if self._commands[notificationName] == nil then
        Error("Module:_RemoveCommand - _commands do not contains notification [" + notificationName + "]");
        return;
    end
    self._commands[notificationName] = nil;
end

function BaseModule:Notify(notification)
    if self._mediator ~= nil then
        self._mediator:HandleNotification(notification);
    end
    if self._commands ~= nil and self._commands[notification:GetName()] ~= nil then
        self._commands[notification:GetName()]:Execute(notification);
    end
end

function BaseModule:GetProxy()
    return self._proxy;
end

function BaseModule:GetProxy()
    return self._proxy;
end

function BaseModule:GetMediator()
    return self._mediator;
end

function BaseModule:GetModuleName()
    return self._moduleName;
end

function BaseModule:SetModuleName(name) 
    self._moduleName = name;
end