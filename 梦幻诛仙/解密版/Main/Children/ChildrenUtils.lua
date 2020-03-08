local Lplus = require("Lplus")
local ChildrenUtils = Lplus.Class("ChildrenUtils")
local def = ChildrenUtils.define
def.static("number", "=>", "table").GetRecallCfg = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHILD_RECALL_CFG, cfgId)
  if record == nil then
    warn("GetRecallCfg nil", cfgId)
    return nil
  end
  local cfg = {}
  cfg.costCurrencyType = record:GetIntValue("cost_currency_type")
  cfg.costCurrencyNum = record:GetIntValue("cost_currency_num")
  return cfg
end
def.static("number", "=>", "table").GetInterestCfg = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHILDREN_CDrawLotsCfg, cfgId)
  if record == nil then
    warn("GetInterestCfg nil", cfgId)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.name = record:GetStringValue("name")
  cfg.props = {}
  local propStruct = record:GetStructValue("propStruct")
  local propVectorSize = DynamicRecord.GetVectorSize(propStruct, "propList")
  for i = 0, propVectorSize - 1 do
    local rec = propStruct:GetVectorValueByIdx("propList", i)
    local prop = rec:GetIntValue("interestType")
    local value = rec:GetIntValue("interestValue")
    table.insert(cfg.props, {prop = prop, value = value})
  end
  return cfg
end
def.static("number", "=>", "table").GetCourseCfg = function(courseType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHILDREN_CCourseCfg, courseType)
  if record == nil then
    warn("GetCourseCfg nil", courseType)
    return nil
  end
  local cfg = {}
  cfg.courseType = record:GetIntValue("courseType")
  cfg.name = record:GetStringValue("name")
  cfg.desc = record:GetStringValue("desc")
  cfg.studyTime = record:GetIntValue("studyTime")
  cfg.vigorCost = record:GetIntValue("vigor")
  cfg.moneyCostType = record:GetIntValue("moneyType")
  cfg.moneyCostNum = record:GetIntValue("cost")
  cfg.props = {}
  local propStruct = record:GetStructValue("propStruct")
  local propVectorSize = DynamicRecord.GetVectorSize(propStruct, "propList")
  for i = 0, propVectorSize - 1 do
    local rec = propStruct:GetVectorValueByIdx("propList", i)
    local prop = rec:GetIntValue("interestType")
    local value = rec:GetIntValue("interestValue")
    local critValue = rec:GetIntValue("critValue")
    table.insert(cfg.props, {
      prop = prop,
      value = value,
      critValue = critValue
    })
  end
  return cfg
end
def.static("number", "=>", "table").GetPropCfg = function(propType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHILDREN_CInterestCfg, propType)
  if record == nil then
    warn("GetPropCfg nil", propType)
    return nil
  end
  local cfg = {}
  cfg.type = record:GetIntValue("interestType")
  cfg.name = record:GetStringValue("name")
  cfg.desc = record:GetStringValue("desc")
  cfg.limit = record:GetIntValue("limit")
  return cfg
end
def.static("=>", "table").GetAllOccupationRecommend = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILDREN_CRecommendCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = entry:GetIntValue("id")
    cfg.name = entry:GetStringValue("name")
    table.insert(list, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return list
end
def.static("number", "=>", "table").GetOneOccupationRecommond = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHILDREN_CRecommendCfg, cfgId)
  if record == nil then
    warn("GetOneOccupationRecommond nil", cfgId)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.name = record:GetStringValue("name")
  cfg.courses = {}
  local courseStruct = record:GetStructValue("courseStruct")
  local propVectorSize = DynamicRecord.GetVectorSize(courseStruct, "courseList")
  for i = 0, propVectorSize - 1 do
    local rec = courseStruct:GetVectorValueByIdx("courseList", i)
    local course = rec:GetIntValue("courseType")
    local value = rec:GetIntValue("studyNum")
    table.insert(cfg.courses, {course = course, value = value})
  end
  return cfg
