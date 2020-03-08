local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
require("Main.module.ModuleId")
local OracleData = require("Main.Oracle.data.OracleData")
local OracleMgr = require("Main.Oracle.OracleMgr")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local OracleModule = Lplus.Extend(ModuleBase, "OracleModule")
local def = OracleModule.define
local instance
def.static("=>", OracleModule).Instance = function()
  if instance == nil then
    instance = OracleModule()
    instance.m_moduleId = ModuleId.ORACLE
  end
  return instance
end
def.field(OracleData)._oracleData = nil
def.override().Init = function(self)
  self._oracleData = OracleData.Instance()
  self._oracleData:Init()
  OracleMgr.Instance():Init()
  require("Main.Oracle.OracleProtocols").RegisterEvents()
  ModuleBase.Init(self)
end
def.method("boolean", "=>", "boolean").IsOpen = function(self, bToast)
  local result = true
  if not self:IsFeatureOpen(bToast) then
    result = false
  elseif not self:IsConditionSatisfied(bToast) then
    result = false
  end
  return result
end
def.method("boolean", "=>", "boolean").IsFeatureOpen = function(self, bToast)
  local open = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_GENIUS)
  if bToast and false == open then
    Toast(textRes.Oracle.FEATRUE_IDIP_NOT_OPEN)
  end
  return open
end
def.method("boolean", "=>", "boolean").IsConditionSatisfied = function(self, bToast)
  local result = true
  local rolelevel = require("Main.Hero.Interface").GetHeroProp().level
  result = rolelevel >= constant.COracleConsts.OPEN_LEVEL
  if bToast and false == result then
    Toast(string.format(textRes.Oracle.FEATRUE_NOT_OPEN_LOW_LEVEL, constant.COracleConsts.OPEN_LEVEL))
  end
  return result
end
def.method("=>", "boolean").NeedReddot = function(self)
  if self:IsOpen(false) then
    local restPoints = self._oracleData:GetRestPoints()
    return restPoints > 0
  else
    return false
  end
end
def.method("=>", "boolean").IsDoubleOracle = function(self)
  local open = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_DOUBLE_GENIUS_SERIES)
  return open
end
OracleModule.Commit()
return OracleModule
