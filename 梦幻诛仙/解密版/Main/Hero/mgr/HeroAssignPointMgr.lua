local Lplus = require("Lplus")
local HeroAssignPointMgr = Lplus.Class("HeroAssignPointMgr")
local def = HeroAssignPointMgr.define
local instance
local HeroBaseProp = Lplus.ForwardDeclare("HeroBaseProp")
local HeroSecondProp = Lplus.ForwardDeclare("HeroSecondProp")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local HeroUtility = require("Main.Hero.HeroUtility")
local HeroPropMgr = Lplus.ForwardDeclare("HeroPropMgr")
def.field("table").transformValueCached = nil
def.field("table").assignPointSchemes = nil
def.field("number").enabledSchemeIndex = 0
def.const("table").basePropMap = {
  str = PropertyType.STR,
  dex = PropertyType.DEX,
  con = PropertyType.CON,
  sta = PropertyType.STA,
  spi = PropertyType.SPR
}
def.const("table").secondPropMap = {
  maxHp = PropertyType.MAX_HP,
  maxMp = PropertyType.MAX_MP,
  phyAtk = PropertyType.PHYATK,
  phyDef = PropertyType.PHYDEF,
  magAtk = PropertyType.MAGATK,
  magDef = PropertyType.MAGDEF,
  speed = PropertyType.SPEED
}
def.static("=>", HeroAssignPointMgr).Instance = function()
  if instance == nil then
    instance = HeroAssignPointMgr()
  end
  return instance
end
def.method("=>", "boolean").IsUnlock = function(self)
  local assignPropMinLevel = HeroUtility.Instance():GetRoleCommonConsts("ADD_POTEN_FUNC_LEVEL")
  local heroProp = HeroPropMgr.Instance():GetHeroProp()
  if assignPropMinLevel > heroProp.level then
    return false
  end
  return true
end
def.method("number", "string").IncBaseProp = function(self, schemeIdx, propName)
  if schemeIdx ~= self.enabledSchemeIndex then
    return
  end
  local scheme = self.assignPointSchemes[schemeIdx]
  scheme.manualAssigning = scheme.manualAssigning or HeroBaseProp()
  if scheme.manualAssignedPoint >= scheme.potentialPoint then
    return
  end
  scheme.manualAssigning[propName] = scheme.manualAssigning[propName] + 1
  scheme.manualAssignedPoint = scheme.manualAssignedPoint + 1
  self:CalcSecondProp(scheme)
end
def.method("number", "string").DecBaseProp = function(self, schemeIdx, propName)
  if schemeIdx ~= self.enabledSchemeIndex then
    return
  end
  local scheme = self.assignPointSchemes[schemeIdx]
  scheme.manualAssigning = scheme.manualAssigning or HeroBaseProp()
  if scheme.manualAssigning[propName] == 0 then
    return
  end
  scheme.manualAssigning[propName] = scheme.manualAssigning[propName] - 1
  scheme.manualAssignedPoint = scheme.manualAssignedPoint - 1
  self:CalcSecondProp(scheme)
end
def.method("number", "string", "number", "=>", "number").SetBaseProp = function(self, schemeIdx, propName, value)
  if schemeIdx ~= self.enabledSchemeIndex then
    return 0
  end
  local scheme = self.assignPointSchemes[schemeIdx]
  scheme.manualAssigning = scheme.manualAssigning or HeroBaseProp()
  local actualValue = value
  local preValue = scheme.manualAssigning[propName]
  if scheme.manualAssignedPoint + value - preValue > scheme.potentialPoint then
    actualValue = scheme.potentialPoint - scheme.manualAssignedPoint + preValue
  end
  scheme.manualAssigning[propName] = actualValue
  scheme.manualAssignedPoint = scheme.manualAssignedPoint + scheme.manualAssigning[propName] - preValue
  self:CalcSecondProp(scheme)
  return actualValue
end
def.method("number", "=>", "number").GetUnusedPotentialPointAmount = function(self, schemeIdx)
  local scheme = self.assignPointSchemes[schemeIdx]
  return scheme.potentialPoint - scheme.manualAssignedPoint