end
def.static("table", "string", "=>", "string").PropsToString = function(props, split)
  local sortTbl = {}
  for k, v in pairs(props) do
    if v > 0 then
      table.insert(sortTbl, {prop = k, value = v})
    end
  end
  table.sort(sortTbl, function(a, b)
    return a.prop < b.prop
  end)
  local strTbl = {}
  for _, v in ipairs(sortTbl) do
    local propCfg = ChildrenUtils.GetPropCfg(v.prop)
    if propCfg then
      local str = string.format("%s +%d", propCfg.name, v.value)
      table.insert(strTbl, str)
    end
  end
  return table.concat(strTbl, split)
end
def.static("table", "string", "=>", "string").PropsToStringV2 = function(props, split)
  local sortTbl = {}
  for i, v in pairs(props) do
    if v.prop > 0 then
      table.insert(sortTbl, v)
    end
  end
  table.sort(sortTbl, function(a, b)
    return a.prop < b.prop
  end)
  local strTbl = {}
  for _, v in ipairs(sortTbl) do
    local propCfg = ChildrenUtils.GetPropCfg(v.prop)
    if propCfg then
      local str
      if v.critValue and 0 < v.critValue then
        str = string.format("%s +%d(%s +%d)", propCfg.name, v.value + v.critValue, textRes.Children[4212], v.critValue)
      else
        str = string.format("%s +%d", propCfg.name, v.value)
      end
      table.insert(strTbl, str)
    end
  end
  return table.concat(strTbl, split)
end
def.static("=>", "table").LoadAptitudeData = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILDREN_CChildPropToAptitudeCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local data = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local prop = entry:GetIntValue("prop")
    local value = entry:GetIntValue("propValue")
    local toAptidute = {}
    local aptitudeStruct = entry:GetStructValue("aptitudeStruct")
    local aptitudeListSize = DynamicRecord.GetVectorSize(aptitudeStruct, "aptitudeStructList")
    for i = 0, aptitudeListSize - 1 do
      local rec = aptitudeStruct:GetVectorValueByIdx("aptitudeStructList", i)
      local aptitude = rec:GetIntValue("aptitude")
      local min = rec:GetIntValue("min")
      local max = rec:GetIntValue("max")
      table.insert(toAptidute, {
        aptitude = aptitude,
        min = min,
        max = max
      })
    end
    if data[prop] == nil then
      data[prop] = {}
    end
    data[prop][value] = toAptidute
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return data
end
def.static("number", "number", "=>", "table").GetBreedStepCfg = function(breedType, step)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILDREN_CBreedStepCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local ret
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = entry:GetIntValue("id")
    cfg.breed_type = entry:GetIntValue("breed_type")
    cfg.step = entry:GetIntValue("step")
    cfg.step_description_tips_id = entry:GetIntValue("step_description_tips_id")
    if cfg.breed_type == breedType and cfg.step == step then
      ret = cfg
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  if ret == nil then
    warn("breed step cfg not exist:", breedType, step)
  end
  return ret
end
def.static("number", "=>", "table").GetBabyOperateCfg = function(operate)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHILDREN_CBabyOperatorCfg, operate)
  if record == nil then
    warn("GetBabyOperateCfg nil", operate)
    return nil
  end
  local cfg = {}
  cfg.operator = record:GetIntValue("operator")
  cfg.iconId = record:GetIntValue("operator_icon_id")
  local currencyStruct = record:GetStructValue("currencyStruct")
  local currencyVectorSize = DynamicRecord.GetVectorSize(currencyStruct, "currencyList")
  for i = 0, currencyVectorSize - 1 do
    local rec = currencyStruct:GetVectorValueByIdx("currencyList", i)
    local cost_currency_type = rec:GetIntValue("cost_currency_type")
    local cost_currency_type_value = rec:GetIntValue("cost_currency_type_value")
    cfg.cost = cfg.cost or {}
    table.insert(cfg.cost, {currencyType = cost_currency_type, value = cost_currency_type_value})
  end
  local propertyStruct = record:GetStructValue("propertyStruct")
  local propertyVectorSize = DynamicRecord.GetVectorSize(propertyStruct, "propertyList")
  for i = 0, propertyVectorSize - 1 do
    local rec = propertyStruct:GetVectorValueByIdx("propertyList", i)
    local add_property_type = rec:GetIntValue("add_property_type")
    local add_property_type_value = rec:GetIntValue("add_property_type_value")
    cfg.property = cfg.property or {}
    table.insert(cfg.property, {propertyType = add_property_type, value = add_property_type_value})
  end
  return cfg
