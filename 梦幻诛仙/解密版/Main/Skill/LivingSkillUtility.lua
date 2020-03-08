local Lplus = require("Lplus")
local LivingSkillUtility = Lplus.Class("LivingSkillUtility")
local Vector = require("Types.Vector")
local def = LivingSkillUtility.define
def.static("string", "=>", "number").GetLivingSkillConst = function(name)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_LIVING_SKILL_CONST_CFG, name)
  return DynamicRecord.GetIntValue(record, "value")
end
def.static("string", "=>", "number").GetMakeDrugConst = function(name)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_LIVING_SKILL_MAKE_DRUG_CFG, name)
  return DynamicRecord.GetIntValue(record, "value")
end
def.static("number", "number", "=>", "number").GetCostVigor = function(skillBagId, level)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_LIVING_SKILL_VIGOR_COST_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local skillBagCfgId = DynamicRecord.GetIntValue(entry, "skillBagCfgId")
    local minLevel = DynamicRecord.GetIntValue(entry, "minLevel")
    local maxLevel = DynamicRecord.GetIntValue(entry, "maxLevel")
    if skillBagId == skillBagCfgId and level >= minLevel and level <= maxLevel then
      local costVigor = DynamicRecord.GetIntValue(entry, "costVigor")
      DynamicDataTable.FastGetRecordEnd(entries)
      return costVigor
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return 0
end
def.static("userdata", "userdata", "number", "string").CreateNewGroup = function(groupNew, gridTemplate, count, name)
  groupNew:set_name(string.format(name, count))
  groupNew.parent = gridTemplate
  groupNew:set_localScale(Vector.Vector3.one)
  groupNew:SetActive(true)
end
def.static("number", "string", "userdata").DeleteLastGroup = function(listNum, groupName, gridTemplate)
  local template = gridTemplate:GetChild(listNum)
  Object.DestroyImmediate(template)
  template = nil
end
def.static("number", "string", "userdata", "userdata").AddLastGroup = function(listNum, groupName, gridTemplate, groupTemplate)
  local groupNew = Object.Instantiate(groupTemplate)
  LivingSkillUtility.CreateNewGroup(groupNew, gridTemplate, listNum, groupName)
end
def.static("number", "number", "=>", "number", "number").GetLevelUpInfo = function(levelUpTypeId, level)
  local key = levelUpTypeId * 1000 + level
  local record = DynamicData.GetRecord(CFG_PATH.DATA_LIVING_SKILL_LEVEL_UP_CFG, key)
  if record then
    return record:GetIntValue("needSilver"), record:GetIntValue("needBanggong")
  end
  return 0, 0
end
def.static("number", "number", "number", "=>", "number", "number").GetTotalLevelUpInfo = function(levelUpTypeId, from, to)
  local needSilver = 0
  local needBanggong = 0
  for i = from, to - 1 do
    local silver, banggong = LivingSkillUtility.GetLevelUpInfo(levelUpTypeId, i)
    needSilver = needSilver + silver
    needBanggong = needBanggong + banggong
  end
  return needSilver, needBanggong
end
def.static("number", "=>", "table").GetEnchantingPropInfo = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ENCHANTING_PROP_CFG, itemId)
  if record == nil then
    warn("GetEnchantingPropInfo(" .. itemId .. ") return nil")
    return nil
  end
  local skillCfg = {}
  skillCfg.id = record:GetIntValue("id")
  skillCfg.extraProperty = record:GetIntValue("extraProperty")
  skillCfg.wearPos = record:GetIntValue("wearPos")
  skillCfg.minProNum = record:GetIntValue("minProNum")
  skillCfg.maxProNum = record:GetIntValue("maxProNum")
  skillCfg.bufftime = record:GetIntValue("wearPos")
  skillCfg.drugPro = record:GetIntValue("drugPro")
  return skillCfg
