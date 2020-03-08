local Lplus = require("Lplus")
local BuffData = require("Main.Buff.data.BuffData")
local SystemBuffData = Lplus.Extend(BuffData, "SystemBuffData")
local def = SystemBuffData.define
local EffectType = require("consts.mzm.gsp.buff.confbean.EffectType")
local BuffInfo = require("netio.protocol.mzm.gsp.buff.BuffInfo")
local BuffUtility = require("Main.Buff.BuffUtility")
local BuffMgr = Lplus.ForwardDeclare("BuffMgr")
def.field("table").cfgData = nil
def.field("table").idipBuffInfo = nil
def.method("table").RawSet = function(self, data)
  self.id = data.buffId
  self.remainValue = data.typeValue
  self.idipBuffInfo = data.idipBuffInfo or {}
end
def.method("=>", "table").GetCfgData = function(self)
  if self.cfgData == nil then
    self.cfgData = BuffUtility.GetBuffCfg(self.id)
  end
  return self.cfgData
end
def.override("=>", "number").GetIcon = function(self)
  local buffCfgData = self:GetCfgData()
  return buffCfgData and buffCfgData.icon
end
def.override("=>", "string").GetName = function(self)
  local buffCfgData = self:GetCfgData()
  if buffCfgData.effectType == EffectType.STATE_IDIP then
    local rateStr = tostring(self:GetIDIPBuffRate())
    local name = string.format(buffCfgData.name, rateStr)
    return name
  else
    return buffCfgData.name
  end
end
def.override("=>", "string").GetDescription = function(self)
  local buffCfgData = self:GetCfgData()
  if buffCfgData.effectType == EffectType.STATE_IDIP then
    local rateStr = tostring(self:GetIDIPBuffRate())
    local desc = string.format(buffCfgData.desc, rateStr)
    return desc
  else
    return buffCfgData.desc
  end
end
def.override("=>", "string").GetStateDescription = function(self)
  local buffCfgData = self:GetCfgData()
  local effectType = buffCfgData.effectType
  local formatText = ""
  if effectType == EffectType.TIME then
    local formatTime = self:GetFormatIntervalTime(self.remainValue)
    if formatTime ~= "" then
      formatText = string.format(textRes.Buff[19], textRes.Buff.EffectType[buffCfgData.effectType], formatTime)
    end
  elseif effectType == EffectType.AFTER_FIGHT or effectType == EffectType.AFTER_DIED then
    formatText = string.format(textRes.Buff[19], textRes.Buff.EffectType[buffCfgData.effectType], tostring(self.remainValue))
  elseif effectType == EffectType.STATE_IDIP then
    local endTime = self.idipBuffInfo[BuffInfo.TIME] or Int64.new(0)
    local formatTime = self:GetFormatIntervalTime(endTime)
    if formatTime ~= "" then
      formatText = string.format(textRes.Buff[19], textRes.Buff.EffectType[2], formatTime)
    end
  elseif effectType == 0 then
    formatText = buffCfgData.consumeText
  else
    formatText = buffCfgData.stateBuffStr or ""
  end
  return formatText
end
def.method("=>", "number").GetIDIPBuffRate = function(self)
  local param = self.idipBuffInfo[BuffInfo.RATE] or Int64.new(0)
  param = Int64.ToNumber(param)
  local rate = param / _G.NUMBER_WAN
  return rate
end
def.method("userdata", "=>", "string").GetFormatIntervalTime = function(self, endTime)
  if endTime < Int64.new(0) then
    return ""
  end
  local now = _G.GetServerTime()
  local interval = Int64.ToNumber(endTime - now)
  if interval < 0 then
    interval = 0
  end
  if interval < 60 then
    return string.format(textRes.Buff[4], interval)
  elseif interval < 3600 then
    return string.format(textRes.Buff[5], interval / 60)
  elseif interval < 86400 then
    return string.format(textRes.Buff[6], interval / 60 / 60, interval / 60 % 60)
  else
    return string.format(textRes.Buff[7], interval / 60 / 60 / 24, interval / 60 / 60 % 24)
  end
end
def.override("=>", "boolean").CanDelete = function(self)
  local buffCfgData = self:GetCfgData()
  return buffCfgData.canDelete == true
end
def.override().OnDelete = function(self)
  local buffCfgData = self:GetCfgData()
  local buffName = self:GetName()
  local desc = string.format(textRes.Buff[18], buffName)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.Common[8], desc, function(s)
    if s == 1 then
      BuffMgr.Instance():CRemoveBuff(self.id)
    end
  end, nil)
end
def.override("=>", "boolean").NeedTickStateDescription = function(self)
  local buffCfgData = self:GetCfgData()
  if buffCfgData and buffCfgData.effectType == EffectType.TIME then
    return true
  end
  return false
end
def.final(SystemBuffData, SystemBuffData, "=>", "boolean").CompareOrder = function(left, right)
  local leftBuffCfgData = left:GetCfgData()
  local rightBuffCfgData = right:GetCfgData()
  if leftBuffCfgData.buffStateType == rightBuffCfgData.buffStateType then
    return left.id < right.id
  else
    return leftBuffCfgData.buffStateType < rightBuffCfgData.buffStateType
  end
end
def.override("=>", "boolean").IsSystemBuff = function(self)
  return true
end
def.override("=>", "boolean").IsNearlyDisappear = function(self)
  local buffCfgData = self:GetCfgData()
  if buffCfgData.effectType ~= 0 and buffCfgData.vanishTip == 0 then
    return false
  end
  if buffCfgData.effectType == EffectType.TIME then
    local endTime = self.remainValue
    local curTime = _G.GetServerTime()
    local intervalSeconds = Int64.ToNumber(endTime - curTime)
    if intervalSeconds <= 0 then
      return true
    end
    local sleepSeconds = intervalSeconds - buffCfgData.vanishTip
    if sleepSeconds <= 0 then
      return true
    end
  elseif buffCfgData.effectType == EffectType.AFTER_FIGHT and Int64.ge(buffCfgData.vanishTip, self.remainValue) then
    return true
  end
  return false
end
def.override("=>", "boolean").NeedAniOnAdd = function(self)
  local buffCfgData = self:GetCfgData()
  if buffCfgData == nil then
    return false
  end
  return buffCfgData.showAppearAnimation
end
return SystemBuffData.Commit()
