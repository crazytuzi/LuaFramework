local Lplus = require("Lplus")
local EquipUtils = require("Main.Equip.EquipUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local LivingSkillData = require("Main.Skill.data.LivingSkillData")
local XianLvInterface = require("Main.partner.PartnerInterface")
local BaodianUtils = Lplus.Class("BaodianUtils")
local def = BaodianUtils.define
local mBaodianGuideCfg, mAllEquipCfg
def.static("=>", "number").GetBaodianOpenLevel = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BAODIAN_CONST_CFG, "OPEN_LEVEL")
  if record == nil then
    warn("GetBaodianConst OPEN_LEVEL failed..")
    return -1
  end
  return record:GetIntValue("value")
end
def.static("string", "=>", "string").GetBaodianDescByName = function(name)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BAODIAN_CONST_CFG, name)
  if record == nil then
    warn("GetBaodianDescByName  failed..")
    return -1
  end
  local id = record:GetIntValue("value")
  local record2 = DynamicData.GetRecord(CFG_PATH.DATA_HOVER_TIP_CFG, id)
  if record2 == nil then
    return textRes.Grow[71]
  end
  local desc = record2:GetStringValue("tipcontent")
  local desc = string.gsub(desc, "\\n", "\n")
  local desc = string.gsub(desc, "/n", "\n")
  return desc
