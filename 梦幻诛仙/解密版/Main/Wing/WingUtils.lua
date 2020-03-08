local Lplus = require("Lplus")
local WingUtils = Lplus.Class("WingUtils")
local WingPropsStruct = require("Main.Wing.WingPropsStruct")
local ItemUtils = require("Main.Item.ItemUtils")
local SkillUtility = require("Main.Skill.SkillUtility")
local WingOutlookType = require("consts.mzm.gsp.wing.confbean.WingOutlookType")
local def = WingUtils.define
def.const("table").Animation = {
  STAND = "Stand_c",
  ATTACK = "Attack01_c",
  DEFEND = "Defend_c",
  DEATH = "Death01_c",
  RUN = "Run_c"
}
def.static("number", "=>", "table").GetWingCfg = function(wingId)
  local record = DynamicData.GetRecord(CFG_PATH.WING_CFG, wingId)
  if not record then
    warn("GetWingCfg nil:", wingId)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.outlookType = record:GetIntValue("outlookType")
  cfg.outlook = record:GetIntValue("outlook")
  cfg.initSkillLib = record:GetIntValue("initSkillLib")
  cfg.resetSkillLib = record:GetIntValue("resetSkillLib")
  cfg.resetSkillItemId = record:GetIntValue("resetSkillItemId")
  cfg.resetSkillItemNum = record:GetIntValue("resetSkillItemNum")
  cfg.initProId = record:GetIntValue("initProId")
  cfg.resetProId = record:GetIntValue("resetProId")
  cfg.resetProItemId = record:GetIntValue("resetProItemId")
  cfg.resetProItemNum = record:GetIntValue("resetProItemNum")
  cfg.gainDes = record:GetStringValue("gainDes")
  return cfg
end
def.static("table", "=>", "number").GetUnlockType = function(wingCfg)
  if wingCfg.initSkillLib > 0 and 0 < wingCfg.initProId then
    return 3
  elseif wingCfg.initSkillLib > 0 then
    return 2
  elseif 0 < wingCfg.initProId then
    return 1
  else
    return 0
  end
end
def.static("table", "=>", "number").GetResetType = function(wingCfg)
  if wingCfg.resetSkillLib > 0 and 0 < wingCfg.resetProId then
    return 3
  elseif wingCfg.resetSkillLib > 0 then
    return 2
  elseif 0 < wingCfg.resetProId then
    return 1
  else
    return 0
  end
end
def.static("number", "=>", "table").GetWingOutlookCfgByWingId = function(wingId)
  local wingCfg = WingUtils.GetWingCfg(wingId)
  if wingCfg then
    local outlookCfg = WingUtils.GetWingViewCfg(wingCfg.outlook)
    return outlookCfg
  end
  return nil