end
def.method("number").SaveManualAssign = function(self, schemeIdx)
  local scheme = self.assignPointSchemes[schemeIdx]
  if scheme.manualAssigning == nil then
    return
  end
  self:C2S_AssignPoint(schemeIdx, scheme.manualAssigning)
  scheme:SaveManualAssign()
end
def.method("number").ClearManualAssign = function(self, schemeIdx)
  local scheme = self.assignPointSchemes[schemeIdx]
  scheme:Clear()
  self.transformValueCached = nil
end
def.method("number", "table").ResetAssignedPoint = function(self, schemeIdx, extraParams)
  local scheme = self.assignPointSchemes[schemeIdx]
  local ItemModule = require("Main.Item.ItemModule")
  local yuanBaoAmount = ItemModule.Instance():GetAllYuanBao()
  local intIsUseYuanBao = extraParams.isYuanBaoBuZu == true and 1 or 0
  self:C2S_ResetAssignedPoint(schemeIdx, yuanBaoAmount, intIsUseYuanBao)
  scheme:Clear()
end
def.method("table").CalcSecondProp = function(self, scheme)
  self:CalcPropAddon(scheme)
  for baseKey, baseIndex in pairs(HeroAssignPointMgr.basePropMap) do
    for secondKey, secondIndex in pairs(HeroAssignPointMgr.secondPropMap) do
      local transformValue = self:GetTransformValue(baseKey, secondKey)
      local secondPropValue = scheme.manualAssigning[baseKey] * transformValue
      scheme.secondPropPreview[secondKey] = scheme.secondPropPreview[secondKey] + secondPropValue
    end
  end
  for secondKey, secondIndex in pairs(HeroAssignPointMgr.secondPropMap) do
    scheme.secondPropPreview[secondKey] = require("Common.MathHelper").Floor(scheme.secondPropPreview[secondKey])
  end
end
def.method("table").CalcPropAddon = function(self, scheme)
  scheme.secondPropPreview = scheme.secondPropPreview or HeroSecondProp()
  for secondKey, secondIndex in pairs(HeroAssignPointMgr.secondPropMap) do
    local addon = 0
    for baseKey, baseIndex in pairs(HeroAssignPointMgr.basePropMap) do
      local transformValue = self:GetTransformValue(baseKey, secondKey)
      local pre = scheme.totalBaseProp[baseKey] * transformValue
      addon = addon + pre
    end
    addon = addon - require("Common.MathHelper").Floor(addon)
    scheme.secondPropPreview[secondKey] = addon
  end
end
def.method("string", "string", "=>", "number").GetTransformValue = function(self, baseKey, secondKey)
  if self.transformValueCached == nil then
    self:LoadTransformValue()
  end
  local selectedBase = HeroAssignPointMgr.basePropMap[baseKey]
  local selectedSecond = HeroAssignPointMgr.secondPropMap[secondKey]
  local propKey = self:GenPropKey(selectedBase, selectedSecond)
  return self.transformValueCached[propKey]
end
def.method().LoadTransformValue = function(self)
  if self.transformValueCached ~= nil then
    return
  end
  self.transformValueCached = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PROPERTY_TRANSFORM_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  for baseKey, baseIndex in pairs(HeroAssignPointMgr.basePropMap) do
    for secondKey, secondIndex in pairs(HeroAssignPointMgr.secondPropMap) do
      local propKey = self:GenPropKey(baseIndex, secondIndex)
      self.transformValueCached[propKey] = 0
    end
  end
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local base = DynamicRecord.GetIntValue(entry, "baseProp")
    local fight = DynamicRecord.GetIntValue(entry, "fightProp")
    local propKey = self:GenPropKey(base, fight)
    if self.transformValueCached[propKey] ~= nil then
      local transformValue = DynamicRecord.GetDoubleValue(entry, "transformValue")
      self.transformValueCached[propKey] = transformValue
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("number", "number", "=>", "number").GenPropKey = function(self, baseIndex, secondIndex)
  return secondIndex * 100 + baseIndex
