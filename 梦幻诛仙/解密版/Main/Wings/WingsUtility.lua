local Lplus = require("Lplus")
local ItemUtils = require("Main.Item.ItemUtils")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local WingsUtility = Lplus.Class("WingsUtility")
local def = WingsUtility.define
def.const("table").Animation = {
  STAND = "Stand_c",
  ATTACK = "Attack01_c",
  DEFEND = "Defend_c",
  DEATH = "Death01_c",
  RUN = "Run_c"
}
def.const("table").ColorTable = {
  Color.white,
  Color.green,
  Color.blue,
  Color.Color(1, 0, 1),
  Color.Color(1, 0.5, 0)
}
def.const("table").PropSeq = {
  PropertyType.PHYATK,
  PropertyType.PHYDEF,
  PropertyType.MAGATK,
  PropertyType.MAGDEF,
  PropertyType.MAX_HP,
  PropertyType.SPEED
}
def.const("table").UIPath = {
  AddExpBtn = "panel_wing/Img _Bg0/Img_YY/Group_Right/Group_Attribute/Btn_Add",
  PropResetBtn = "panel_wing/Img _Bg0/Img_YY/Group_Right/Group_Attribute/Img_Bg/Btn_Reset",
  SkillResetBtn = "panel_wing/Img _Bg0/Img_YY/Group_Right/Group_Skill/Btn_ResetSkill",
  PhaseUpBtn = "panel_wing/Img _Bg0/Img_YY/Group_Right/Group_Skill/Btn_UpLevel"
}
def.static("table", "table", "=>", "boolean").WingsExpItemFilter = function(item, params)
  local itemBase = ItemUtils.GetItemBase(item.id)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  return itemBase.itemType == ItemType.WING_EXP_ITEM
end
def.static("string", "=>", "number").GetWingsConstByName = function(name)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WINGS_CONST_CFG, name)
  if record == nil then
    return -1
  end
  return record:GetIntValue("value")
end
def.static("number", "=>", "table").GetWingsLevelUpCfg = function(level)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WINGS_LEVELUP_CFG, level + 1)
  if not record then
    return nil
  end
  local cfg = {}
  cfg.needWingExp = record:GetIntValue("needWingExp")
  cfg.needRoleLevel = record:GetIntValue("needRoleLevel")
  cfg.needWingPhase = record:GetIntValue("needWingPhase")
  return cfg
end
def.static("number", "=>", "table").GetPhaseUpCfg = function(phase)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WINGS_PHASEUP_CFG, phase + 1)
  if not record then
    return nil
  end
  local cfg = {}
  cfg.wingPhase = record:GetIntValue("wingPhase")
  cfg.needWingLevel = record:GetIntValue("needWingLevel")
  cfg.needItemId = record:GetIntValue("needItemId")
  cfg.needItemNum = record:GetIntValue("needItemNum")
  return cfg
end
def.static("number", "=>", "table").GetPhaseCfg = function(phase)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WINGS_PHASEUP_CFG, phase)
  if not record then
    return nil
  end
  local cfg = {}
  cfg.wingPhase = record:GetIntValue("wingPhase")
  cfg.modelId = record:GetIntValue("modelId")
  cfg.maxSkillNum = record:GetIntValue("maxSkillNum")
  cfg.skillResetItemId = record:GetIntValue("skillResetItemId")
  cfg.skillResetItemNum = record:GetIntValue("skillResetItemNum")
  return cfg
end
def.static("number", "=>", "table").GetWingsViewCfg = function(wingsId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WINGS_VIEW_CFG, wingsId)
  if not record then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.name = record:GetStringValue("name")
  cfg.modelId = record:GetIntValue("modelId")
  cfg.dieEffectId = record:GetIntValue("dieEffectId")
  cfg.effectId = record:GetIntValue("effectId")
  cfg.desc = record:GetStringValue("desc")
  cfg.iconId = record:GetIntValue("iconId")
  cfg.fakeItemId = record:GetIntValue("fakeItemId")
  return cfg
end
def.static("number", "number", "number").ShowGainLevelExpEffect = function(exp, fromLevel, toLevel)
  if exp > 0 then
    Toast(string.format(textRes.Wings[31], exp))
  end
  if fromLevel < toLevel then
    Toast(string.format(textRes.Wings[32], toLevel))
  end
end
def.static("=>", "table").GetWingsSkillOpenPhaseCfg = function(index)
  local phase = WingsUtility.GetWingsConstByName("WING_INIT_PHASE")
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WINGS_PHASEUP_CFG, phase)
  if not record then
    return nil
  end
  local cfg = {}
  while record do
    local skillNum = record:GetIntValue("maxSkillNum")
    if not cfg[skillNum] then
      cfg[skillNum] = phase
    end
    phase = phase + 1
    record = DynamicData.GetRecord(CFG_PATH.DATA_WINGS_PHASEUP_CFG, phase)
  end
  return cfg
