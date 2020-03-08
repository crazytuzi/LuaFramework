local Lplus = require("Lplus")
local WingsUtility = require("Main.Wings.WingsUtility")
local SkillUtility = require("Main.Skill.SkillUtility")
local WingsData = require("Main.Wings.data.WingsData")
local WingsPropData = require("Main.Wings.data.WingsPropData")
local WingsSkillData = require("Main.Wings.data.WingsSkillData")
local WingsViewData = require("Main.Wings.data.WingsViewData")
local WingsDataMgr = Lplus.Class("WingsDataMgr")
local def = WingsDataMgr.define
def.field("boolean").isWingsUnlocked = false
def.field("number").schemaCount = 0
def.field("number").curSchemaIdx = 0
def.field("number").activeSchemaIdx = 0
def.field("number").isShowWings = 1
def.field("table").wingsList = nil
def.field("table").wingsViewList = nil
def.field("table").resetPropList = nil
def.field("table").resetSkillInfo = nil
def.field("table").randomSkillList = nil
def.const("number").MAX_SCHEMA_NUM = WingsUtility.GetWingsConstByName("MAX_SCHEMA_NUM")
def.const("number").WING_PROPERTY_NUM = WingsUtility.GetWingsConstByName("WING_PROPERTY_NUM")
def.const("number").WING_MAIN_SKILL_NUM = 4
def.const("number").WING_SUB_SKILL_NUM = 3
def.const("number").SCHEMA2_NEED_YUANBAO = WingsUtility.GetWingsConstByName("SCHEMA2_NEED_YUANBAO")
def.const("number").SCHEMA3_NEED_YUANBAO = WingsUtility.GetWingsConstByName("SCHEMA3_NEED_YUANBAO")
def.const("number").RESET_WING_YUANBAO_NUM = WingsUtility.GetWingsConstByName("RESET_WING_YUANBAO_NUM")
def.const("number").MIN_ROLE_LEVEL_FOR_WING = WingsUtility.GetWingsConstByName("MIN_ROLE_LEVLE_FOR_WING")
def.const("number").WING_PROPERTY_RESET_ITEM_ID = WingsUtility.GetWingsConstByName("WING_PROPERTY_RESET_ITEM_ID")
def.const("number").WING_PROPERTY_RESET_ITEM_NUM = WingsUtility.GetWingsConstByName("WING_PROPERTY_RESET_ITEM_NUM")
def.const("table").WING_SKILL_OPEN_PHASES_CFG = WingsUtility.GetWingsSkillOpenPhaseCfg()
def.const("number").WING_DYE_ITEM_ID = WingsUtility.GetWingsConstByName("WING_DYE_ITEM_ID")
def.const("number").WING_FAKE_ITEM_ID = WingsUtility.GetWingsConstByName("WING_FAKE_ITEM_ID")
def.const("number").WING_DYE_ITEM_NUM = 1
def.const("number").WING_PHASE_LIMIT = 10
def.const("number").WING_SKILL_TIP_ID = WingsUtility.GetWingsConstByName("WING_DESC_TIP_ID")
def.const("number").WING_PRO_RESET_TIP_ID = WingsUtility.GetWingsConstByName("WING_PRO_RESET_TIP_ID")
def.const("number").WING_UNDERSTAND_TIP_ID = WingsUtility.GetWingsConstByName("WING_UNDERSTAND_TIP_ID")
def.const("number").WING_DYE_TIP_ID = WingsUtility.GetWingsConstByName("WING_DYE_TIP_ID")
def.const("number").MIN_LEVEL_FOR_RESET_PROPERTY = WingsUtility.GetWingsConstByName("MIN_LEVLE_FOR_RESET_PROPERTY")
def.const("number").WING_TASK_GRAPH_ID = WingsUtility.GetWingsConstByName("WING_GRAPH_ID")
local instance
def.static("=>", WingsDataMgr).Instance = function()
  if instance == nil then
    instance = WingsDataMgr()
  end
  return instance
end
def.method().ResetAllStates = function(self)
  self.isWingsUnlocked = false
  self.curSchemaIdx = 0
  self.schemaCount = 0
  self.wingsList = nil
  self.activeSchemaIdx = 0
  self.wingsViewList = nil
  self.isShowWings = 1
  self.resetPropList = nil
  self.randomSkillList = nil
  self.resetSkillInfo = nil
end
def.method().ClearResetPropData = function(self)
  self.resetPropList = {}
end
def.method().ClearRandomSkillData = function(self)
  self.randomSkillList = {}