end
def.method("number", "string").IncBasePropSetting = function(self, schemeIdx, propName)
  if schemeIdx ~= self.enabledSchemeIndex then
    return
  end
  local scheme = self.assignPointSchemes[schemeIdx]
  scheme.autoAssigning = scheme.autoAssigning or HeroBaseProp()
  if scheme.autoAssignedPoint >= scheme.autoAssignPointLimit then
    return
  end
  scheme.autoAssigning[propName] = scheme.autoAssigning[propName] + 1
  scheme.autoAssignedPoint = scheme.autoAssignedPoint + 1
end
def.method("number", "string").DecBasePropSetting = function(self, schemeIdx, propName)
  if schemeIdx ~= self.enabledSchemeIndex then
    return
  end
  local scheme = self.assignPointSchemes[schemeIdx]
  scheme.autoAssigning = scheme.autoAssigning or HeroBaseProp()
  if scheme.autoAssigning[propName] <= 0 then
    return
  end
  scheme.autoAssigning[propName] = scheme.autoAssigning[propName] - 1
  scheme.autoAssignedPoint = scheme.autoAssignedPoint - 1
end
def.method("number", "string", "number", "=>", "number").SetBasePropSetting = function(self, schemeIdx, propName, value)
  if schemeIdx ~= self.enabledSchemeIndex then
    return 0
  end
  local scheme = self.assignPointSchemes[schemeIdx]
  scheme.autoAssigning = scheme.autoAssigning or HeroBaseProp()
  local actualValue = value
  local preValue = scheme.autoAssigning[propName]
  if scheme.autoAssignedPoint + value - preValue > scheme.autoAssignPointLimit then
    actualValue = scheme.autoAssignPointLimit - scheme.autoAssignedPoint + preValue
  end
  scheme.autoAssigning[propName] = actualValue
  scheme.autoAssignedPoint = scheme.autoAssignedPoint + scheme.autoAssigning[propName] - preValue
  return actualValue
end
def.method("number", "=>", "number").GetUnusedAutoAssignPointAmount = function(self, schemeIdx)
  if schemeIdx ~= self.enabledSchemeIndex then
    return
  end
  local scheme = self.assignPointSchemes[schemeIdx]
  scheme:GetAutoAssigning()
  return scheme.autoAssignPointLimit - scheme.autoAssignedPoint
end
def.method("number").SaveAutoAssignSetting = function(self, schemeIdx)
  local scheme = self.assignPointSchemes[schemeIdx]
  if scheme == nil or scheme.autoAssigning == nil then
    return
  end
  self:C2S_SaveAutoAssignPointSetting(schemeIdx, scheme.autoAssigning)
  scheme:SaveAutoAssigning()
end
def.method("number").ClearAutoAssignSetting = function(self, schemeIdx)
  local scheme = self.assignPointSchemes[schemeIdx]
  scheme:ClearAutoAssigning()
end
def.method("number", "boolean").EnableAutoAssignPoint = function(self, schemeIdx, isAuto)
  local scheme = self.assignPointSchemes[schemeIdx]
  self:C2S_EnableAutoAssignPoint(schemeIdx, isAuto)
  scheme:Clear()
end
def.method().ClearAssignPointScheme = function(self)
  self.assignPointSchemes = nil
  self.enabledSchemeIndex = 0
end
def.method("number", "table").AddAssignPointScheme = function(self, schemeId, rawScheme)
  self.assignPointSchemes = self.assignPointSchemes or {}
  local HeroAssignPointScheme = require("Main.Hero.data.HeroAssignPointScheme")
  local obj = HeroAssignPointScheme()
  obj:RawSet(schemeId, rawScheme)
  self.assignPointSchemes[schemeId] = obj
end
def.method("number", "table").UpdateAssignPointScheme = function(self, idx, rawScheme)
  if self.assignPointSchemes == nil or idx < 1 or idx > #self.assignPointSchemes then
    return
  end
  self.assignPointSchemes[idx]:RawSet(rawScheme)
end
def.method("number").EnableAssignPointScheme = function(self, idx)
  local ItemModule = require("Main.Item.ItemModule")
  local moneySilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER) or Int64.new(0)
  self:C2S_EnableAssignPointScheme(idx, moneySilver)
