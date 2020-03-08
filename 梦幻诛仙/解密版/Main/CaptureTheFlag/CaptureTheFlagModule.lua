local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local CaptureTheFlag = Lplus.Extend(ModuleBase, MODULE_NAME)
local def = CaptureTheFlag.define
local instance
def.static("=>", CaptureTheFlag).Instance = function()
  if instance == nil then
    instance = CaptureTheFlag()
    instance.m_moduleId = ModuleId.CTF
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, CaptureTheFlag.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, CaptureTheFlag.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, CaptureTheFlag.OnFeatureOpenInit)
  require("Main.CaptureTheFlag.mgr.BattleFieldMgr").Instance():Init()
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  require("Main.CaptureTheFlag.mgr.BattleFieldMgr").Instance():Reset()
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
end
def.static("table", "table").OnFeatureOpenChange = function(p1, p2)
end
return CaptureTheFlag.Commit()