end
def.static("number", "=>", "table").GetBaoShiDuItemInfo = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BAOSHIDU_ITEM_CFG, itemId)
  if record == nil then
    warn("GetBaoShiDuItemInfo(" .. itemId .. ") return nil")
    return nil
  end
  local skillCfg = {}
  skillCfg.id = record:GetIntValue("id")
  skillCfg.baoshiduNum = record:GetIntValue("baoshiduNum")
  skillCfg.drugPro = record:GetIntValue("drugPro")
  skillCfg.siftcfgid = record:GetIntValue("siftcfgid")
  skillCfg.itemdesc = record:GetStringValue("itemdesc")
  return skillCfg
end
def.static("number", "=>", "table").GetInFightDrugItemInfo = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DRUG_IN_FIGHT_CFG, itemId)
  if record == nil then
    warn("GetInFightDrugItemInfo(" .. itemId .. ") return nil")
    return nil
  end
  local skillCfg = {}
  skillCfg.id = record:GetIntValue("id")
  skillCfg.skillEffectGroupId = record:GetIntValue("skillEffectGroupId")
  skillCfg.targettype1 = record:GetIntValue("targettype1")
  skillCfg.targettype2 = record:GetIntValue("targettype2")
  skillCfg.targettype3 = record:GetIntValue("targettype3")
  skillCfg.targettype4 = record:GetIntValue("targettype4")
  skillCfg.fun = record:GetIntValue("fun")
  skillCfg.drugPro = record:GetIntValue("drugPro")
  skillCfg.itemdesc = record:GetStringValue("itemdesc")
  return skillCfg
end
def.static("number", "=>", "table").GetYaoCaiInfo = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DRUG_ITEM_CFG, itemId)
  if record == nil then
    warn("GetInFightDrugItemInfo(" .. itemId .. ") return nil")
    return nil
  end
  local yaocaiCfg = {}
  yaocaiCfg.id = record:GetIntValue("id")
  yaocaiCfg.skillEffectGroupId = record:GetIntValue("skillEffectGroupId")
  yaocaiCfg.targettype1 = record:GetIntValue("targettype1")
  yaocaiCfg.targettype2 = record:GetIntValue("targettype2")
  yaocaiCfg.targettype3 = record:GetIntValue("targettype3")
  yaocaiCfg.targettype4 = record:GetIntValue("targettype4")
  yaocaiCfg.itemdesc = record:GetStringValue("itemdesc")
  return yaocaiCfg
end
def.static("number", "=>", "table").GetDrugInfo = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ENCHANTING_PROP_CFG, itemId)
  if record == nil then
    warn("GetDrugInfo(" .. itemId .. ") return nil")
    return nil
  end
  local skillCfg = {}
  skillCfg.id = record:GetIntValue("id")
  skillCfg.skillEffectGroupId = record:GetIntValue("skillEffectGroupId")
  skillCfg.targettype1 = record:GetIntValue("targettype1")
  skillCfg.targettype2 = record:GetIntValue("targettype2")
  skillCfg.targettype3 = record:GetIntValue("targettype3")
  skillCfg.targettype4 = record:GetIntValue("targettype4")
  return skillCfg
end
def.static("number", "=>", "table").GetPetLifeItemInfo = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ENCHANTING_PROP_CFG, itemId)
  if record == nil then
    warn("GetPetLifeItemInfo(" .. itemId .. ") return nil")
    return nil
  end
  local skillCfg = {}
  skillCfg.id = record:GetIntValue("id")
  skillCfg.petMinLifeLimit = record:GetIntValue("petMinLifeLimit")
  skillCfg.petMaxLifeLimit = record:GetIntValue("petMaxLifeLimit")
  skillCfg.drugPro = record:GetIntValue("drugPro")
  return skillCfg
end
def.static("number").ToastGetItem = function(itemId)
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemName = ItemUtils.GetItemBase(itemId).name
  Toast(string.format(textRes.Skill[53], itemName))
end
def.static("number", "number").ToastGetItemWithNums = function(itemId, nums)
  local ItemUtils = require("Main.Item.ItemUtils")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local itemBase = ItemUtils.GetItemBase(itemId)
  local itemName = itemBase.name
  local itemcolor = HtmlHelper.NameColor[itemBase.namecolor]
  Toast(string.format(textRes.Skill[75], itemcolor, itemName, nums))
end
return LivingSkillUtility.Commit()
