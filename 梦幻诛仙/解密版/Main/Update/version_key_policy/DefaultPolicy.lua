local MODULE_NAME = (...)
local Lplus = require("Lplus")
local VersionKeyPolicy = import(".VersionKeyPolicy")
local DefaultPolicy = Lplus.Extend(VersionKeyPolicy, MODULE_NAME)
local def = DefaultPolicy.define
def.const("number").KEY_PC = 1
def.const("number").KEY_IOS = 2
def.const("number").KEY_ANDROID = 3
def.override("=>", "number").GetResourceVersionKey = function(self)
  if _G.platform == Platform.win then
    return DefaultPolicy.KEY_PC
  elseif _G.platform == Platform.ios then
    return DefaultPolicy.KEY_IOS
  elseif _G.platform == Platform.android then
    return DefaultPolicy.KEY_ANDROID
  else
    error("platform error: " .. tostring(_G.platform))
  end
end
return DefaultPolicy.Commit()
