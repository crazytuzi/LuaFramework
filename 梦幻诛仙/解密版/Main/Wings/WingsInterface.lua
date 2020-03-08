local Lplus = require("Lplus")
local WingsDataMgr = require("Main.Wings.data.WingsDataMgr")
local WingsUtility = require("Main.Wings.WingsUtility")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local WingsViewData = require("Main.Wings.data.WingsViewData")
local WingsInterface = Lplus.Class("WingsInterface")
local def = WingsInterface.define
def.const("table").PropTypeToName = {
  [PropertyType.PHYATK] = "\231\137\169\230\148\187",
  [PropertyType.PHYDEF] = "\231\137\169\233\152\178",
  [PropertyType.MAGATK] = "\230\179\149\230\148\187",
  [PropertyType.MAGDEF] = "\230\179\149\233\152\178",
  [PropertyType.MAX_HP] = "\230\176\148\232\161\128",
  [PropertyType.SPEED] = "\233\128\159\229\186\166"
}
def.static().OpenWingsPanel = function()
  if not WingsDataMgr.Instance():IsWingsFuncUnlocked() then
    Toast(textRes.Wings[2])
    return
  end
  local WingsPanel = require("Main.Wings.ui.WingsPanel")
  WingsPanel.Instance():ShowPanel()
end
def.static("number").OpenWingsPanelToTab = function(nodeId)
  if not WingsDataMgr.Instance():IsWingsFuncUnlocked() then
    Toast(textRes.Wings[2])
    return
  end
  local WingsPanel = require("Main.Wings.ui.WingsPanel")
  WingsPanel.Instance():ShowPanelToTab(nodeId)
end
def.static("=>", "boolean").IsWingsFuncUnlocked = function()
  return WingsDataMgr.Instance():IsWingsFuncUnlocked()
end
def.static("=>", "boolean").IsWingsActivated = function()
  if not WingsInterface.IsWingsFuncUnlocked() then
    return false
  end
  return WingsDataMgr.Instance():GetActiveSchemaIdx() ~= 0
end
def.static("=>", "boolean").IsWingsModelOn = function()
  if not WingsInterface.IsWingsFuncUnlocked() then
    return false
  end
  return WingsInterface.IsWingsActivated() and WingsDataMgr.Instance():GetIsWingsShowing() == 1
end
def.static("=>", "table").GetCurrentWings = function()
  if not WingsInterface.IsWingsModelOn() then
    return {id = 0, dyeId = 0}
  end
  local activeSchema = WingsDataMgr.Instance():GetActiveSchemaIdx()
  local curView = WingsDataMgr.Instance():GetCurrentViewBySchemaIdx(activeSchema)
  return {
    id = curView.modelId,
    dyeId = curView.dyeId
  }
end
def.static("=>", "table").RawGetCurrentwings = function()
  if not WingsInterface.IsWingsActivated() then
    return {id = 0, dyeId = 0}
  end
  local activeSchema = WingsDataMgr.Instance():GetActiveSchemaIdx()
  local curView = WingsDataMgr.Instance():GetCurrentViewBySchemaIdx(activeSchema)
  return {
    id = curView.modelId,
    dyeId = curView.dyeId
  }
end
def.static("=>", "number").GetCurWingsLevel = function()
  if not WingsInterface.IsWingsFuncUnlocked() then
    return 0
  end
  local activeSchema = WingsDataMgr.Instance():GetActiveSchemaIdx()
  return WingsDataMgr.Instance():GetWingsLevelBySchemaIdx(activeSchema)
end
def.static("=>", "number").GetCurWingsPhase = function()
  if not WingsInterface.IsWingsFuncUnlocked() then
    return 0
  end
  local activeSchema = WingsDataMgr.Instance():GetActiveSchemaIdx()
  return WingsDataMgr.Instance():GetWingsPhaseBySchemaIdx(activeSchema)
end
def.static("=>", "number").GetCurWingsItemId = function()
  if not WingsInterface.IsWingsFuncUnlocked() then
    return 0
  end
  if WingsInterface.IsWingsActivated() and not WingsInterface.IsWingsModelOn() then
    return WingsDataMgr.WING_FAKE_ITEM_ID
  end
  local activeSchema = WingsDataMgr.Instance():GetActiveSchemaIdx()
  local curView = WingsDataMgr.Instance():GetCurrentViewBySchemaIdx(activeSchema)
  if not curView then
    return WingsDataMgr.WING_FAKE_ITEM_ID
  end
  local cfg = WingsUtility.GetWingsViewCfg(curView.modelId)
  if not cfg then
    return WingsDataMgr.WING_FAKE_ITEM_ID
  end
  return cfg.fakeItemId
end
def.static("table", "=>", "number").GetWingsItemIdByWingsData = function(wingsData)
  local curView = wingsData.curWingsView
  if not curView then
    return WingsDataMgr.WING_FAKE_ITEM_ID
  end
  local cfg = WingsUtility.GetWingsViewCfg(curView.modelId)
  if not cfg then
    return WingsDataMgr.WING_FAKE_ITEM_ID
  end
  return cfg.fakeItemId
end
def.static("=>", "table").GetCurWingsSchema = function()
  local activeSchemaId = WingsDataMgr.Instance():GetActiveSchemaIdx()
  if activeSchemaId <= 0 then
    return nil
  end
  return WingsDataMgr.Instance():GetWingsSchemaByIdx(activeSchemaId)
end
def.static("=>", "number").GetCurWingsSchemaId = function()
  return WingsDataMgr.Instance():GetActiveSchemaIdx()
end
def.static("=>", "table").GetCurWingsProperties = function()
  local activeSchema = WingsInterface.GetCurWingsSchema()
  if not activeSchema then
    return nil
  end
  local rawProps = activeSchema.propList
  return WingsInterface.ConvertRawProperties(rawProps)
end
def.static("table", "=>", "table").ConvertRawProperties = function(rawProps)
  if not rawProps then
    return nil
  end
  local propMap = WingsDataMgr.PropListToMap(rawProps)
  local propList = {}
  for i = 1, WingsDataMgr.WING_PROPERTY_NUM do
    local prop = {}
    local rawPropItem = propMap[WingsUtility.PropSeq[i]]
    prop.name = WingsInterface.PropTypeToName[WingsUtility.PropSeq[i]]
    prop.value = rawPropItem.value
    prop.phase = rawPropItem.phase
    table.insert(propList, prop)
  end
  return propList
end
def.static("=>", "table").GetCurWingsSkills = function()
  local activeSchema = WingsInterface.GetCurWingsSchema()
  if not activeSchema then
    return nil
  end
  local rawSkills = activeSchema.skillList
  return WingsInterface.ConvertRawSkills(rawSkills)
end
def.static("table", "=>", "table").ConvertRawSkills = function(rawSkills)
  if not rawSkills then
    return nil
  end
  local skillList = {}
  for i = 1, #rawSkills do
    local skill = {}
    skill.id = rawSkills[i].mainSkillId
    skill.subIds = rawSkills[i].subSkillIds
    table.insert(skillList, skill)
  end
  return skillList
end
def.static().OpenWingsViewPanel = function()
  if not WingsDataMgr.Instance():IsWingsFuncUnlocked() then
    Toast(textRes.Wings[2])
    return
  end
  local openIndex = WingsDataMgr.Instance():GetActiveSchemaIdx()
  if openIndex == 0 then
    openIndex = WingsDataMgr.Instance():GetCurrentSchemaIdx()
  end
  require("Main.Wings.WingsModule").Instance():ReqAllWingsViews(openIndex)
end
return WingsInterface.Commit()
