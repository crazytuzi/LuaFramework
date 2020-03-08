local ModuleBase = require("Main.module.ModuleBase")
local SwornMgr = require("Main.Sworn.SwornMgr")
local Lplus = require("Lplus")
local SwornModule = Lplus.Extend(ModuleBase, "SwornModule")
local def = SwornModule.define
local instance
def.static("=>", SwornModule).Instance = function()
  if not instance then
    instance = SwornModule()
    instance.m_moduleId = ModuleId.SWORN
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  SwornMgr.Instance():Init()
end
def.override().OnReset = function(self)
  SwornMgr.Instance:Reset()
end
SwornModule.Commit()
return SwornModule