end
def.static("table", "userdata", "number").ShowWingskillTip = function(skillCfg, go, prefer)
  if not skillCfg then
    return
  end
  if not go then
    return
  end
  local position = go.position
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = go:GetComponent("UIWidget")
  local iconId = skillCfg.iconId
  local name = skillCfg.name
  local description = skillCfg.description
  local isUnlock = true
  local unlockTip = ""
  local typeText = "\232\162\171\229\138\168"
  local consume = textRes.Skill[8]
  require("Main.Skill.SkillTipMgr").Instance():ShowTipById(skillCfg.id, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), prefer)
end
def.static("=>", "table").GetAllWingsExpItemIds = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_WINGS_EXP_ITEM_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local idList = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local id = DynamicRecord.GetIntValue(entry, "id")
    table.insert(idList, id)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return idList
end
def.static("number", "=>", "table").GetWingExpItemCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WINGS_EXP_ITEM_CFG, id)
  if not record then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.exp = record:GetIntValue("exp")
  return cfg
end
def.static("=>", "table").GetAllWingsSkills = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_WINGS_SKILLS_LIB)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local mainSkillList = {}
  local subSkillList = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local mainSkillId = record:GetIntValue("mainSkillId")
    local subSkillStruct = record:GetStructValue("subSkillIdStruct")
    local size = subSkillStruct:GetVectorSize("subSkillIdVector")
    local subSkills = {}
    for j = 0, size - 1 do
      local subSkillItem = subSkillStruct:GetVectorValueByIdx("subSkillIdVector", j)
      local subSkillId = subSkillItem:GetIntValue("subSkillId")
      if subSkillId ~= 0 then
        table.insert(subSkills, subSkillId)
      end
    end
    table.insert(mainSkillList, mainSkillId)
    table.insert(subSkillList, subSkills)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return {mainSkillList = mainSkillList, subSkillList = subSkillList}
end
def.static("=>", "number").GetCurWingsTaskID = function()
  local TaskInterface = require("Main.task.TaskInterface")
  local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
  local WingsDataMgr = require("Main.Wings.data.WingsDataMgr")
  local graphID = WingsDataMgr.WING_TASK_GRAPH_ID
  local taskInfos = TaskInterface.Instance():GetTaskInfos()
  for taskId, graphIdValue in pairs(taskInfos) do
    for graphId, info in pairs(graphIdValue) do
      if graphId == graphID and (info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or info.state == TaskConsts.TASK_STATE_CAN_ACCEPT or info.state == TaskConsts.TASK_STATE_FINISH) then
        return taskId
      end
    end
  end
  return 0
end
def.static("number", "=>", "number").GetReSetPropItemPrice = function(itemId)
  local mallType = require("consts.mzm.gsp.mall.confbean.MallType")
  local mallUitls = require("Main.Mall.MallUtility")
  local key = string.format("%d_%d", itemId, mallType.FUNCTION_MALL)
  return mallUitls.GetItemPrice(key)
end
def.static("number", "=>", "number").GetRanseItemPrice = function(itemId)
  local mallType = require("consts.mzm.gsp.mall.confbean.MallType")
  local mallUitls = require("Main.Mall.MallUtility")
  local key = string.format("%d_%d", itemId, mallType.PRECIOUS_MALL)
  return mallUitls.GetItemPrice(key)
end
def.static("table").PrintWingsInfo = function(info)
  print("~~~~~Wings Schema beg~~~~~~~~~")
  print(string.format("Exp: %s, Level: %s, Phase: %s", info.exp, info.level, info.phase))
  for i = 1, #info.propertyList do
    local prop = info.propertyList[i]
    print(string.format("Property %d --->Type: %s, Value: %s, Phase: %s", i, prop.propertyType, prop.propertyValue, prop.propertyPhase))
  end
  for i = 1, #info.skillList do
    local skill = info.skillList[i]
    print(string.format("Skill %d --->Skill ID: %d, Skill Level: %d, SubSkill Count: %d", i, skill.mainSkillId, skill.mainSkilllevel, #skill.subSkillIds))
  end
  print("Current Wings View Id: ", info.modelId2dyeid.modelId, info.modelId2dyeid.dyeId)
  print("~~~~~Wings Schema end~~~~~~~~~")
end
def.static("table").PrintWingViewInfo = function(info)
  print("~~~~~~~~~~Wing View beg~~~~~~~~~~~")
  for i = 1, #info do
    print(string.format("Wings View %d ---> Wings ID: %d, Wings DyeID: %d", i, info[i].modelId, info[i].dyeId))
  end
  print("~~~~~~~~~~Wing View end~~~~~~~~~~~")
end
def.static("table").PrintPropList = function(propList)
  for i = 1, #propList do
    local prop = propList[i]
    print(string.format("Property %d --->Type: %s, Value: %s, Phase: %s", i, prop.propertyType, prop.propertyValue, prop.propertyPhase))
  end
end
return WingsUtility.Commit()