end
def.static("userdata", "=>", "string").ConvertSecondToStr = function(second)
  if second == nil then
    return "00:00:00"
  end
  local h = second / 3600
  local m = second % 3600 / 60
  local s = second % 60
  return string.format("%02d:%02d:%02d", tonumber(h:tostring()), tonumber(m:tostring()), tonumber(s:tostring()))
end
def.static("number", "=>", "table").GetChildrenFashionCfg = function(fashionId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHILDREN_CFashionCfg, fashionId)
  if record == nil then
    warn("GetChildrenFashionCfg nil", fashionId)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.phase = record:GetIntValue("phase")
  cfg.gender = record:GetIntValue("gender")
  cfg.name = record:GetStringValue("name")
  cfg.desc = record:GetStringValue("desc")
  cfg.itemId = record:GetIntValue("itemId")
  cfg.duration = record:GetIntValue("duration")
  cfg.changeId = record:GetIntValue("changeId")
  cfg.typeId = record:GetIntValue("typeId")
  return cfg
end
def.static("number", "=>", "table").GetChildrenFashionCfgIdsByTypeId = function(typeId)
  local retData = {}
  local entry = DynamicData.GetRecord(CFG_PATH.DATA_CHILDREN_TYPE2CFGIDS, typeId)
  if entry == nil then
    warn("[ERROR: Load DATA_CHILDREN_TYPE2CFGIDS error,] typeId = " .. typeId)
    return nil
  end
  local cfgIdsStruct = entry:GetStructValue("cfgIdsStruct")
  local vecSize = DynamicRecord.GetVectorSize(cfgIdsStruct, "cfgIds")
  for i = 0, vecSize - 1 do
    local record = cfgIdsStruct:GetVectorValueByIdx("cfgIds", i)
    local cfgId = record:GetIntValue("cfgId")
    table.insert(retData, cfgId)
  end
  return retData
end
def.static("=>", "table").GetAllChildrenFashion = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILDREN_CFashionCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local ret = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = entry:GetIntValue("id")
    cfg.phase = entry:GetIntValue("phase")
    cfg.gender = entry:GetIntValue("gender")
    table.insert(ret, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return ret
end
def.static("number", "=>", "table").GetChildrenCfgById = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHILDREN_CChildrenCfg, cfgId)
  if record == nil then
    warn("[GetChildrenCfgById]record is nil for id: ", cfgId)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.modelId = record:GetIntValue("modelId")
  cfg.hairResId = record:GetIntValue("hairResId")
  cfg.hairColor = record:GetIntValue("hairColor")
  cfg.bodyResId = record:GetIntValue("bodyResId")
  cfg.bodyColor = record:GetIntValue("bodyColor")
  cfg.speed = record:GetIntValue("speed")
  return cfg