end
def.method("table").SetAllWingsData = function(self, data)
  self:ResetAllStates()
  if #data.WingList == 0 then
    return
  end
  self.isWingsUnlocked = true
  self.schemaCount = #data.WingList
  if self.schemaCount > WingsDataMgr.MAX_SCHEMA_NUM then
    warn("Wings Schema Count Exceeded Limit!")
  end
  self.activeSchemaIdx = data.curIndex
  if data.curIndex ~= 0 then
    self.curSchemaIdx = data.curIndex
  else
    self.curSchemaIdx = 1
  end
  self.isShowWings = data.isshowwing
  self.wingsList = {}
  for i = 1, self.schemaCount do
    local wingsdata = WingsData()
    wingsdata:RawSet(data.WingList[i], i)
    table.insert(self.wingsList, wingsdata)
  end
end
def.method("table").AppendWingsSchema = function(self, data)
  if not self.isWingsUnlocked then
    self:ResetAllStates()
    self.wingsList = {}
  end
  self.isWingsUnlocked = true
  self.curSchemaIdx = data.openIndex
  self.schemaCount = self.schemaCount + 1
  self.activeSchemaIdx = data.curIndex
  local wingsdata = WingsData()
  wingsdata:RawSet(data.newWingInfo, self.curSchemaIdx)
  table.insert(self.wingsList, wingsdata)
end
def.method("table").SetWingsSchema = function(self, data)
  local schema = self:GetWingsSchemaByIdx(data.index)
  schema:RawSet(data.wingInfo, data.index)
end
def.method("number").TurnOnWingSchema = function(self, idx)
  self.activeSchemaIdx = idx
end
def.method("=>", "boolean").IsCurrentSchemaOn = function(self)
  if not self.isWingsUnlocked then
    return false
  end
  return self.activeSchemaIdx == self.curSchemaIdx
end
def.method("=>", "number").GetActiveSchemaIdx = function(self)
  return self.activeSchemaIdx
end
def.method("table", "boolean").SetPropertyData = function(self, data, isCurrent)
  if not self.isWingsUnlocked then
    return
  end
  local propList
  if not isCurrent then
    self.resetPropList = {}
    if #data.propertyList == 0 then
      return
    end
    propList = self.resetPropList
  else
    local schema = self.wingsList[data.index]
    schema.propList = {}
    propList = schema.propList
  end
  if not propList then
    return
  end
  for i = 1, #data.propertyList do
    local propData = WingsPropData()
    propData:RawSet(data.propertyList[i])
    table.insert(propList, propData)
  end
end
def.method("boolean", "=>", "table").GetPropertyMap = function(self, isCurrent)
  if not self.isWingsUnlocked then
    return nil
  end
  local propList
  if isCurrent then
    propList = self.wingsList[self.curSchemaIdx].propList
  else
    if not self:IsResetPropAvalible() then
      return nil
    end
    propList = self.resetPropList
  end
  return WingsDataMgr.PropListToMap(propList)
end
def.method("=>", "number").GetCurrentWingsPhase = function(self)
  return self:GetWingsPhaseBySchemaIdx(self.curSchemaIdx)
end
def.method("number", "=>", "number").GetWingsPhaseBySchemaIdx = function(self, idx)
  if not self.isWingsUnlocked then
    return 0
  end
  if idx <= 0 or idx > self.schemaCount then
    return 0
  end
  return self.wingsList[idx].phase
end
def.method("number", "number").SetPhaseBySchemaIdx = function(self, idx, phase)
  if not self.isWingsUnlocked then
    return
  end
  if idx <= 0 or idx > self.schemaCount then
    return
  end
  self.wingsList[idx].phase = phase
end
def.method("=>", "number").GetCurrentSchemaIdx = function(self)
  if not self.isWingsUnlocked then
    return 0
  end
  return self.curSchemaIdx
end
def.method("number", "=>", "table").GetWingsSchemaByIdx = function(self, idx)
  if not self.isWingsUnlocked then
    return nil
  end
  if idx <= 0 or idx > self.schemaCount then
    return nil
  end
  return self.wingsList[idx]
end
def.method("=>", "table").GetCurrentWingsSchema = function(self)
  return self:GetWingsSchemaByIdx(self.curSchemaIdx)
end
def.method("number").GetMainSkillCount = function(self)
  if not self.isWingsUnlocked then
    return
  end
  local curSchema = self:GetCurrentWingsSchema()
  return #curSchema.skillList
