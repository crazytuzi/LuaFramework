local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ProtectionFactory = Lplus.Class(CUR_CLASS_NAME)
local CommonProtection = import(".CommonProtection")
local def = ProtectionFactory.define
def.const("table").ProtectionType = {OnHook = 1, ZhenYaoActivity = 2}
local instance
def.static("=>", ProtectionFactory).Instance = function()
  if instance == nil then
    instance = ProtectionFactory()
  end
  return instance
end
def.method("number", "=>", CommonProtection).CreateProtection = function(self, pType)
  if pType == ProtectionFactory.ProtectionType.OnHook then
    return import(".OnHookProtection", CUR_CLASS_NAME)()
  elseif pType == ProtectionFactory.ProtectionType.ZhenYaoActivity then
    return import(".ZhenYaoActivityProtection", CUR_CLASS_NAME)()
  else
    return import(".NoProtection", CUR_CLASS_NAME)()
  end
end
return ProtectionFactory.Commit()
