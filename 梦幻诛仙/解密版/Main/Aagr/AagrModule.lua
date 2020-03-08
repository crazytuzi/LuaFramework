local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local AagrModule = Lplus.Extend(ModuleBase, "AagrModule")
local instance
local def = AagrModule.define
def.static("=>", AagrModule).Instance = function()
  if instance == nil then
    instance = AagrModule()
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  require("Main.Aagr.data.AagrData").Instance():Init()
  require("Main.Aagr.AagrProtocols").RegisterProtocols()
  require("Main.Aagr.AagrMgr").Instance():Init()
end
def.method("boolean", "=>", "boolean").IsOpen = function(self, bToast)
  local result = true
  if false == self:IsFeatrueOpen(bToast) then
    result = false
  end
  return result
end
def.method("boolean", "=>", "boolean").IsFeatrueOpen = function(self, bToast)
  local result = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BALL_BATTLE)
  if false == result and bToast then
    Toast(textRes.Aagr.FEATRUE_IDIP_NOT_OPEN)
  end
  return result
end
def.method("=>", "boolean").NeedReddot = function(self)
  return self:IsOpen(false)
end
return AagrModule.Commit()