end
def.method("=>", "table").GetCurrentSkillTable = function(self)
  if not self.isWingsUnlocked then
    return nil
  end
  local skillList = self:GetCurrentWingsSchema().skillList
  return WingsDataMgr.SkillListToTable(skillList)
end
def.method("=>", "table").GetCurrentMainSkillTable = function(self)
  if not self.isWingsUnlocked then
    return nil
  end
  local skillList = self:GetCurrentWingsSchema().skillList
  local mainSkillTable = {}
  for i = 1, WingsDataMgr.WING_MAIN_SKILL_NUM do
    local mainSkill = {}
    if i <= #skillList then
      mainSkill.id = skillList[i].mainSkillId
      mainSkill.cfg = SkillUtility.GetPassiveSkillCfg(mainSkill.id)
    else
      mainSkill.id = 0
      mainSkill.level = 0
      mainSkill.cfg = nil
    end
    table.insert(mainSkillTable, mainSkill)
  end
  return mainSkillTable
end
def.method("=>", "table").GetCurrentSubSkillTable = function(self)
  if not self.isWingsUnlocked then
    return nil
  end
  local skillList = self:GetCurrentWingsSchema().skillList
  local subSkillTable = {}
  for i = 1, WingsDataMgr.WING_MAIN_SKILL_NUM do
    for j = 1, WingsDataMgr.WING_SUB_SKILL_NUM do
      local subSkill = {}
      if i <= #skillList and j <= #skillList[i].subSkillIds then
        subSkill.id = skillList[i].subSkillIds[j]
        subSkill.cfg = SkillUtility.GetPassiveSkillCfg(subSkill.id)
      else
        subSkill.id = 0
        subSkill.cfg = nil
      end
      table.insert(subSkillTable, subSkill)
    end
  end
  return subSkillTable
end
def.method("=>", "boolean").IsResetPropAvalible = function(self)
  if not self.isWingsUnlocked then
    return false
  end
  if not self.resetPropList then
    return false
  end
  if #self.resetPropList == 0 then
    return false
  end
  return true
end
def.method("=>", "boolean").IsWingsFuncUnlocked = function(self)
  return self.isWingsUnlocked
end
def.method("=>", "table").GetCurrentLevelExp = function(self)
  if not self.isWingsUnlocked then
    return nil
  end
  local lvlExp = {}
  lvlExp.level = self.wingsList[self.curSchemaIdx].level
  lvlExp.exp = self.wingsList[self.curSchemaIdx].exp
  return lvlExp
end
def.method("=>", "number").GetCurrentWingsLevel = function(self)
  return self:GetWingsLevelBySchemaIdx(self.curSchemaIdx)
end
def.method("number", "=>", "number").GetWingsLevelBySchemaIdx = function(self, idx)
  if not self.isWingsUnlocked then
    return 0
  end
  if idx <= 0 or idx > self.schemaCount then
    return 0
  end
  return self.wingsList[idx].level
end
def.method("number", "number", "number").SetExpLevelBySchemaIdx = function(self, idx, exp, level)
  if not self.isWingsUnlocked then
    return
  end
  if idx <= 0 or idx > self.schemaCount then
    return
  end
  local schema = self.wingsList[idx]
  schema.exp = exp
  schema.level = level
end
def.method("table").SetRandomSkillTable = function(self, data)
  if not self.isWingsUnlocked then
    return
  end
  self.randomSkillList = {}
  self.randomSkillList.mainSkillId = data.mainSkillId
  self.randomSkillList.subSkillIds = {}
  local numSubSkills = #data.subSkillIds
  for i = 1, numSubSkills do
    table.insert(self.randomSkillList.subSkillIds, data.subSkillIds[i])
  end
end
def.method("=>", "table").GetRandomSkillInfo = function(self)
  if not self.isWingsUnlocked then
    return
  end
  if not self.randomSkillList then
    return nil
  end
  local skillList = {}
  skillList.mainSkillId = self.randomSkillList.mainSkillId
  skillList.mainSkillCfg = nil
  if skillList.mainSkillId ~= 0 then
    skillList.mainSkillCfg = SkillUtility.GetPassiveSkillCfg(skillList.mainSkillId)
  end
  skillList.subSkills = {}
  local numSubSkills = #self.randomSkillList.subSkillIds
  for i = 1, numSubSkills do
    if self.randomSkillList.subSkillIds[i] ~= 0 then
      local subskill = {}
      subskill.Id = self.randomSkillList.subSkillIds[i]
      subskill.Cfg = SkillUtility.GetPassiveSkillCfg(subskill.Id)
      table.insert(skillList.subSkills, subskill)
    end
  end
  return skillList