end
def.static("number", "=>", "table").GetWingDyeLibByWingId = function(wingId)
  warn("GetWingDyeLibByWingId", wingId)
  local wingCfg = WingUtils.GetWingCfg(wingId)
  if wingCfg then
    local outlook = wingCfg.outlook
    local viewCfg = WingUtils.GetWingViewCfg(outlook)
    if viewCfg then
      local dyeLib = WingUtils.GetDyeLib(viewCfg.dyeLibId)
      warn("dyeLib", #dyeLib)
      if #dyeLib > 0 then
        return dyeLib
      else
        return nil
      end
    else
      return nil
    end
  else
    return nil
  end
end
def.static("number", "=>", "table").GetWingFakeItemByWingId = function(wingId)
  local wingCfg = WingUtils.GetWingCfg(wingId)
  if wingCfg then
    local outlookCfg = WingUtils.GetWingViewCfg(wingCfg.outlook)
    if outlookCfg then
      local itemId = outlookCfg.fakeItemId
      local itemBase = ItemUtils.GetItemBase(itemId)
      return itemBase
    end
  end
  return nil
end
def.static("number", "=>", "table").GetWingProperty = function(propId)
  local record = DynamicData.GetRecord(CFG_PATH.WING_PROP, propId)
  if not record then
    warn("GetWingProperty nil:", propId)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.propType = record:GetIntValue("propType")
  cfg.propValue = record:GetIntValue("proValue")
  cfg.propColor = record:GetIntValue("proColor")
  return cfg
end
def.static("number", "table", "string", "=>", "string").PropsToString = function(wingId, props, prefix)
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local strTbl = {}
  local sortProps = {}
  for k, v in ipairs(props) do
    local prop = WingUtils.GetWingProperty(v)
    local propCfg = GetCommonPropNameCfg(prop.propType)
    local value = prop.propValue
    local propName = propCfg.propName
    local colorId = prop.propColor
    local sort = WingUtils.GetWingPropSortId(wingId, v)
    table.insert(sortProps, {
      name = propName,
      value = value,
      color = colorId,
      sort = sort
    })
  end
  table.sort(sortProps, function(a, b)
    return a.sort < b.sort
  end)
  for k, v in ipairs(sortProps) do
    if v.color > 1 then
      local str = string.format("%s[%s]%s +%d %s[-]", prefix, ItemTipsMgr.Color[v.color], v.name, v.value, textRes.Wing.QualityName[v.color] or "")
      table.insert(strTbl, str)
    else
      local str = string.format("%s%s +%d %s", prefix, v.name, v.value, textRes.Wing.QualityName[v.color] or "")
      table.insert(strTbl, str)
    end
  end
  return table.concat(strTbl, "\n")
end
def.static("number", "table", "string", "=>", "string").PropsToString2 = function(wingId, props)
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local strTbl = {}
  local sortProps = {}
  for k, v in ipairs(props) do
    local prop = WingUtils.GetWingProperty(v)
    local propCfg = GetCommonPropNameCfg(prop.propType)
    local value = prop.propValue
    local propName = propCfg.propName
    local colorId = prop.propColor
    local sort = WingUtils.GetWingPropSortId(wingId, v)
    table.insert(sortProps, {
      name = propName,
      value = value,
      color = colorId,
      sort = sort
    })
  end
  table.sort(sortProps, function(a, b)
    return a.sort < b.sort
  end)
  for k, v in ipairs(sortProps) do
    local str = string.format("%s +%d %s", v.name, v.value, textRes.Wing.QualityName[v.color] or "")
    table.insert(strTbl, str)
  end
  return table.concat(strTbl, "\n")
end
def.static("number", "number", "=>", "number").GetWingPropSortId = function(wingId, propId)
  local wingCfg = WingUtils.GetWingCfg(wingId)
  if wingCfg == nil then
    return 0
  end
  local props1 = WingUtils.GetWingPropLib(wingCfg.initProId)
  local props2 = WingUtils.GetWingPropLib(wingCfg.resetProId)
  for idx, propList in ipairs(props1 or {}) do
    for k, v in ipairs(propList) do
      if v == propId then
        return idx
      end
    end
  end
  for idx, propList in ipairs(props2 or {}) do
    for k, v in ipairs(propList) do
      if v == propId then
        return idx
      end
    end
  end
  warn("GetWingPropSortId wing not exist:", wingId)
  return 0
end
def.static("number", "=>", "string").SkillToString = function(skill)
  local skillCfg = SkillUtility.GetSkillCfg(skill)
  if skillCfg then
    local strTbl = {}
    local name = skillCfg.name
    table.insert(strTbl, name)
    local description = skillCfg.description
    table.insert(strTbl, description)
    return table.concat(strTbl, "\n")
  else
    return ""
  end
end
def.static("table", "=>", "string").PropsToName = function(props)
  if props == nil then
    return ""
  end
  local strTbl = {}
  for k, v in ipairs(props) do
    local prop = WingUtils.GetWingProperty(v)
    local propCfg = GetCommonPropNameCfg(prop.propType)
    local propName = propCfg.propName
    table.insert(strTbl, propName)
  end
  return table.concat(strTbl, textRes.Wing[19])
end
def.static("table", "=>", "string").SkillsToName = function(skills)
  if skills == nil then
    return ""
  end
  local strTbl = {}
  for k, v in ipairs(skills) do
    local skillCfg = SkillUtility.GetSkillCfg(v)
    table.insert(strTbl, skillCfg.name)
  end
  return table.concat(strTbl, textRes.Wing[19])
end
local maxPhase = 0
def.static("=>", "number").GetMaxPhase = function(self)
  if maxPhase == 0 then
    local entries = DynamicData.GetTable(CFG_PATH.WING_PHASE)
    local count = DynamicDataTable.GetRecordsCount(entries)
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, count - 1 do
      local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local rank = entry:GetIntValue("rank")
      maxPhase = rank > maxPhase and rank or maxPhase
    end
    DynamicDataTable.FastGetRecordEnd(entries)
  end
  return maxPhase
end
def.static("number", "=>", "number").GetLevelLimitByPhase = function(phase)
  local levelUp = WingUtils.GetAllUpgradeCfg()
  for k, v in ipairs(levelUp) do
    if v.needrank == phase then
      return k
    end
  end
  return -1
end
local promoteWing
def.static("=>", "table").ReadPromoteWing = function()
  if promoteWing ~= nil then
    return promoteWing
  end
  local entries = DynamicData.GetTable(CFG_PATH.WING_PHASE)
  local count = DynamicDataTable.GetRecordsCount(entries)
  promoteWing = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.rank = entry:GetIntValue("rank")
    cfg.wingInfoId = entry:GetIntValue("wingInfoId")
    cfg.upNeedRoleLv = entry:GetIntValue("upNeedRoleLv")
    cfg.needItemId = entry:GetIntValue("needItemId")
    cfg.itemNum = entry:GetIntValue("itemNum")
    cfg.visibleRank = entry:GetIntValue("visibleRank")
    table.insert(promoteWing, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(promoteWing, function(a, b)
    return a.rank < b.rank
  end)
  return promoteWing
end
def.static("=>", "table").GetAllPromoteWing = function(self)
  local promoteList = WingUtils.ReadPromoteWing()
  local promoteIds = {}
  for k, v in ipairs(promoteList) do
    table.insert(promoteIds, v.wingInfoId)
  end
  return promoteIds
end
def.static("number", "=>", "table").GetAllPromoteWingWithRank = function(myRank)
  local promoteList = WingUtils.ReadPromoteWing()
  local promoteIds = {}
  for k, v in ipairs(promoteList) do
    if myRank >= v.visibleRank then
      table.insert(promoteIds, v.wingInfoId)
    end
  end
  return promoteIds
end
def.static("number", "=>", "number").WingIdToPhase = function(wingId)
  local allPromote = WingUtils.ReadPromoteWing()
  for k, v in ipairs(allPromote) do
    if v.wingInfoId == wingId then
      return v.rank
    end
  end
  return -1
end
local otherWing
def.static("=>", "table").GetAllOtherWing = function()
  if otherWing ~= nil then
    return otherWing
  end
  local entries = DynamicData.GetTable(CFG_PATH.WING_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  otherWing = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local type = entry:GetIntValue("outlookType")
    if type ~= WingOutlookType.TY_SJ then
      local id = entry:GetIntValue("id")
      table.insert(otherWing, id)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return otherWing
end
def.static("number", "=>", "table").GetPromoteCfgByPhase = function(phase)
  local record = DynamicData.GetRecord(CFG_PATH.WING_PHASE, phase)
  if not record then
    warn("GetPromoteCfgByPhase nil:", phase)
    return nil
  end
  local cfg = {}
  cfg.rank = record:GetIntValue("rank")
  cfg.wingInfoId = record:GetIntValue("wingInfoId")
  cfg.upNeedRoleLv = record:GetIntValue("upNeedRoleLv")
  cfg.needItemId = record:GetIntValue("needItemId")
  cfg.itemNum = record:GetIntValue("itemNum")
  return cfg
end
def.static("=>", "table").GetAllUpgradeCfg = function(self)
  local entries = DynamicData.GetTable(CFG_PATH.WING_LEVEL)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local levelUpList = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.level = entry:GetIntValue("level")
    cfg.needrank = entry:GetIntValue("needrank")
    cfg.needExp = entry:GetIntValue("needExp")
    levelUpList[cfg.level] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return levelUpList
end
def.static("number", "=>", "table").GetUpgradeCfgByLevel = function(level)
  local record = DynamicData.GetRecord(CFG_PATH.WING_LEVEL, level)
  if not record then
    warn("GetUpgradeCfgByLevel nil:", phase)
    return nil
  end
  local cfg = {}
  cfg.level = record:GetIntValue("level")
  cfg.needrank = record:GetIntValue("needrank")
  cfg.needExp = record:GetIntValue("needExp")
  return cfg
end
def.static("number", "=>", "table").GetWingViewCfg = function(viewId)
  local record = DynamicData.GetRecord(CFG_PATH.WING_VIEW, viewId)
  if not record then
    warn("GetWingViewCfg nil:", viewId)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.modelId = record:GetIntValue("modelId")
  cfg.effectId = record:GetIntValue("effectId")
  cfg.dieEffectId = record:GetIntValue("dieEffectId")
  cfg.dyeLibId = record:GetIntValue("dyeLibId")
  cfg.dyeId = record:GetIntValue("dyeid")
  cfg.fakeItemId = record:GetIntValue("fakeItemId")
  return cfg
end
def.static().AllWingLib = function()
  local entries = DynamicData.GetTable(CFG_PATH.WING_SKILL_LIB)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local wingId = entry:GetIntValue("wingId")
    warn("AllWingLib", wingId)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.static("number", "=>", "table").GetDyeLib = function(dyeLib)
  local record = DynamicData.GetRecord(CFG_PATH.WING_DYE_LIB, dyeLib)
  if not record then
    warn("GetDyeLib nil:", dyeLib)
    return nil
  end
  local cfg = {}
  local rec = record:GetStructValue("dyeLibStruct")
  local size = rec:GetVectorSize("dyeLibList")
  for i = 0, size - 1 do
    local entry = rec:GetVectorValueByIdx("dyeLibList", i)
    local dyeId = entry:GetIntValue("dyeid")
    table.insert(cfg, dyeId)
  end
  return cfg
end
def.static("number", "=>", "table").GetSkillLib = function(wingId)
  local record = DynamicData.GetRecord(CFG_PATH.WING_SKILL_LIB, wingId)
  if not record then
    warn("GetSkillLib nil:", wingId)
    return nil
  end
  local cfg = {}
  local rec = record:GetStructValue("skillLibStruct")
  local size = rec:GetVectorSize("skillLibList")
  for i = 0, size - 1 do
    local entry = rec:GetVectorValueByIdx("skillLibList", i)
    local skillId = entry:GetIntValue("skillId")
    table.insert(cfg, skillId)
  end
  return cfg
end
def.static("number", "=>", "table").GetWingLevelProps = function(level)
  local typeId = constant.WingConsts.LEVEL_PRO_ID
  local props = require("Main.partner.PartnerInterface").GetLevelToPropertyCfg(typeId, level)
  if props == nil then
    warn("GetWingLevelProps fail:", typeId, level)
    return nil
  end
  local wingProp = WingPropsStruct()
  wingProp.PHYATK = props.addPhyAtkPerLevel
  wingProp.PHYDEF = props.addPhyDefPerLevel
  wingProp.MAGATK = props.addMagAtkPerLevel
  wingProp.MAGDEF = props.addMagDefPerLevel
  wingProp.MAX_HP = props.addMaxHpPerLevel
  wingProp.SPEED = props.addSpeedPerLevelPerLevel
  wingProp.PHY_CRIT_LEVEL = props.addPhyCrtLevelPerLevel
  wingProp.PHY_CRT_DEF_LEVEL = props.addPhyCrtLevelDefPerLevel
  wingProp.MAG_CRT_LEVEL = props.addMagCrtLevelPerLevel
  wingProp.MAG_CRT_DEF_LEVEL = props.addMagCrtLevelDefPerLevel
  wingProp.SEAL_HIT = props.addSealHitLevelPerLevel
  wingProp.SEAL_RESIST = props.addSealResLevelPerLevel
  return wingProp
end
def.static("table", "=>", "table").ConvertWingProps = function(rawData)
  local wingProp = WingPropsStruct()
  if rawData then
    for k, v in ipairs(rawData) do
      local prop = WingUtils.GetWingProperty(v)
      wingProp:SetValueByType(prop.propType, prop.propValue)
    end
  end
  return wingProp
end
def.static("number").ShowQA = function(tipId)
  local tmpPosition = {x = 0, y = 0}
  local CommonDescDlg = require("GUI.CommonUITipsDlg")
  local tipString = require("Main.Common.TipsHelper").GetHoverTip(tipId)
  if tipString == "" then
    return
  end
  CommonDescDlg.ShowCommonTip(tipString, tmpPosition)
end
def.static("number", "=>", "table").GetOneWingSkillLib = function(wingId)
  local wingItem = WingUtils.GetWingFakeItemByWingId(wingId)
  local skills = WingUtils.GetSkillLib(wingId)
  if wingItem and skills then
    local result = {}
    local oneWing = {}
    oneWing.name = wingItem.name
    oneWing.wingId = wingId
    oneWing.skills = {}
    oneWing.sort = 1
    oneWing.skills[1] = {
      name = textRes.Wing[40]
    }
    for k, v in ipairs(skills) do
      table.insert(oneWing.skills[1], v)
    end
    result[1] = oneWing
    return result
  else
    return nil
  end
end
def.static("number", "=>", "table").GetWingSkillLib = function(curPhase)
  local allWings = WingUtils.ReadPromoteWing()
  local allSkill = {}
  local wingSkill = {}
  for k, v in ipairs(allWings) do
    if curPhase >= v.visibleRank then
      local skills = WingUtils.GetSkillLib(v.wingInfoId)
      if skills then
        local oneWingSkill = {}
        for k1, v1 in ipairs(skills) do
          table.insert(oneWingSkill, v1)
          allSkill[v1] = true
        end
        table.sort(oneWingSkill)
        oneWingSkill.phase = v.rank
        oneWingSkill.windId = v.wingInfoId
        table.insert(wingSkill, oneWingSkill)
      end
    end
  end
  local allSkill = table.keys(allSkill)
  table.sort(allSkill)
  local result = {}
  local allSkillTree = {}
  allSkillTree.name = textRes.Wing[36]
  allSkillTree.skills = {}
  allSkillTree.sort = -1
  allSkillTree.skills[1] = {
    name = textRes.Wing[40]
  }
  for k, v in ipairs(allSkill) do
    table.insert(allSkillTree.skills[1], v)
  end
  table.insert(result, allSkillTree)
  local oldWingSkillMap
  for k, v in ipairs(wingSkill) do
    local tree = {}
    tree.name = string.format(textRes.Wing[35], v.phase)
    tree.skills = {}
    tree.sort = v.phase
    tree.wingId = v.windId
    tree.skills[1] = {
      name = textRes.Wing[41]
    }
    tree.skills[2] = {
      name = textRes.Wing[40]
    }
    local newWingSkillMap = {}
    for k1, v1 in ipairs(v) do
      table.insert(tree.skills[2], v1)
      newWingSkillMap[v1] = true
      if oldWingSkillMap ~= nil and not oldWingSkillMap[v1] then
        table.insert(tree.skills[1], v1)
      end
    end
    if #tree.skills[1] == 0 then
      table.remove(tree.skills, 1)
    end
    oldWingSkillMap = newWingSkillMap
    table.insert(result, tree)
  end
  table.sort(result, function(a, b)
    return a.sort < b.sort
  end)
  return result
end
def.static("number", "=>", "table").GetWingPropLib = function(libId)
  local record = DynamicData.GetRecord(CFG_PATH.WING_PROP_LIB, libId)
  if not record then
    warn("GetWingPropLib nil:", libId)
    return nil
  end
  local cfg = {}
  local propLibStruct = record:GetStructValue("propLibStruct")
  local propLibSize = propLibStruct:GetVectorSize("propLibList")
  for i = 1, propLibSize do
    cfg[i] = {}
    local propLibEntry = propLibStruct:GetVectorValueByIdx("propLibList", i - 1)
    local propStruct = propLibEntry:GetStructValue("propStruct")
    local propSize = propStruct:GetVectorSize("propList")
    for j = 1, propSize do
      local entry = propStruct:GetVectorValueByIdx("propList", j - 1)
      local propId = entry:GetIntValue("propId")
      table.insert(cfg[i], propId)
    end
  end
  return cfg
end
def.static("number", "=>", "string", "number").GetWingPropertyPreview = function(wingId)
  local wingCfg = WingUtils.GetWingCfg(wingId)
  if wingCfg == nil then
    return nil
  end
  local props1 = WingUtils.GetWingPropLib(wingCfg.initProId)
  local props2 = WingUtils.GetWingPropLib(wingCfg.resetProId)
  local propPreview = {}
  local function CountProp(idx, prop, value)
    if propPreview[idx] == nil then
      propPreview[idx] = {}
    end
    if propPreview[idx][prop] then
      if value > propPreview[idx][prop].max then
        propPreview[idx][prop].max = value
      elseif value < propPreview[idx][prop].min then
        propPreview[idx][prop].min = value
      end
    else
      propPreview[idx][prop] = {min = value, max = value}
    end
  end
  for idx, propList in ipairs(props1 or {}) do
    for k, v in ipairs(propList) do
      local propCfg = WingUtils.GetWingProperty(v)
      if propCfg then
        CountProp(idx, propCfg.propType, propCfg.propValue)
      end
    end
  end
  for idx, propList in ipairs(props2 or {}) do
    for k, v in ipairs(propList) do
      local propCfg = WingUtils.GetWingProperty(v)
      if propCfg then
        CountProp(idx, propCfg.propType, propCfg.propValue)
      end
    end
  end
  local sortedPreview = {}
  for idx, props in ipairs(propPreview) do
    local sorted = {}
    for k, v in pairs(props) do
      table.insert(sorted, {
        prop = k,
        min = v.min,
        max = v.max
      })
    end
    table.sort(sorted, function(a, b)
      return a.prop < b.prop
    end)
    sortedPreview[idx] = sorted
  end
  local strTbl = {}
  local maxDigitalCount = 0
  for idx, props in ipairs(sortedPreview) do
    local propStrTbl = {}
    for k, v in ipairs(props) do
      local propCfg = GetCommonPropNameCfg(v.prop)
      if propCfg then
        local propName = propCfg.propName
        if v.min == v.max then
          table.insert(propStrTbl, string.format("%s:+%d", propName, v.min))
        else
          table.insert(propStrTbl, string.format("%s:+%d~%d", propName, v.min, v.max))
        end
      end
    end
    local line = table.concat(propStrTbl, "/")
    maxDigitalCount = math.max(maxDigitalCount, _G.Strlen(line))
    table.insert(strTbl, line)
  end
  return table.concat(strTbl, "\n"), maxDigitalCount
end
def.static("number").ShowPropPreView = function(wingId)
  local previewWord, maxDigitalCount = WingUtils.GetWingPropertyPreview(wingId)
  if maxDigitalCount >= 20 then
    require("GUI.CommonResizeTipWithTitle").Instance():ShowTipWithPos(textRes.Wing[44], previewWord, 0, 0)
  else
    require("GUI.CommonTipWithTitle").Instance():ShowTipWithPos(textRes.Wing[44], previewWord, 0, 0)
  end
end
return WingUtils.Commit()
