local Lplus = require("Lplus")
local FormationUtils = Lplus.Class("FormationUtils")
local def = FormationUtils.define
local formations
local function LoadformationCfg()
  formations = {}
  local formationsEntries = DynamicData.GetTable(CFG_PATH.DATA_FORMATION_CFG)
  local count = DynamicDataTable.GetRecordsCount(formationsEntries)
  DynamicDataTable.FastGetRecordBegin(formationsEntries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(formationsEntries, i)
    local formationInfo = {}
    formationInfo.id = record:GetIntValue("id")
    formationInfo.name = record:GetStringValue("name")
    formationInfo.icon = record:GetIntValue("icon")
    formationInfo.backIcon = record:GetIntValue("backIcon")
    local effectStruct = record:GetStructValue("EffectStruct")
    local effectCount = effectStruct:GetVectorSize("EffectVector")
    formationInfo.effectInfo = {}
    for i = 0, effectCount - 1 do
      local item = effectStruct:GetVectorValueByIdx("EffectVector", i)
      local effectInfo = {}
      effectInfo.AEffect = item:GetIntValue("AEffect")
      effectInfo.AGrow = item:GetIntValue("AGrow")
      effectInfo.AInit = item:GetIntValue("AInit")
      effectInfo.BEffect = item:GetIntValue("BEffect")
      effectInfo.BGrow = item:GetIntValue("BGrow")
      effectInfo.BInit = item:GetIntValue("BInit")
      formationInfo.effectInfo[i + 1] = effectInfo
    end
    local KZStruct = record:GetStructValue("KZStruct")
    local KZCount = KZStruct:GetVectorSize("KZVector")
    formationInfo.KZInfo = {}
    for i = 0, KZCount - 1 do
      local item = KZStruct:GetVectorValueByIdx("KZVector", i)
      local effectInfo = {}
      effectInfo.EffectId = item:GetIntValue("EffectId")
      effectInfo.FormationId = item:GetIntValue("FormationId")
      effectInfo.value = item:GetIntValue("value")
      formationInfo.KZInfo[effectInfo.FormationId] = effectInfo
    end
    local BKStruct = record:GetStructValue("BKStruct")
    local BKCount = BKStruct:GetVectorSize("BKVector")
    formationInfo.BKInfo = {}
    for i = 0, KZCount - 1 do
      local item = BKStruct:GetVectorValueByIdx("BKVector", i)
      local effectInfo = {}
      effectInfo.EffectId = item:GetIntValue("EffectId")
      effectInfo.FormationId = item:GetIntValue("FormationId")
      effectInfo.value = item:GetIntValue("value")
      formationInfo.BKInfo[effectInfo.FormationId] = effectInfo
    end
    formations[formationInfo.id] = formationInfo
  end
  DynamicDataTable.FastGetRecordEnd(formationsEntries)
end
def.static("number", "=>", "table").GetFormationCfg = function(formationId)
  if formations == nil then
    LoadformationCfg()
  end
  return formations[formationId]
end
def.static("=>", "table").GetAllFormations = function()
  if formations == nil then
    LoadformationCfg()
  end
  return formations
end
local formationConst
local function LoadFormationConst()
  formationConst = {}
  formationConst.initLevel = DynamicData.GetRecord(CFG_PATH.DATA_FORMATION_CONST, "INIT_LEVEL"):GetIntValue("value")
  formationConst.maxLevel = DynamicData.GetRecord(CFG_PATH.DATA_FORMATION_CONST, "MAX_LEVEL"):GetIntValue("value")
  formationConst.LevelUpExp = {}
  formationConst.LevelUpExp[1] = DynamicData.GetRecord(CFG_PATH.DATA_FORMATION_CONST, "UP_TO_LEVEL2_NEED_EXPNUM"):GetIntValue("value")
  formationConst.LevelUpExp[2] = DynamicData.GetRecord(CFG_PATH.DATA_FORMATION_CONST, "UP_TO_LEVEL3_NEED_EXPNUM"):GetIntValue("value")
  formationConst.LevelUpExp[3] = DynamicData.GetRecord(CFG_PATH.DATA_FORMATION_CONST, "UP_TO_LEVEL4_NEED_EXPNUM"):GetIntValue("value")
  formationConst.LevelUpExp[4] = DynamicData.GetRecord(CFG_PATH.DATA_FORMATION_CONST, "UP_TO_LEVEL5_NEED_EXPNUM"):GetIntValue("value")
  formationConst.LevelUpTip = DynamicData.GetRecord(CFG_PATH.DATA_FORMATION_CONST, "TIPS_OF_LEVEL_UP"):GetIntValue("value")
end
def.static("=>", "table").GetFormationConst = function()
  if formationConst == nil then
    LoadFormationConst()
  end
  return formationConst
end
local FormationToItem
local function LoadFormationBook()
  FormationToItem = {}
  local bookEntry = DynamicData.GetTable(CFG_PATH.DATA_FORMATIONBOOK_CFG)
  local count = DynamicDataTable.GetRecordsCount(bookEntry)
  DynamicDataTable.FastGetRecordBegin(bookEntry)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(bookEntry, i)
    local itemId = record:GetIntValue("id")
    local formationId = record:GetIntValue("formationId")
    FormationToItem[formationId] = itemId
  end
  DynamicDataTable.FastGetRecordEnd(bookEntry)
end
def.static("number", "=>", "number").GetNeedBook = function(formationId)
  if FormationToItem == nil then
    LoadFormationBook()
  end
  return FormationToItem[formationId]
end
def.static("number", "number", "=>", "number").CalcAddExp = function(itemId, formationId)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(itemId)
  local addExp = 1
  if itemBase.itemType == ItemType.ZHENFA_ITEM then
    local record = DynamicData.GetRecord(CFG_PATH.DATA_FORMATIONBOOK_CFG, itemBase.itemid)
    local fid = record:GetIntValue("formationId")
    if fid == formationId then
      addExp = record:GetIntValue("extraexp") + record:GetIntValue("exp")
    else
      addExp = record:GetIntValue("exp")
    end
  elseif itemBase.itemType == ItemType.ZHENFA_FRAGMENT_ITEM then
    local record = DynamicData.GetRecord(CFG_PATH.DATA_FORMATIONFRAGMENT_CFG, itemBase.itemid)
    addExp = record:GetIntValue("exp")
  end
  return addExp
end
def.static("number", "number", "=>", "number").MaxLevelNeedExp = function(level, curExp)
  local exp = 0
  for i = level, formationConst.maxLevel - 1 do
    exp = exp + formationConst.LevelUpExp[i]
  end
  return exp - curExp
end
FormationUtils.Commit()
return FormationUtils