end
def.method("table").RefreshNewPhaseData = function(self, data)
  if not self.isWingsUnlocked then
    return
  end
  self:SetPhaseBySchemaIdx(data.index, data.phase)
  local newSkillIndex = data.skillIndex
  local skillData = WingsSkillData()
  skillData:RawSet(data.skill)
  local skillList = self:GetWingsSchemaByIdx(data.index).skillList
  if newSkillIndex > #skillList then
    table.insert(skillList, skillData)
  else
    skillList[newSkillIndex] = skillData
  end
  local curView = self:GetWingsSchemaByIdx(data.index).curWingsView
  curView:RawSet(data.modelId2dyeid)
end
def.method("table").RefreshNewLevelData = function(self, data)
  if not self.isWingsUnlocked then
    return
  end
  self:SetExpLevelBySchemaIdx(data.index, data.exp, data.newLevel)
  local propData = {
    index = data.index,
    propertyList = data.propertyList
  }
  self:SetPropertyData(propData, true)
  WingsUtility.ShowGainLevelExpEffect(data.addExp, data.oldLevel, data.newLevel)
end
def.method("number").SwitchSchema = function(self, idx)
  if not self.isWingsUnlocked then
    return
  end
  if idx <= 0 or idx > self.schemaCount then
    return
  end
  self.curSchemaIdx = idx
end
def.method("number", "=>", WingsViewData).GetCurrentViewBySchemaIdx = function(self, idx)
  local schema = self:GetWingsSchemaByIdx(idx)
  if not schema then
    return nil
  end
  if not self.wingsViewList or #self.wingsViewList == 0 then
    return schema.curWingsView
  else
    for i = 1, #self.wingsViewList do
      local wingsView = self.wingsViewList[i]
      if schema.curWingsView.modelId == wingsView.modelId then
        return wingsView
      end
    end
  end
  return schema.curWingsView
end
def.method("=>", WingsViewData).GetCurrentViewOfCurrentSchema = function(self)
  return self:GetCurrentViewBySchemaIdx(self.curSchemaIdx)
end
def.method("=>", "string").GetCurrentModelName = function(self)
  local viewData = self:GetCurrentViewOfCurrentSchema()
  if not viewData then
    return
  end
  local cfg = WingsUtility.GetWingsViewCfg(viewData.modelId)
  if not cfg then
    return ""
  end
  return cfg.name
end
def.method("table").SetWingsViewList = function(self, data)
  if not self.isWingsUnlocked then
    return
  end
  if not data then
    return
  end
  self.wingsViewList = {}
  for i = 1, #data do
    local wingsViewData = WingsViewData()
    wingsViewData:RawSet(data[i])
    table.insert(self.wingsViewList, wingsViewData)
  end
end
def.method("=>", "table").GetWingsViewList = function(self)
  return self.wingsViewList
end
def.method("=>", "number").GetIsWingsShowing = function(self)
  if not self.isWingsUnlocked then
    return 0
  end
  return self.isShowWings
end
def.method("table", "=>", "number").SetWingsDyeRes = function(self, viewData)
  if not self.wingsViewList or #self.wingsViewList == 0 then
    return
  end
  local idx = 0
  for i = 1, #self.wingsViewList do
    local wingsView = self.wingsViewList[i]
    if wingsView.modelId == viewData.modelId then
      wingsView.dyeId = viewData.dyeId
      idx = i
      break
    end
  end
  return idx
end
def.method("number", "number", "table").SetCurrentViewBySchemaIdx = function(self, idx, isShow, viewData)
  if idx <= 0 or idx > self.schemaCount then
    return
  end
  local curView = self.wingsList[idx].curWingsView
  self.isShowWings = isShow
  curView:RawSet(viewData)
end
def.method("=>", "boolean").CheckCanPhaseUp = function(self)
  local curPhase = self:GetCurrentWingsPhase()
  local curLevel = self:GetCurrentWingsLevel()
  local phaseUpCfg = WingsUtility.GetPhaseUpCfg(curPhase)
  if not phaseUpCfg then
    return false
  end
  return curLevel >= phaseUpCfg.needWingLevel
end
def.method("table").ResetOneSkillGroup = function(self, data)
  local skillData = WingsSkillData()
  skillData:RawSet(data.skillresult)
  local skillList = self:GetWingsSchemaByIdx(data.index).skillList
  if #skillList >= data.skillIndex then
    skillList[data.skillIndex] = skillData
  else
    warn("Wrong skill index returned when reseting wings skills")
  end