end
def.static("number", "number", "=>", "number", "number", "number", "number").SelectChildren = function(phase, gender)
  local ChildPhase = require("consts.mzm.gsp.children.confbean.ChildPhase")
  local SGenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local CChildrenConsts = constant.CChildrenConsts
  if phase == ChildPhase.INFANT then
    if gender == SGenderEnum.MALE then
      return CChildrenConsts.BOY_BABY_BASE_CFG_ID, 0, 0, 0
    elseif gender == SGenderEnum.FEMALE then
      return CChildrenConsts.GIRL_BABY_BASE_CFG_ID, 0, 0, 0
    else
      return CChildrenConsts.BOY_BABY_BASE_CFG_ID, CChildrenConsts.GIRL_BABY_BASE_CFG_ID, 0, 0
    end
  elseif phase == ChildPhase.CHILD then
    if gender == SGenderEnum.MALE then
      return CChildrenConsts.BOY_CHILDHOOD_BASE_CFG_ID, 0, 0, 0
    elseif gender == SGenderEnum.FEMALE then
      return CChildrenConsts.GIRL_CHILDHOOD_BASE_CFG_ID, 0, 0, 0
    else
      return CChildrenConsts.BOY_CHILDHOOD_BASE_CFG_ID, CChildrenConsts.GIRL_CHILDHOOD_BASE_CFG_ID, 0, 0
    end
  elseif phase == ChildPhase.YOUTH then
    if gender == SGenderEnum.MALE then
      return CChildrenConsts.BOY_ADULT1_BASE_CFG_ID, CChildrenConsts.BOY_ADULT2_BASE_CFG_ID, 0, 0
    elseif gender == SGenderEnum.FEMALE then
      return CChildrenConsts.GIRL_ADULT1_BASE_CFG_ID, CChildrenConsts.GIRL_ADULT2_BASE_CFG_ID, 0, 0
    else
      return CChildrenConsts.BOY_ADULT1_BASE_CFG_ID, CChildrenConsts.BOY_ADULT2_BASE_CFG_ID, CChildrenConsts.GIRL_ADULT1_BASE_CFG_ID, CChildrenConsts.GIRL_ADULT2_BASE_CFG_ID
    end
  end
  return 0, 0, 0, 0
end
def.static("number", "=>", "number").GetChildHeadIcon = function(childCfgId)
  local cfg = ChildrenUtils.GetChildrenCfgById(childCfgId)
  if cfg == nil then
    return 0
  end
  local modelRecord = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, cfg.modelId)
  if modelRecord then
    return modelRecord:GetIntValue("headerIconId")
  end
  return 0
end
def.static("number", "=>", "number").GetChildHalfBofyIcon = function(childCfgId)
  local cfg = ChildrenUtils.GetChildrenCfgById(childCfgId)
  if cfg == nil then
    return 0
  end
  local modelRecord = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, cfg.modelId)
  if modelRecord then
    return modelRecord:GetIntValue("halfBodyIconId")
  end
  return 0
