local Lplus = require("Lplus")
local ChildAssignPropMgr = Lplus.Class("ChildAssignPropMgr")
local def = ChildAssignPropMgr.define
local QualityType = require("consts.mzm.gsp.children.confbean.QualityType")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
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
def.const("table").secondPropQualityMap = {
  maxHp = QualityType.HP_APT,
  maxMp = nil,
  phyAtk = QualityType.PHYATK_APT,
  phyDef = QualityType.PHYDEF_APT,
  magAtk = QualityType.MAGATK_APT,
  magDef = QualityType.MAGDEF_APT,
  speed = QualityType.SPEED_APT
}
def.field("table").propTransCfgCatched = nil
local instance
def.static("=>", ChildAssignPropMgr).Instance = function()
  if instance == nil then
    instance = ChildAssignPropMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method("userdata", "string").IncBaseProp = function(self, childId, attr)
  local child = ChildrenDataMgr.Instance():GetChildById(childId)
  local scheme = child.assignPropScheme
  local manualAssigning = scheme:GetManualAssigning()
  if scheme.manualAssignedPoint >= scheme.potentialPoint then
    return
  end
  manualAssigning[attr] = manualAssigning[attr] + 1
  scheme.manualAssignedPoint = scheme.manualAssignedPoint + 1
  self:CalcSecondProp(child)
end
def.method("userdata", "string").DecBaseProp = function(self, childId, attr)
  local child = ChildrenDataMgr.Instance():GetChildById(childId)
  local scheme = child.assignPropScheme
  local manualAssigning = scheme:GetManualAssigning()
  if manualAssigning[attr] <= 0 then
    return
  end
  manualAssigning[attr] = manualAssigning[attr] - 1
  scheme.manualAssignedPoint = scheme.manualAssignedPoint - 1
  self:CalcSecondProp(child)
end
def.method("userdata", "string", "number", "=>", "number").SetBaseProp = function(self, childId, propName, value)
  local child = ChildrenDataMgr.Instance():GetChildById(childId)
  local scheme = child.assignPropScheme
  local manualAssigning = scheme:GetManualAssigning()
  local actualValue = value
  local preValue = scheme.manualAssigning[propName]
  if scheme.manualAssignedPoint + value - preValue > scheme.potentialPoint then
    actualValue = scheme.potentialPoint - scheme.manualAssignedPoint + preValue
  end
  scheme.manualAssigning[propName] = actualValue
  scheme.manualAssignedPoint = scheme.manualAssignedPoint + scheme.manualAssigning[propName] - preValue
  self:CalcSecondProp(child)
  return actualValue
end
def.method("userdata", "=>", "number").GetUnusedPotentialPointNum = function(self, childId)
  local child = ChildrenDataMgr.Instance():GetChildById(childId)
  return child.assignPropScheme.potentialPoint - child.assignPropScheme.manualAssignedPoint
end
def.method("table").CalcSecondProp = function(self, child)
  self:CalcPropAddon(child)
  local scheme = child.assignPropScheme
  local petQuality = pet.petQuality
  for secondKey, _ in pairs(ChildAssignPropMgr.secondPropMap) do
    scheme.secondPropPreview[secondKey] = 0
  end
  for baseKey, baseIndex in pairs(ChildAssignPropMgr.basePropMap) do
    for secondKey, secondIndex in pairs(ChildAssignPropMgr.secondPropMap) do
      local qualityType = ChildAssignPropMgr.secondPropQualityMap[secondKey]
      local transformValue = self:GetTransformValue(baseKey, secondKey)
      local qualityValue = 1
      if qualityType then
        qualityValue = petQuality:GetQuality(qualityType)
      end
      local secondPropValue = scheme.manualAssigning[baseKey] * transformValue * childId.growValue
      scheme.secondPropPreview[secondKey] = scheme.secondPropPreview[secondKey] + secondPropValue
    end
  end
  for secondKey, secondIndex in pairs(ChildAssignPropMgr.secondPropMap) do
    scheme.secondPropPreview[secondKey] = require("Common.MathHelper").Round(scheme.secondPropPreview[secondKey])
  end