end
def.static("table", "=>", "table").PropListToMap = function(propList)
  if not propList or #propList ~= WingsDataMgr.WING_PROPERTY_NUM then
    return nil
  end
  local propMap = {}
  for i = 1, WingsDataMgr.WING_PROPERTY_NUM do
    local v = {}
    v.value = propList[i].propValue
    v.phase = propList[i].propPhase
    propMap[propList[i].propType] = v
  end
  return propMap
end
def.static("table", "=>", "table").SkillListToTable = function(skillList)
  if not skillList then
    return nil
  end
  local skillTable = {}
  local mainSkillTable = {}
  for i = 1, WingsDataMgr.WING_MAIN_SKILL_NUM do
    local mainSkill = {}
    if i <= #skillList then
      mainSkill.id = skillList[i].mainSkillId
      mainSkill.cfg = SkillUtility.GetPassiveSkillCfg(mainSkill.id)
    else
      mainSkill.id = 0
      mainSkill.cfg = nilWW
    end
    table.insert(mainSkillTable, mainSkill)
  end
  skillTable.mainSkills = mainSkillTable
  local subSkillTable = {}
  for i = 1, WingsDataMgr.WING_MAIN_SKILL_NUM do
    for j = 1, WingsDataMgr.WING_SUB_SKILL_NUM do
      local subSkill = {}
      if i <= #skillList and j <= #skillList[i].subSkillIds then
        subSkill.id = skillList[i].subSkillIds[j]
        subSkill.cfg = SkillUtility.GetPassiveSkillCfg(subSkill.id)
      else
        subSkill.id = 0
        subSkill.cfg = nil
      end
      table.insert(subSkillTable, subSkill)
    end
  end
  skillTable.subSkills = subSkillTable
  return skillTable
end
def.method("table").SetResetSkillInfo = function(self, info)
  self.resetSkillInfo = {}
  self.resetSkillInfo.index = info.index
  self.resetSkillInfo.skillIndex = info.skillIndex
  self.resetSkillInfo.mainSkillId = info.mainSkillId
  self.resetSkillInfo.index2subskillid = info.index2subskillid
end
def.method().ClearResetSkillInfo = function(self)
  self.resetSkillInfo = nil
end
def.method("=>", "number").GetResetSkillType = function(self)
  if not self.resetSkillInfo then
    return -1
  end
  local hasMainSkill = self.resetSkillInfo.mainSkillId ~= 0
  local hasSubSkill = false
  for k, v in pairs(self.resetSkillInfo.index2subskillid) do
    if k ~= 0 and v ~= 0 then
      hasSubSkill = true
      break
    end
  end
  if hasMainSkill then
    return 0
  end
  if hasSubSkill then
    return 1
  end
  return -1
end
def.method("=>", "table").GetResetSkillCfg = function(self)
  local resetSkillType = self:GetResetSkillType()
  if resetSkillType == -1 then
    return nil
  end
  local cfg = {}
  cfg.MainSkillCfg = {}
  if self.resetSkillInfo.mainSkillId ~= 0 then
    cfg.MainSkillCfg.id = self.resetSkillInfo.mainSkillId
    cfg.MainSkillCfg.cfg = SkillUtility.GetPassiveSkillCfg(self.resetSkillInfo.mainSkillId)
  else
    cfg.MainSkillCfg.id = 0
    cfg.MainSkillCfg.cfg = nil
  end
  cfg.SubSkillCfgs = {}
  local skillMap = self.resetSkillInfo.index2subskillid
  for i = 1, WingsDataMgr.WING_SUB_SKILL_NUM do
    local subCfg = {}
    subCfg.id = skillMap[i]
    if subCfg.id then
      subCfg.cfg = SkillUtility.GetPassiveSkillCfg(subCfg.id)
    else
      subCfg.id = 0
      subCfg.cfg = nil
    end
    table.insert(cfg.SubSkillCfgs, subCfg)
  end
  return cfg
end
def.method("=>", "number", "number").GetResetSkillIndex = function(self)
  if not self.resetSkillInfo then
    return 0, 0
  end
  local mainIndex = self.resetSkillInfo.skillIndex
  local subIndex = 0
  for k, v in pairs(self.resetSkillInfo.index2subskillid) do
    if k ~= 0 and v ~= 0 then
      subIndex = k
      break
    end
  end
  return mainIndex, subIndex
end
return WingsDataMgr.Commit()