end
def.static("number", "=>", "number").RandomAChildFamilyLoveWord = function(loveType)
  local familyLoveCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILDREN_CChildrenFamilyLoveTipsCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = entry:GetIntValue("id")
    cfg.type = entry:GetIntValue("type")
    cfg.tips_id = entry:GetIntValue("tips_id")
    familyLoveCfg[cfg.type] = familyLoveCfg[cfg.type] or {}
    table.insert(familyLoveCfg[cfg.type], cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  if familyLoveCfg[loveType] == nil then
    warn("familyLoveCfg is empty, type:" .. loveType)
    return -1
  end
  if #familyLoveCfg[loveType] == 0 then
    warn("familyLoveCfg is empty, type:" .. loveType)
    return -1
  end
  local randonIdx = math.random(#familyLoveCfg[loveType])
  return familyLoveCfg[loveType][randonIdx].tips_id
end
def.static("number", "=>", "table").GetMenpaiSkills = function(menpai)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILDREN_OccupationSkillCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  local skills = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local occupation = entry:GetIntValue("occupation")
    if menpai == occupation then
      local cfg = {}
      cfg.skillid = entry:GetIntValue("skillid")
      cfg.mainItemid = entry:GetIntValue("mainItemid")
      cfg.levelUpCostClassid = entry:GetIntValue("levelUpCostClassid")
      cfg.needEquipmentLevel = entry:GetIntValue("needEquipmentLevel")
      table.insert(skills, cfg)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return skills
end
def.static("number", "=>", "table").GetMenpaiSkillMap = function(menpai)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILDREN_OccupationSkillCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  local skills = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local occupation = entry:GetIntValue("occupation")
    if menpai == occupation then
      local cfg = {}
      cfg.skillid = entry:GetIntValue("skillid")
      cfg.mainItemid = entry:GetIntValue("mainItemid")
      cfg.levelUpCostClassid = entry:GetIntValue("levelUpCostClassid")
      cfg.needEquipmentLevel = entry:GetIntValue("needEquipmentLevel")
      skills[cfg.skillid] = cfg
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return skills
end
def.static("number", "number", "=>", "number").GetChildSkillUpdateCfg = function(classid, level)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILDREN_OccupationUpdateSkillCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cost = 0
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local class_id = entry:GetIntValue("classid")
    local skillLv = entry:GetIntValue("skillLv")
    if class_id == classid and level == skillLv then
      cost = entry:GetIntValue("itemCount")
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cost
end
def.static("=>", "number").GetChildSkillMaxLevel = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILDREN_OccupationUpdateSkillCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local lvs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local skillLv = entry:GetIntValue("skillLv")
    table.insert(lvs, skillLv)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(lvs, function(a, b)
    if a == nil then
      return true
    elseif b == nil then
      return false
    else
      return a < b
    end
  end)
  return (lvs[#lvs] or 0) + 1
end
def.static("number", "=>", "number").GetChildDefaultScheme = function(menpai)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHILD_DEFAULT_SCHEME_CFG, menpai)
  if record == nil then
    warn("GetChildDefaultScheme get nil record for id: ", menpai)
    return -1
  end
  return record:GetIntValue("schemeId")
end
def.static("=>", "table").GetAllChildrenSpecialSkillItemIds = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILD_SPECIAL_SKILL_ITEM_CFG)
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
def.static("=>", "table").GetChildSkillUnlockCfg = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHILD_UNLOCK_SKILL_CFG, 830900000)
  if record == nil then
    warn("GetChildDefaultScheme get nil record for id: 830900000")
    return nil
  end
  local cfgs = {}
  local itemsStruct = record:GetStructValue("itemsStruct")
  local count = DynamicRecord.GetVectorSize(itemsStruct, "itemsList")
  for i = 0, count - 1 do
    local rec = itemsStruct:GetVectorValueByIdx("itemsList", i)
    local ret = {}
    ret.unLockItemNum = rec:GetIntValue("unLockItemNum")
    ret.unLockMainItem = rec:GetIntValue("unLockMainItem")
    ret.unLocksubItem1 = rec:GetIntValue("unLocksubItem1")
    table.insert(cfgs, ret)
  end
  return cfgs
end
def.static("=>", "table").GetAllOccupationSkill = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILDREN_OccupationSkillCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  local skills = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local occupation = entry:GetIntValue("occupation")
    if skills[occupation] == nil then
      skills[occupation] = {}
    end
    local skillid = entry:GetIntValue("skillid")
    table.insert(skills[occupation], skillid)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return skills
end
def.static("=>", "table").GetAllOpenedOccupationSkill = function()
  local OccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local LoginUtility = require("Main.Login.LoginUtility")
  local skills = ChildrenUtils.GetAllOccupationSkill()
  local openedOccupationSkill = {}
  for k, v in pairs(skills) do
    if not LoginUtility.Instance():IsOccupationHided(k) then
      openedOccupationSkill[k] = v
    end
  end
  return openedOccupationSkill
end
def.static("=>", "table").GetAllChildrenSpecialSkills = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILD_SPECIAL_SKILL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local idList = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local id = DynamicRecord.GetIntValue(entry, "skillId")
    table.insert(idList, id)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return idList
end
def.static("number", "=>", "table").GetChildEquipItemIdsByPos = function(pos)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILD_EQUIP_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local idList = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local id = DynamicRecord.GetIntValue(entry, "id")
    local wearPos = DynamicRecord.GetIntValue(entry, "wearPos")
    if pos == wearPos then
      table.insert(idList, id)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return idList
end
def.static("number", "=>", "table").GetChildEquipItem = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHILD_EQUIP_CFG, id)
  if record == nil then
    warn("GetChildEquipItem get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.levelTypeid = record:GetIntValue("levelTypeid")
  cfg.stageTypeid = record:GetIntValue("stageTypeid")
  cfg.wearPos = record:GetIntValue("wearPos")
  cfg.modelId = record:GetIntValue("modelId")
  return cfg
end
def.static("number", "number", "=>", "table").GetChildEquipLevelCfg = function(id, level)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILD_EQUIP_LEVEL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfg
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local _level = DynamicRecord.GetIntValue(entry, "level")
    local levelTypeid = DynamicRecord.GetIntValue(entry, "levelTypeid")
    if id == levelTypeid and level == _level then
      cfg = {}
      cfg.levelUpExp = DynamicRecord.GetIntValue(entry, "levelUpExp")
      cfg.phase_req = DynamicRecord.GetIntValue(entry, "needStage")
      local propStruct = entry:GetStructValue("propStruct")
      local propVectorSize = DynamicRecord.GetVectorSize(propStruct, "propList")
      cfg.propList = {}
      for i = 0, propVectorSize - 1 do
        local key_rec = propStruct:GetVectorValueByIdx("propList", i)
        local val_rec = propStruct:GetVectorValueByIdx("propValueList", i)
        local key = key_rec:GetIntValue("key")
        local value = val_rec:GetIntValue("val")
        table.insert(cfg.propList, {key = key, value = value})
      end
      cfg.itemIds = {}
      local itemCount = DynamicRecord.GetVectorSize(propStruct, "itemidsList")
      for i = 0, itemCount - 1 do
        local item_rec = propStruct:GetVectorValueByIdx("itemidsList", i)
        local itemId = item_rec:GetIntValue("itemId")
        table.insert(cfg.itemIds, itemId)
      end
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfg
end
def.static("number", "number", "=>", "table").GetChildEquipPhaseCfg = function(id, phase)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILD_EQUIP_PHASE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfg
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local _phase = DynamicRecord.GetIntValue(entry, "stage")
    local stageTypeid = DynamicRecord.GetIntValue(entry, "stageTypeid")
    if id == stageTypeid and phase == _phase then
      cfg = {}
      cfg.mainItemid = DynamicRecord.GetIntValue(entry, "mainItemid")
      cfg.subItemid = DynamicRecord.GetIntValue(entry, "subItemid1")
      cfg.needLevel = DynamicRecord.GetIntValue(entry, "needLevel")
      cfg.needItemNum = DynamicRecord.GetIntValue(entry, "needItemNum")
      cfg.color = DynamicRecord.GetIntValue(entry, "color")
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfg
end
def.static("=>", "number").GetChildEquipMaxPhase = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILD_EQUIP_PHASE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local entry = DynamicDataTable.GetRecordByIdx(entries, count - 1)
  if entry == nil then
    warn("entry is nil for idx: ", count - 1)
    return -1
  end
  local phase = DynamicRecord.GetIntValue(entry, "stage")
  return phase
end
def.static("=>", "table").GetChildrenCharacterCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHILD_CHARACTER_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.desc = DynamicRecord.GetIntValue(entry, "desc")
    cfg.name = DynamicRecord.GetStringValue(entry, "name")
    cfg.min = DynamicRecord.GetIntValue(entry, "min")
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "number").GetChildEquipLevelUpItemCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHILD_EQUIP_LEVELUP_ITEM_CFG, id)
  if record == nil then
    warn("GetChildEquipLevelUpItemCfg get nil record for id: ", id)
    return
  end
  return record:GetIntValue("exp")