end
def.method("number").SetEnabledSchemeIndex = function(self, index)
  self.enabledSchemeIndex = index
end
def.method("=>", "number").GetEnabledSchemeIndex = function(self)
  return self.enabledSchemeIndex
end
def.method("number", "=>", "table").GetAssignPointScheme = function(self, schemeIdx)
  return self.assignPointSchemes[schemeIdx]
end
def.method("number").ClearChanges = function(self, schemeIdx)
  local scheme = self.assignPointSchemes[schemeIdx]
  scheme:Clear()
end
def.method().ClearCatchedData = function(self)
  self.transformValueCached = nil
end
def.method("number", "=>", "number").GetSchemeUnlockLevel = function(self, schemeIdx)
  local HeroUtility = require("Main.Hero.HeroUtility")
  local constName = string.format("OPEN_POINT_SYS_%d_LEVEL", schemeIdx + 1)
  return HeroUtility.Instance():GetRoleCommonConsts(constName)
end
def.method("number", "userdata").C2S_EnableAssignPointScheme = function(self, schemeId, curMoney)
  local p = require("netio.protocol.mzm.gsp.role.CSwitchPropSysReq").new(schemeId, curMoney)
  gmodule.network.sendProtocol(p)
end
def.method("number", "boolean").C2S_EnableAutoAssignPoint = function(self, schemeId, opt)
  local isAuto
  if opt == true then
    isAuto = 1
  else
    isAuto = 0
  end
  local p = require("netio.protocol.mzm.gsp.role.CSetAutoAssignFuncReq").new(schemeId, isAuto)
  gmodule.network.sendProtocol(p)
end
def.method("number", HeroBaseProp).C2S_AssignPoint = function(self, schemeId, data)
  local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
  local assignPropMap = {
    [PropertyType.STR] = data.str,
    [PropertyType.DEX] = data.dex,
    [PropertyType.CON] = data.con,
    [PropertyType.STA] = data.sta,
    [PropertyType.SPR] = data.spi
  }
  local p = require("netio.protocol.mzm.gsp.role.CAssignPropReq").new(schemeId, assignPropMap)
  gmodule.network.sendProtocol(p)
end
def.method("number", HeroBaseProp).C2S_SaveAutoAssignPointSetting = function(self, schemeId, data)
  local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
  local assignPropMap = {
    [PropertyType.STR] = data.str,
    [PropertyType.DEX] = data.dex,
    [PropertyType.CON] = data.con,
    [PropertyType.STA] = data.sta,
    [PropertyType.SPR] = data.spi
  }
  local p = require("netio.protocol.mzm.gsp.role.CAutoAssignPrefReq").new(schemeId, assignPropMap)
  gmodule.network.sendProtocol(p)
end
def.method("number", "userdata", "number").C2S_ResetAssignedPoint = function(self, schemeId, curYuanBao, isUseYuanBao)
  local p = require("netio.protocol.mzm.gsp.role.CResetRolePropReq").new(isUseYuanBao, schemeId, curYuanBao)
  gmodule.network.sendProtocol(p)
end
def.method("boolean").OnSSetAutoAssignFuncRes = function(self, isAuto)
  local scheme = self.assignPointSchemes[self.enabledSchemeIndex]
  scheme.isEnableAutoAssign = isAuto
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.SAVE_AUTO_ASSIGN_STATE_SUCCESS, {-1})
end
def.method("number", "table").OnSAutoAssignPrefRes = function(self, schemeIdx, propMap)
  local scheme = self.assignPointSchemes[schemeIdx]
  scheme.autoAssigned:RawSet(propMap)
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.SAVE_ASSIGN_RROP_SETTING_SUCCESS, {schemeIdx})
end
def.method("number").OnSSwitchPropSysRes = function(self, schemeIdx)
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.SWITCH_ASSIGN_PROP_SCHEME_SUCCESS, {schemeIdx})
end
HeroAssignPointMgr.Commit()
return HeroAssignPointMgr
