
local CURRENT_MODULE_NAME = ...

local providers = {
    "PunchBox",
}
for _, packageName in ipairs(providers) do
    local className = "wowAd." .. packageName
    if not cc.Registry.exists(className) then
        cc.Registry.add(import("." .. packageName, CURRENT_MODULE_NAME), className)
    end
end

local wowAd = class("cc.wowAd")

local DEFAULT_PROVIDER_OBJECT_NAME = "wowAd.default"

function wowAd:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self.events = import(".events", CURRENT_MODULE_NAME)
    self.errors = import(".errors", CURRENT_MODULE_NAME)
    self.providers_ = {}
end

function wowAd:start(options, name)
    if not self.providers_[name] then
        local providerFactoryClass = cc.Registry.newObject(name)
        local provider = providerFactoryClass.getInstance(self, options)
        if not provider then
            printError("cc.wowAd:start() - create wowAd provider failed")
            return
        end

        self.providers_[name] = provider
        if not self.providers_[DEFAULT_PROVIDER_OBJECT_NAME] then
            self.providers_[DEFAULT_PROVIDER_OBJECT_NAME] = provider
        end
    end
end

function wowAd:getProvider(name)
    name = name or DEFAULT_PROVIDER_OBJECT_NAME
    if self.providers_[name] then
        return self.providers_[name]
    end
    printError("cc.wowAd:getProvider() - provider %s not exists", name)
end

function wowAd:stop(name)
    local provider = self:getProvider(name)
    if provider then
        provider:stop()
        self.providers_[name or DEFAULT_PROVIDER_OBJECT_NAME] = nil
    end
end

--[[
args {
    command = "要执行的命令",
    providerName = "模块名字",
    args = "执行命令的参数"
}
]]
function wowAd:doCommand(args)
    local provider = self:getProvider(name)
    if provider then
        provider:doCommand(args)
    end
end

function wowAd:remove(name)
    local provider = self:getProvider(name)
    if provider then
        provider:remove()
    end
end

return wowAd