end
def.static("number", "=>", "number").GetChildCharacterItemCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHILD_CHARACTER_ITEM_CFG, id)
  if record == nil then
    warn("GetChildCharacterItemCfg get nil record for id: ", id)
    return
  end
  return record:GetIntValue("addCharacter")
end
def.static("number", "=>", "table").GetChildGrowthItemCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHILD_GROWTH_ITEM_CFG, id)
  if record == nil then
    warn("GetChildGrowthItemCfg get nil record for id: ", id)
    return
  end
  local cfg = {}
  cfg.min = record:GetIntValue("growRateMin")
  cfg.max = record:GetIntValue("growRateMax")
  cfg.useCount = record:GetCharValue("addUseCount") ~= 0
  return cfg
end
def.static("number", "=>", "table").GetChildrenInitEquip = function(modelCfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHILD_INIT_EQUIP_CFG, modelCfgId)
  if record == nil then
    warn("GetChildrenDefaultEquip get nil record for id:", modelCfgId)
    return nil
  end
  local equips = {}
  local initEquipStruct = record:GetStructValue("initEquipStruct")
  local count = DynamicRecord.GetVectorSize(initEquipStruct, "initEquipList")
  for i = 0, count - 1 do
    local rec = initEquipStruct:GetVectorValueByIdx("initEquipList", i)
    local id = rec:GetIntValue("equipId")
    table.insert(equips, id)
  end
  return equips
