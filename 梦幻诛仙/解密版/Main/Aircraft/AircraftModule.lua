local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local AircraftData = require("Main.Aircraft.data.AircraftData")
local AircraftModule = Lplus.Extend(ModuleBase, "AircraftModule")
local instance
local def = AircraftModule.define
def.static("=>", AircraftModule).Instance = function()
  if instance == nil then
    instance = AircraftModule()
  end
  return instance
end
def.field("boolean")._bReddot = false
def.override().Init = function(self)
  ModuleBase.Init(self)
  require("Main.Aircraft.AircraftProtocols").RegisterProtocols()
  require("Main.Aircraft.AircraftMgr").Instance():Init()
  AircraftData.Instance():Init()
end
def.method("boolean", "=>", "boolean").IsOpen = function(self, bToast)
  local result = true
  if false == self:IsFeatrueOpen(bToast) then
    result = false
  elseif false == self:ReachMinLevel(bToast) then
    result = false
  end
  return result
end
def.method("boolean", "=>", "boolean").IsFeatrueOpen = function(self, bToast)
  local result = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_AIRCRAFT)
  if false == result and bToast then
    Toast(textRes.Aircraft.FEATRUE_IDIP_NOT_OPEN)
  end
  return result
end
def.method("boolean", "=>", "boolean").ReachMinLevel = function(self, needToast)
  local result = false
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp ~= nil then
    local rolelevel = heroProp.level
    result = rolelevel >= constant.CFeijianConsts.fei_jian_open_level
  end
  if needToast and false == result then
    Toast(string.format(textRes.Aircraft.NOT_OPEN_LOW_LEVEL, constant.CFeijianConsts.fei_jian_open_level))
  end
  return result
end
def.method("boolean").SetReddot = function(self, value)
  if self._bReddot ~= value then
    warn("[AircraftModule:SetReddot] SetReddot:", value)
    self._bReddot = value
    Event.DispatchEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionNotifyChanged, nil)
  end
end
def.method("=>", "boolean").NeedReddot = function(self)
  return self:IsOpen(false) and self._bReddot
end
return AircraftModule.Commit()