end
def.static("=>", "table").GetBaodianGuideCfg = function()
  if mBaodianGuideCfg ~= nil then
    return mBaodianGuideCfg
  end
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_BAODIAN_GUIDE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  mBaodianGuideCfg = {}
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.templateName = record:GetStringValue("templateName")
    cfg.cfgName = record:GetIntValue("cfgName")
    cfg.typeNameStr = record:GetStringValue("typeNameStr")
    cfg.sort = record:GetIntValue("sort")
    table.insert(mBaodianGuideCfg, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return mBaodianGuideCfg
end
def.static("=>", "table").GetBaodianTypeName = function()
  local records = BaodianUtils.GetBaodianGuideCfg()
  if records == nil or #records == 0 then
    return nil
  end
  local count = #records
  local names = {}
  for k, v in pairs(records) do
    local name = v.typeNameStr
    names[k] = name
  end
  return names
end
def.static("=>", "table").GetEquipAllCfg = function()
  if mAllEquipCfg ~= nil then
    return mAllEquipCfg
  end
  local allEntry = DynamicData.GetTable(CFG_PATH.DATA_BAODIAN_EQUIP_CFG)
  local count = DynamicDataTable.GetRecordsCount(allEntry)
  mAllEquipCfg = {}
  DynamicDataTable.FastGetRecordBegin(allEntry)
  for i = 0, count - 1 do
    local cfg = {}
    local record = DynamicDataTable.FastGetRecordByIdx(allEntry, i)
    local selectId = record:GetIntValue("selectId")
    local selectName = record:GetStringValue("selectName")
    local equipId = record:GetIntValue("equipId")
    local equipRange = record:GetIntValue("equipRange")
    local npcId = record:GetIntValue("npcId")
    local serverLevel = record:GetIntValue("needServerLevel")
    local id = record:GetIntValue("id")
    if mAllEquipCfg[selectId] then
      local equips = mAllEquipCfg[selectId].equips
      local equip = {}
      equip.equipId = equipId
      equip.npcId = npcId
      equip.id = id
      table.insert(equips, equip)
    else
      cfg.selectName = selectName
      cfg.selectLevel = serverLevel
      cfg.equips = {}
      local equipInfo = {}
      equipInfo.id = id
      equipInfo.equipId = equipId
      equipInfo.npcId = npcId
      table.insert(cfg.equips, equipInfo)
      mAllEquipCfg[selectId] = cfg
    end
  end
  DynamicDataTable.FastGetRecordEnd(allEntry)
  for k, v in pairs(mAllEquipCfg) do
    local equips = v.equips
    table.sort(equips, function(l, r)
      return l.id < r.id
    end)
  end
  return mAllEquipCfg
end
def.static("=>", "table").GetAllSelectIdAndName = function()
  local equipCfg = BaodianUtils.GetEquipAllCfg()
  if equipCfg == nil then
    return nil
  end
  local curServerLevel = require("Main.Server.Interface").GetServerLevelInfo().level
  local tb = {}
  for k, v in pairs(equipCfg) do
    if curServerLevel >= v.selectLevel then
      local selectName = v.selectName
      tb[k] = selectName
    end
  end
  return tb
end
def.static("number", "=>", "table").GetAllEquipIdBySelectId = function(selectId)
  local equipCfg = BaodianUtils.GetEquipAllCfg()
  if equipCfg == nil then
    return nil
  end
  if selectId == 0 then
    return BaodianUtils.GetAllEquipIds()
  end
  local equipIds = {}
  local equips = BaodianUtils.GetEquipsBySelectId(selectId)
  for k, v in pairs(equips.equips) do
    table.insert(equipIds, v.equipId)
  end
  return equipIds
end
def.static("=>", "table").GetAllEquipIds = function()
  local equipCfg = BaodianUtils.GetEquipAllCfg()
  if equipCfg == nil then
    return nil
  end
  local allEquips = {}
  for k, v in pairs(equipCfg) do
    local equips = v.equips
    for k2, v2 in pairs(equips) do
      table.insert(allEquips, v2.equipId)
    end
  end
  return allEquips
end
def.static("number", "number", "=>", "number").GetNpcId = function(selectId, equipId)
  local equipCfg = BaodianUtils.GetEquipAllCfg()
  if selectId == 0 then
    selectId = 1
  end
  local equipInfo = equipCfg[selectId].equips
  for k, v in pairs(equipInfo) do
    if v.equipId == equipId then
      return v.npcId
    end
  end
  return equipInfo[1].npcId
end
def.static("number", "=>", "table").GetEquipsBySelectId = function(selectId)
  local equipCfg = BaodianUtils.GetEquipAllCfg()
  if equipCfg == nil then
    return nil
  end
  return equipCfg[selectId]
end
def.static("number", "=>", "table", "table", "string").GetEquipDetaiInfo = function(equipId)
  local equipInfo = EquipUtils.GetEquipDetailsInfo(equipId)
  local lingNameStr, lingAttrStr, hunNameStr, hunAttrStr, hunRanNum = EquipUtils.GetEquipMakePreviewContent(equipInfo)
  local ling = string.split(lingNameStr, "\n")
  local lingAttr = string.split(lingAttrStr, "\n")
  local hun = string.split(hunNameStr, "\n")
  local hunAttr = string.split(hunAttrStr, "\n")
  local lingCount = #ling
  local lingTable = {}
  for i = 1, lingCount do
    lingTable[i] = {}
    table.insert(lingTable[i], ling[i])
    table.insert(lingTable[i], lingAttr[i])
  end
  local hunTable = {}
  local hunCount = #hun
  for i = 1, hunCount do
    hunTable[i] = {}
    table.insert(hunTable[i], hun[i])
    table.insert(hunTable[i], hunAttr[i])
  end
  return lingTable, hunTable, hunRanNum
end
def.static("number", "=>", "string").GetNPCShopName = function(npcId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_NPC_CONFIG, npcId)
  if record == nil then
    return textRes.Grow[5]
  end
  local shopName = record:GetStringValue("npcTitle")
  return shopName
end
local skillCfg
def.static("=>", "table").GetAllSkillCfg = function()
  if skillCfg ~= nil then
    return skillCfg
  end
  skillCfg = {}
  skillCfg[1] = {}
  skillCfg[2] = {}
  skillCfg[3] = {}
  skillCfg[4] = {}
  skillCfg[5] = {}
  local allEntry = DynamicData.GetTable(CFG_PATH.DATA_BAODIAN_SKILL_CFG)
  local count = DynamicDataTable.GetRecordsCount(allEntry)
  local getIndex = function(selectId)
    if selectId < 100 then
      return 1
    elseif selectId < 200 then
      return 2
    elseif selectId < 300 then
      return 3
    else
      return 4
    end
  end
  DynamicDataTable.FastGetRecordBegin(allEntry)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(allEntry, i)
    local selectId = record:GetIntValue("selectId")
    local index = getIndex(selectId)
    if skillCfg[index][0] == nil then
      skillCfg[index][0] = record:GetStringValue("skillTypeName")
    end
    if skillCfg[index][selectId] == nil then
      skillCfg[index][selectId] = {}
      local cache = skillCfg[index][selectId]
      local selectName = record:GetStringValue("selectName")
      cache.selectName = selectName
      local ids = {}
      local names = {}
      local skillId = record:GetIntValue("skillId")
      local skillName = record:GetStringValue("skillName")
      table.insert(ids, skillId)
      table.insert(names, skillName)
      cache.skillIds = ids
      cache.skillNames = names
    else
      local skillId = record:GetIntValue("skillId")
      local skillName = record:GetStringValue("skillName")
      table.insert(skillCfg[index][selectId].skillIds, skillId)
      table.insert(skillCfg[index][selectId].skillNames, skillName)
    end
  end
  DynamicDataTable.FastGetRecordEnd(allEntry)
  return skillCfg
end
def.static("number", "=>", "table").GetSkillTypeTable = function(skillType)
  local skillCfg = BaodianUtils.GetAllSkillCfg()
  if skillCfg == nil then
    return nil
  end
  return skillCfg[skillType]
end
def.static("number", "number", "=>", "table").GetSkillTypeTableBySelectId = function(skilltype, selectId)
  local skillTypeCfg = BaodianUtils.GetSkillTypeTable(skilltype)
  if skillTypeCfg == nil then
    return nil
  end
  local skills = {}
  skills.skillIds = {}
  skills.skillNames = {}
  if selectId == 0 then
    for k, v in pairs(skillTypeCfg) do
      if k ~= 0 then
        local ids = v.skillIds
        local names = v.skillNames
        local count = #ids
        for i = 1, count do
          table.insert(skills.skillIds, ids[i])
          table.insert(skills.skillNames, names[i])
        end
      end
    end
    table.sort(skills.skillIds, function(a, b)
      return a < b
    end)
    return skills
  end
  return skillTypeCfg[selectId]
end
local cacheNames = {}
def.static("number", "=>", "table").GetSkillSelectNamesByType = function(type)
  if cacheNames[type] ~= nil then
    return cacheNames[type]
  end
  local skillTypeCfg = BaodianUtils.GetSkillTypeTable(type)
  if skillTypeCfg == nil then
    return nil
  end
  local names = {}
  for k, v in pairs(skillTypeCfg) do
    if k ~= 0 then
      table.insert(names, v.selectName)
    end
  end
  cacheNames[type] = names
  return names
end
local cacheNameEx = {}
def.static("number", "table", "=>", "table").GetGetSkillSelectNamesByTypeEx = function(nodetype, selectIds)
  if cacheNameEx[nodetype] ~= nil then
    return cacheNameEx[nodetype]
  end
  local skillTypeCfg = BaodianUtils.GetSkillTypeTable(nodetype)
  local names = {}
  for _, v in pairs(selectIds) do
    if v ~= 0 then
      local selectName = skillTypeCfg[v].selectName
      table.insert(names, selectName)
    end
  end
  cacheNameEx[nodetype] = names
  return names
end
def.static("number", "number", "=>", "table", "table").GetSkillIdsAndNamesBySelectId = function(type, selectId)
  local skillCfg = BaodianUtils.GetSkillTypeTableBySelectId(type, selectId)
  if skillCfg == nil then
    return nil, nil
  end
  return skillCfg.skillIds, skillCfg.skillNames
end
local cacheSelectIds = {}
def.static("number", "=>", "table").GetAllSelectIdByType = function(type)
  if cacheSelectIds[type] ~= nil then
    return cacheSelectIds[type]
  end
  local skillTypeCfg = BaodianUtils.GetSkillTypeTable(type)
  if skillTypeCfg == nil then
    return nil
  end
  local selects = {}
  for k, v in pairs(skillTypeCfg) do
    if k ~= 0 then
      table.insert(selects, k)
    end
  end
  table.sort(selects, function(leftId, rightId)
    return leftId < rightId
  end)
  cacheSelectIds[type] = selects
  return selects
end
def.static("number", "number", "number", "=>", "string").GetMeiPaiName = function(type, selectId, skillId)
  local skillCfg = BaodianUtils.GetAllSkillCfg()
  if skillCfg == nil then
    return " "
  end
  local typeCfg = skillCfg[type]
  if selectId ~= 0 then
    return typeCfg[selectId].selectName
  end
  for k, v in pairs(typeCfg) do
    if k ~= 0 then
      for _, id in pairs(v.skillIds) do
        if id == skillId then
          return v.selectName
        end
      end
    end
  end
  return " "
end
local petbookCfg
def.static("=>", "table").GetPetBookAllCfg = function()
  if petbookCfg ~= nil then
    return petbookCfg
  end
  local allEntry = DynamicData.GetTable(CFG_PATH.DATA_PET_SKILL_BOOK_ITEM_CFG)
  local count = DynamicDataTable.GetRecordsCount(allEntry)
  petbookCfg = {}
  DynamicDataTable.FastGetRecordBegin(allEntry)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(allEntry, i)
    if record ~= nil then
      local itemId = record:GetIntValue("id")
      local skillId = record:GetIntValue("skillId")
      petbookCfg[skillId] = itemId
    end
  end
  DynamicDataTable.FastGetRecordEnd(allEntry)
  return petbookCfg
end
def.static("number", "=>", "number").GetSkillBookItem = function(skillId)
  local skillBookCfg = BaodianUtils.GetPetBookAllCfg()
  if skillBookCfg == nil then
    return 0
  end
  return skillBookCfg[skillId] and skillBookCfg[skillId] or 0
end
local ShowType = require("consts.mzm.gsp.skill.confbean.LifeSkillBagShowTypeEnum")
local PengRenCfg
def.static("=>", "table").GetPengRenCfg = function()
  if PengRenCfg ~= nil then
    return PengRenCfg
  end
  local allDataCfg = LivingSkillData.Instance():GetBagList()
  if allDataCfg == nil then
    return nil
  end
  warn("GetPengRenCfg.....", allDataCfg, #allDataCfg)
  local cfg = {}
  for _, v in pairs(allDataCfg) do
    if v.showType == ShowType.type2 and v.itemIdList then
      for _, v2 in pairs(v.itemIdList) do
        local itemcfg = {}
        itemcfg.id = v2.id
        itemcfg.openLevel = v2.openLevel
        local itembase
        if v2.bItem then
          itembase = ItemUtils.GetItemBase(v2.id)
        else
          itembase = ItemUtils.GetItemFilterCfg(v2.id)
        end
        itemcfg.iconId = itembase.icon
        itemcfg.desc = itembase.desc
        itemcfg.name = itembase.name
        itemcfg.effect = itembase.effect
        table.insert(cfg, itemcfg)
      end
    end
  end
  table.sort(cfg, function(l, r)
    return l.openLevel < r.openLevel
  end)
  PengRenCfg = cfg
  return cfg
end
def.static("number", "string", "=>", "table").GetCfgById = function(id, ctype)
  if ctype == "pengren" then
    local prCfg = BaodianUtils.GetPengRenCfg()
    for _, v in pairs(prCfg) do
      if v.id == id then
        return v
      end
    end
    return prCfg[1]
  else
    local lyCfg = BaodianUtils.GetLianYaoCfg()
    for _, v in pairs(lyCfg) do
      if v.id == id then
        return v
      end
    end
    return lyCfg[1]
  end
end
local LianYaoCfg
def.static("=>", "table").GetLianYaoCfg = function()
  if LianYaoCfg ~= nil then
    return LianYaoCfg
  end
  local allDataCfg = LivingSkillData.Instance():GetBagList()
  if allDataCfg == nil then
    return nil
  end
  local cfg = {}
  for _, v in pairs(allDataCfg) do
    if v.showType == ShowType.type3 and v.itemIdList then
      for _, v2 in pairs(v.itemIdList) do
        local itemcfg = {}
        itemcfg.id = v2.id
        itemcfg.openLevel = v2.openLevel
        local itembase
        if v2.bItem then
          itembase = ItemUtils.GetItemBase(v2.id)
        else
          itembase = ItemUtils.GetItemFilterCfg(v2.id)
        end
        itemcfg.iconId = itembase.icon
        itemcfg.desc = itembase.desc
        itemcfg.name = itembase.name
        itemcfg.effect = itembase.effect
        table.insert(cfg, itemcfg)
      end
    end
  end
  table.sort(cfg, function(l, r)
    return l.openLevel < r.openLevel
  end)
  LianYaoCfg = cfg
  return cfg
end
local wingViewItemList
def.static("=>", "table").GetAllWingViewItemId = function()
  if wingViewItemList ~= nil then
    return wingViewItemList
  end
  local itemList = {}
  local allEntry = DynamicData.GetTable(CFG_PATH.DATA_WING_VIEW_ITEM)
  local count = DynamicDataTable.GetRecordsCount(allEntry)
  DynamicDataTable.FastGetRecordBegin(allEntry)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(allEntry, i)
    local itemId = record:GetIntValue("id")
    table.insert(itemList, itemId)
  end
  DynamicDataTable.FastGetRecordEnd(allEntry)
  wingViewItemList = itemList
  return itemList
end
local wingMainSkillIds, wingMainSkillNames
def.static("=>", "table", "table").GetAllWingsSkillInfo = function()
  if wingMainSkillNames ~= nil and wingMainSkillIds ~= nil then
    return wingMainSkillIds, wingMainSkillNames
  end
  wingMainSkillIds = {}
  wingMainSkillNames = {}
  local allEntry = DynamicData.GetTable(CFG_PATH.DATA_WINGS_SKILLS_LIB)
  local count = DynamicDataTable.GetRecordsCount(allEntry)
  DynamicDataTable.FastGetRecordBegin(allEntry)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(allEntry, i)
    local mainSkill1 = record:GetIntValue("mainSkillId1")
    local mainSkill2 = record:GetIntValue("mainSkillId2")
    table.insert(wingMainSkillIds, mainSkill1)
    table.insert(wingMainSkillIds, mainSkill2)
  end
  DynamicDataTable.FastGetRecordEnd(allEntry)
  return wingMainSkillIds, wingMainSkillNames
end
local xianlvCfg
def.static("=>", "table").GetAllXianLvCfg = function()
  if xianlvCfg ~= nil then
    return xianlvCfg
  end
  local allCfg = XianLvInterface.Instance():GetPartnerCfgsList()
  if allCfg == nil then
    return nil
  end
  warn("GetAllXianLvCfg..", #allCfg)
  xianlvCfg = {}
  for k, v in pairs(allCfg) do
    local id = v.id
    local cache = {}
    cache.id = id
    cache.name = v.name
    cache.faction = GetOccupationName(v.faction)
    local modelinfo = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, v.modelId)
    local headidx = DynamicRecord.GetIntValue(modelinfo, "headerIconId")
    if headidx == 0 then
      headidx = 3002
    end
    cache.headIconId = headidx
    cache.unlockLevel = v.unlockLevel
    cache.unlockItem = v.unlockItem
    cache.unlockItemNum = v.unlockItemNum
    cache.unlockItemId = v.unlockItemId
    cache.skillCfgList = {}
    local skillList = v.skillIds
    for _, v in pairs(skillList) do
      local skillCfg = XianLvInterface.GetPartnerSkillCfg(v).skillCfg
      table.insert(cache.skillCfgList, skillCfg)
    end
    table.insert(xianlvCfg, cache)
  end
  table.sort(xianlvCfg, function(l, r)
    return l.unlockLevel < r.unlockLevel
  end)
  return xianlvCfg
end
def.static("number", "=>", "table").GetXianLvCfg = function(id)
  local allcfg = BaodianUtils.GetAllXianLvCfg()
  if allcfg == nil then
    return nil
  end
  for k, v in pairs(allcfg) do
    if v.id == id then
      return v
    end
  end
  return nil
end
def.static("=>", "table").GetAllEquipSkillCfg = function()
  local equipSkillCfg = {}
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_GROW_EQUIP_SKILL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    if record then
      local equipSkillId = record:GetIntValue("equipSkillId")
      table.insert(equipSkillCfg, equipSkillId)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  table.sort(equipSkillCfg, function(l, r)
    return l < r
  end)
  return equipSkillCfg
end
BaodianUtils.Commit()
return BaodianUtils