end
def.method("table").CalcPropAddon = function(self, child)
  local scheme = child.assignPropScheme
  scheme.secondPropPreview = scheme.secondPropPreview or HeroSecondProp()
  for secondKey, secondIndex in pairs(ChildAssignPropMgr.secondPropMap) do
    local addon = 0
    for baseKey, baseIndex in pairs(ChildAssignPropMgr.basePropMap) do
      local transformValue = self:GetTransformValue(baseKey, secondKey)
      local pre = child.baseProp[baseKey] * transformValue
      addon = addon + pre
    end
    addon = addon - require("Common.MathHelper").Floor(addon)
    scheme.secondPropPreview[secondKey] = addon
  end
end
def.method("string", "string", "=>", "number").GetTransformValue = function(self, baseKey, secondKey)
  if self.propTransCfgCatched == nil then
    self.propTransCfgCatched = self:GetChildPropTransCfg()
  end
  local selectedBase = ChildAssignPropMgr.basePropMap[baseKey]
  local selectedSecond = ChildAssignPropMgr.secondPropMap[secondKey]
  local propKey = self:GenPropKey(selectedBase, selectedSecond)
  local value
  if self.propTransCfgCatched[propKey] then
    value = self.propTransCfgCatched[propKey].bp2fpFactor
  else
    value = 0
  end
  return value
end
def.method("userdata", "string").IncBasePropPrefab = function(self, childId, attr)
  local child = ChildrenDataMgr.Instance():GetChildById(childId)
  local scheme = child.assignPropScheme
  local autoAssigning = scheme:GetAutoAssigning()
  if scheme.autoAssignedPoint >= scheme.autoAssignPointLimit then
    return
  end
  autoAssigning[attr] = autoAssigning[attr] + 1
  scheme.autoAssignedPoint = scheme.autoAssignedPoint + 1
end
def.method("userdata", "string").DecBasePropPrefab = function(self, childId, attr)
  local child = ChildrenDataMgr.Instance():GetChildById(childId)
  local scheme = child.assignPropScheme
  local autoAssigning = scheme:GetAutoAssigning()
  if autoAssigning[attr] <= 0 then
    return
  end
  autoAssigning[attr] = autoAssigning[attr] - 1
  scheme.autoAssignedPoint = scheme.autoAssignedPoint - 1
end
def.method("userdata", "string", "number", "=>", "number").SetBasePropSetting = function(self, childId, propName, value)
  local child = ChildrenDataMgr.Instance():GetChildById(childId)
  local scheme = child.assignPropScheme
  local autoAssigning = scheme:GetAutoAssigning()
  local actualValue = value
  local preValue = scheme.autoAssigning[propName]
  if scheme.autoAssignedPoint + value - preValue > scheme.autoAssignPointLimit then
    actualValue = scheme.autoAssignPointLimit - scheme.autoAssignedPoint + preValue
  end
  scheme.autoAssigning[propName] = actualValue
  scheme.autoAssignedPoint = scheme.autoAssignedPoint + scheme.autoAssigning[propName] - preValue
  return actualValue
end
def.method("userdata", "=>", "number").GetUnusedPrefabPointNum = function(self, childId)
  local child = ChildrenDataMgr.Instance():GetChildById(childId)
  return child.assignPropScheme.autoAssignPointLimit - child.assignPropScheme.autoAssignedPoint
end
def.method("userdata", "number").ResetPotentialPoint = function(self, childId, itemNum)
  local ItemModule = require("Main.Item.ItemModule")
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  self:C2S_ResetPotentialPoint(childId, itemNum, yuanBaoNum)
end
def.method("userdata").SaveAssignedProp = function(self, childId)
  local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
  local child = ChildrenDataMgr.Instance():GetChildById(childId)
  local manualAssigning = child.assignPropScheme:GetManualAssigning()
  local assignPropMap = {
    [PropertyType.STR] = manualAssigning.str,
    [PropertyType.DEX] = manualAssigning.dex,
    [PropertyType.CON] = manualAssigning.con,
    [PropertyType.STA] = manualAssigning.sta,
    [PropertyType.SPR] = manualAssigning.spi
  }
  self:C2S_AssignProp(childId, assignPropMap)