end
def.static("number", "=>", "number").GetChildrenInitWeapon = function(modelCfgId)
  local initEquips = ChildrenUtils.GetChildrenInitEquip(modelCfgId)
  if initEquips then
    local ChildEuqipPos = require("consts.mzm.gsp.item.confbean.ChildEuqipPos")
    for _, v in ipairs(initEquips) do
      local equipCfg = ChildrenUtils.GetChildEquipItem(v)
      if equipCfg and equipCfg.wearPos == ChildEuqipPos.WEAPON then
        return v
      end
    end
    return 0
  else
    return 0
  end
end
def.static("number", "=>", "string").GetChildLocationText = function(child_location)
  local text = textRes.Children.Location[child_location]
  if text == nil then
    text = textRes.Children.Location[-1]:format(child_location)
  end
  return text
end
def.static("userdata", "number").SetYouthChildScore = function(groupScore, score)
  ChildrenUtils.SetYouthChildScoreUI(groupScore, score, false)
end
def.static("userdata", "number", "boolean").SetYouthChildScoreUI = function(groupScore, score, isTweening)
  if groupScore == nil or groupScore.isnil then
    return
  end
  local GUIUtils = require("GUI.GUIUtils")
  local Label_PowerNum = groupScore:FindDirect("Label_PowerNum")
  local Group_UpDown = groupScore:FindDirect("Group_UpDown")
  GUIUtils.SetActive(Label_PowerNum, true)
  GUIUtils.SetText(Label_PowerNum, score)
  local Group_UpDown = groupScore:FindDirect("Group_UpDown")
  GUIUtils.SetActive(Group_UpDown, isTweening)
end
def.static("userdata", "number", "number").TweenYouthChildScore = function(groupScore, from, to)
  if groupScore == nil or groupScore.isnil then
    return
  end
  local isTweening = true
  local duration = 1.5
  local lastScore = -1
  local t = 0
  local function tick(param, dt)
    if groupScore.isnil or not groupScore.activeInHierarchy then
      isTweening = false
      ChildrenUtils.SetYouthChildScoreUI(groupScore, to, false)
      Timer:RemoveIrregularTimeListener(tick)
      return
    end
    t = t + dt
    if t > duration then
      t = duration
    end
    local rt = t / duration
    local val = rt
    if val == 1 then
      Timer:RemoveIrregularTimeListener(tick)
      isTweening = false
    end
    local score = math.floor((1 - val) * from + to * val)
    if lastScore ~= score or not isTweening then
      lastScore = score
      ChildrenUtils.SetYouthChildScoreUI(groupScore, score, isTweening)
    end
  end
  local GUIUtils = require("GUI.GUIUtils")
  local Group_UpDown = groupScore:FindDirect("Group_UpDown")
  if Group_UpDown then
    Group_UpDown:SetActive(true)
    local isGreen = from < to
    local isRed = not isGreen
    GUIUtils.SetActive(GUIUtils.FindDirect(Group_UpDown, "Img_ArrowRed"), isRed)
    local Label_Red = GUIUtils.FindDirect(Group_UpDown, "Label_Red")
    GUIUtils.SetActive(Label_Red, isRed)
    GUIUtils.SetActive(GUIUtils.FindDirect(Group_UpDown, "Img_ArrowGreen"), isGreen)
    local Label_Green = GUIUtils.FindDirect(Group_UpDown, "Label_Green")
    GUIUtils.SetActive(Label_Green, isGreen)
    local label = isGreen and Label_Green or Label_Red
    if isGreen then
      local text = string.format(textRes.Pet[128], to - from)
      GUIUtils.SetText(Label_Green, text)
    else
      local text = string.format(textRes.Pet[129], from - to)
      GUIUtils.SetText(Label_Red, text)
    end
  end
  ChildrenUtils.SetYouthChildScoreUI(groupScore, from, isTweening)
  Timer:RegisterIrregularTimeListener(tick, nil)
end
ChildrenUtils.Commit()
return ChildrenUtils
