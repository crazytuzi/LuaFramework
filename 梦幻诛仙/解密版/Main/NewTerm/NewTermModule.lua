local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local NewTermModule = Lplus.Extend(ModuleBase, "NewTermModule")
local instance
local def = NewTermModule.define
def.static("=>", NewTermModule).Instance = function()
  if instance == nil then
    instance = NewTermModule()
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  require("Main.NewTerm.NewTermMgr").Instance():Init()
  require("Main.NewTerm.NewTermProtocols").RegisterProtocols()
  require("Main.NewTerm.data.NewTermData").Instance():Init()
end
def.method("boolean", "=>", "boolean").IsOpen = function(self, bToast)
  local result = true
  if false == self:IsFeatrueOpen(bToast) then
    result = false
  end
  return result
end
def.method("boolean", "=>", "boolean").IsFeatrueOpen = function(self, bToast)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local result = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_ACTIVITY_ACHIEVEMENT)
  if false == result and bToast then
    Toast(textRes.NewTerm.FEATRUE_IDIP_NOT_OPEN)
  end
  return result
end
def.method("=>", "boolean").NeedReddot = function(self)
  return false
end
return NewTermModule.Commit()