end
def.method("userdata").SaveAssignedPropPrefab = function(self, childId)
  local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
  local child = ChildrenDataMgr.Instance():GetChildById(childId)
  local autoAssigning = child.assignPropScheme:GetAutoAssigning()
  local assignPropMap = {
    [PropertyType.STR] = autoAssigning.str,
    [PropertyType.DEX] = autoAssigning.dex,
    [PropertyType.CON] = autoAssigning.con,
    [PropertyType.STA] = autoAssigning.sta,
    [PropertyType.SPR] = autoAssigning.spi
  }
  self:C2S_AssignPrefab(childId, assignPropMap)
end
def.method("userdata").ToggleAutoAssignState = function(self, childId)
  local child = ChildrenDataMgr.Instance():GetChildById(childId)
  local scheme = child.assignPropScheme
  local targetState = not scheme.isEnableAutoAssign
  self:EnableAutoAssign(targetState)
end
def.method("userdata", "boolean").EnableAutoAssign = function(self, childId, isEnable)
  local child = ChildrenDataMgr.Instance():GetChildById(childId)
  local scheme = child.assignPropScheme
  if scheme.isEnableAutoAssign == isEnable then
    return
  end
  local stateValue
  if isEnable then
    stateValue = 1
  else
    stateValue = 0
  end
  self:C2S_SetAutoAssignPropState(childId, stateValue)
end
def.method("table").OnSAutoAddPotentialPrefRes = function(self, data)
  local child = ChildrenDataMgr.Instance():GetChildById(data.childId)
  child.assignPropScheme.autoAssigned.str = data.propMap[PropertyType.STR]
  child.assignPropScheme.autoAssigned.dex = data.propMap[PropertyType.DEX]
  child.assignPropScheme.autoAssigned.con = data.propMap[PropertyType.CON]
  child.assignPropScheme.autoAssigned.sta = data.propMap[PropertyType.STA]
  child.assignPropScheme.autoAssigned.spi = data.propMap[PropertyType.SPR]
  child.assignPropScheme:ResetAutoAssigning()
end
def.method("userdata", "number", "userdata").C2S_ResetPotentialPoint = function(self, childId, itemNum, yuanBaoNum)
  local p = require("netio.protocol.mzm.gsp.children.CResetAddPotentialPrefReq").new(childId, itemNum, yuanBaoNum)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "table").C2S_AssignProp = function(self, childId, propMap)
  local p = require("netio.protocol.mzm.gsp.children.CDiyPotentialReq").new(childId, propMap)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "number").C2S_SetAutoAssignPropState = function(self, childId, state)
  local p = require("netio.protocol.mzm.gsp.children.CSetAutoAddFlag").new(childId, state)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "table").C2S_AssignPrefab = function(self, childId, propMap)
  local p = require("netio.protocol.mzm.gsp.children.CAutoAddPotentialPrefReq").new(childId, propMap)
  gmodule.network.sendProtocol(p)
end
def.method("=>", "table").GetChildPropTransCfg = function(self)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILD_PROP_TRANS_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgList = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = {}
    cfg.templateId = DynamicRecord.GetIntValue(entry, "templateId")
    cfg.basePropType = DynamicRecord.GetIntValue(entry, "basePropType")
    cfg.fightPropType = DynamicRecord.GetIntValue(entry, "fightPropType")
    cfg.bp2fpFactor = DynamicRecord.GetFloatValue(entry, "bp2fpFactor")
    cfg.templateName = DynamicRecord.GetStringValue(entry, "templateName")
    local propKey = self:GenPropKey(cfg.basePropType, cfg.fightPropType)
    cfgList[propKey] = cfg
  end
  return cfgList
end
def.method("number", "number", "=>", "number").GenPropKey = function(self, basePropType, secondPropType)
  return basePropType * 10000 + secondPropType
end
return ChildAssignPropMgr.Commit()
