local Lplus = require("Lplus")
local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local PetUtility = require("Main.Pet.PetUtility")
local BreakOutData = Lplus.Class("BreakOutData")
local def = BreakOutData.define
local _instance
def.static("=>", BreakOutData).Instance = function()
  if _instance == nil then
    _instance = BreakOutData()
  end
  return _instance
end
def.const("table").RELATED_BAGS = {
  BagInfo.BAG,
  BagInfo.EQUIPBAG
}
def.field("table")._stageCfg = nil
def.field("table")._equipTypeLevelCfg = nil
def.field("table")._stageMaxLevelCfg = nil
def.method().Init = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._stageCfg = nil
  self._equipTypeLevelCfg = nil
  self._stageMaxLevelCfg = nil
end
def.method()._LoadStageCfg = function(self)
  warn("[BreakOutData:_LoadStageCfg] start Load stageCfg!")
  self._stageCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_GOD_WEAPON_BREAKOUT_STAGE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local stageCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    stageCfg.stage = DynamicRecord.GetIntValue(entry, "stage")
    stageCfg.namePrefix = DynamicRecord.GetStringValue(entry, "namePrefix")
    stageCfg.colorFrameId = DynamicRecord.GetIntValue(entry, "colorFrameId")
    stageCfg.maxStrengthLevel = DynamicRecord.GetIntValue(entry, "maxStrengthLevel")
    stageCfg.maxGemLevel = DynamicRecord.GetIntValue(entry, "maxGemLevel")
    stageCfg.gemSlotNum = DynamicRecord.GetIntValue(entry, "gemSlotNum")
    stageCfg.requiredLevel = DynamicRecord.GetIntValue(entry, "requiredLevel")
    stageCfg.requiredEquipmentQuality = DynamicRecord.GetIntValue(entry, "requiredEquipmentQuality")
    stageCfg.requiredEquipmentLevel = DynamicRecord.GetIntValue(entry, "requiredEquipmentLevel")
    stageCfg.requiredStrengthLevel = DynamicRecord.GetIntValue(entry, "requiredStrengthLevel")
    stageCfg.requiredRoleLevel = DynamicRecord.GetIntValue(entry, "requiredRoleLevel")
    stageCfg.requiredServerLevel = DynamicRecord.GetIntValue(entry, "requiredServerLevel")
    stageCfg.requiredCurrencyType = DynamicRecord.GetIntValue(entry, "requiredCurrencyType")
    stageCfg.requiredCurrencyNum = DynamicRecord.GetIntValue(entry, "requiredCurrencyNum")
    stageCfg.costItems = {}
    local struct = entry:GetStructValue("requiredItemsStruct")
    local count = struct:GetVectorSize("requiredItemsList")
    for i = 1, count do
      local itemInfo = {}
      local record = struct:GetVectorValueByIdx("requiredItemsList", i - 1)
      itemInfo.id = record:GetIntValue("id")
      itemInfo.num = record:GetIntValue("num")
      table.insert(stageCfg.costItems, itemInfo)
    end
    self._stageCfg[stageCfg.stage] = stageCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetStageCfgs = function(self)
  if nil == self._stageCfg then
    self:_LoadStageCfg()
  end
  return self._stageCfg
end
def.method("number", "=>", "table").GetStageCfg = function(self, id)
  return self:_GetStageCfgs()[id]
end
def.method("number", "=>", "string").GetEquipStageFrame = function(self, stage)
  local stageCfg = self:GetStageCfg(stage)
  local iconCfg = stageCfg and PetUtility.Instance():GetPetIconBgCfg(stageCfg.colorFrameId) or nil
  if iconCfg then
    return iconCfg.spriteName
  else
    warn("[ERROR][BreakOutData:GetEquipStageFrame] iconCfg NIL!")
    return ""
  end
end
def.method()._LoadStageMaxLevelCfg = function(self)
  warn("[BreakOutData:_LoadStageMaxLevelCfg] start Load StageMaxLevelCfg!")
  self._stageMaxLevelCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_GOD_WEAPON_STAGE_MAX_LEVEL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    local stage = DynamicRecord.GetIntValue(entry, "stage")
    local maxLevel = DynamicRecord.GetIntValue(entry, "maxLevel")
    self._stageMaxLevelCfg[stage] = maxLevel
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetStageMaxLevelCfgs = function(self)
  if nil == self._stageMaxLevelCfg then
    self:_LoadStageMaxLevelCfg()
  end
  return self._stageMaxLevelCfg
end
def.method("number", "=>", "number").GetStageMaxLevel = function(self, stage)
  local level = self:_GetStageMaxLevelCfgs()[stage]
  return level and level or 0
end
def.method()._LoadEquipTypeLevelCfg = function(self)
  warn("[BreakOutData:_LoadEquipTypeLevelCfg] start Load levelCfg!")
  self._equipTypeLevelCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_GOD_WEAPON_BREAKOUT_LEVEL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local equipTypeCfg = {}
    local equipTypeEntry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    equipTypeCfg.equipType = DynamicRecord.GetIntValue(equipTypeEntry, "equipmentType")
    equipTypeCfg.levelCfgs = {}
    local equipLevelCfgsStruct = equipTypeEntry:GetStructValue("configsStruct")
    local count = equipLevelCfgsStruct:GetVectorSize("configsList")
    for i = 1, count do
      local levelCfg = {}
      levelCfg.level = i
      local levelCfgRecord = equipLevelCfgsStruct:GetVectorValueByIdx("configsList", i - 1)
      levelCfg.improveCfgs = {}
      local improveBeansStruct = levelCfgRecord:GetStructValue("improveBeansStruct")
      local count = improveBeansStruct:GetVectorSize("improveBeansList")
      for i = 1, count do
        local improveBeansRecord = improveBeansStruct:GetVectorValueByIdx("improveBeansList", i - 1)
        local type = improveBeansRecord:GetIntValue("type")
        local value = improveBeansRecord:GetIntValue("value")
        levelCfg.improveCfgs[type] = value
      end
      levelCfg.costItems = {}
      local requiredItemsStruct = levelCfgRecord:GetStructValue("requiredItemsStruct")
      local count = requiredItemsStruct:GetVectorSize("requiredItemsList")
      for i = 1, count do
        local ItemCfg = {}
        local requireItemRecord = requiredItemsStruct:GetVectorValueByIdx("requiredItemsList", i - 1)
        ItemCfg.id = requireItemRecord:GetIntValue("id")
        ItemCfg.num = requireItemRecord:GetIntValue("num")
        table.insert(levelCfg.costItems, ItemCfg)
      end
      levelCfg.requiredStrengthLevel = levelCfgRecord:GetIntValue("requiredStrengthLevel")
      levelCfg.requiredStage = levelCfgRecord:GetIntValue("requiredStage")
      levelCfg.requiredCurrencyType = levelCfgRecord:GetIntValue("requiredCurrencyType")
      levelCfg.requiredCurrencyNum = levelCfgRecord:GetIntValue("requiredCurrencyNum")
      equipTypeCfg.levelCfgs[levelCfg.level] = levelCfg
    end
    self._equipTypeLevelCfg[equipTypeCfg.equipType] = equipTypeCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetEquipTypeLevelCfgs = function(self)
  if nil == self._equipTypeLevelCfg then
    self:_LoadEquipTypeLevelCfg()
  end
  return self._equipTypeLevelCfg
end
def.method("number", "=>", "table").GetEquipTypeLevelCfg = function(self, type)
  return self:_GetEquipTypeLevelCfgs()[type]
end
def.method("number", "number", "=>", "table").GetLevelCfg = function(self, type, level)
  local result
  local typeCfg = self:GetEquipTypeLevelCfg(type)
  if typeCfg then
    result = typeCfg.levelCfgs[level]
    if nil == result then
      warn("[ERROR][BreakOutUtils:GetLevelCfg] levelCfg nil for type&level:", type, level)
    end
  else
    warn("[ERROR][BreakOutUtils:GetLevelCfg] typeCfg nil for type:", type)
  end
  return result
end
def.method("=>", "table").GetBreakOutEquips = function(self)
  if nil == BreakOutData.RELATED_BAGS or #BreakOutData.RELATED_BAGS <= 0 then
    return nil
  end
  local ItemUtils = require("Main.Item.ItemUtils")
  local ItemModule = require("Main.Item.ItemModule")
  local EquipUtils = require("Main.Equip.EquipUtils")
  local equipList = {}
  for _, bagId in ipairs(BreakOutData.RELATED_BAGS) do
    local bagInfo = ItemModule.Instance():GetItemsByBagId(bagId)
    if bagInfo then
      for key, itemInfo in pairs(bagInfo) do
        local BreakOutUtils = require("Main.GodWeapon.BreakOut.BreakOutUtils")
        if BreakOutUtils.IsItemSatisfyGodWeapon(itemInfo) then
          local equipInfo = {}
          local itemBase = ItemUtils.GetItemBase(itemInfo.id)
          if nil == itemBase then
            warn("[ERROR][BreakOutData:GetBreakOutEquips] itemBase nil for itemid:", itemInfo.id)
          else
          end
          local equipBase = ItemUtils.GetEquipBase(itemBase.itemid)
          if nil == equipBase then
            warn("[ERROR][BreakOutData:GetBreakOutEquips] equipBase nil for itemid:", itemInfo.id)
          else
          end
          local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
          equipInfo.id = itemInfo.id
          equipInfo.uuid = itemInfo.uuid[1]
          equipInfo.bagId = bagId
          equipInfo.key = key
          equipInfo.icon = itemBase and itemBase.icon or 0
          equipInfo.namecolor = itemBase and itemBase.namecolor or 0
          equipInfo.bEquiped = BagInfo.EQUIPBAG == bagId
          equipInfo.score = EquipUtils.CalcEpuipScoreUtil(itemInfo)
          equipInfo.extraMap = itemInfo.extraMap
          local godWeaponStage = itemInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_STAGE]
          equipInfo.godWeaponStage = godWeaponStage and godWeaponStage or 0
          local godWeaponLevel = itemInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_LEVEL]
          equipInfo.godWeaponLevel = godWeaponLevel and godWeaponLevel or 0
          equipInfo.realName = ItemUtils.GetItemName(itemInfo, itemBase)
          equipInfo.frameName = ItemUtils.GetItemFrame(itemInfo, itemBase)
          equipInfo.strenLevel = EquipUtils.GetEquipStrenLevel(equipInfo.bagId, equipInfo.key)
          equipInfo.typeName = itemBase and itemBase.itemTypeName or ""
          local equipBase = ItemUtils.GetEquipBase(equipInfo.id)
          equipInfo.wearPos = equipBase and equipBase.wearpos or -1
          local costMap = itemInfo.super_equipment_cost_bean
          equipInfo.stageUpCostMap = costMap and costMap.stage_cost_map or nil
          equipInfo.levelUpCostMap = costMap and costMap.level_cost_map or nil
          table.insert(equipList, equipInfo)
        end
      end
    else
      warn(string.format("[ERROR][BreakOutData:GetBreakOutEquips] bagInfo nil for bagId[%d].", bagId))
    end
  end
  if equipList and #equipList > 0 then
    table.sort(equipList, function(a, b)
      if a == nil then
        return true
      elseif b == nil then
        return false
      elseif a.bEquiped ~= b.bEquiped then
        return a.bEquiped
      elseif a.wearPos ~= b.wearPos then
        return a.wearPos < b.wearPos
      elseif a.score ~= b.score then
        return a.score > b.score
      else
        return Int64.lt(a.uuid, b.uuid)
      end
    end)
  end
  return equipList
end
def.method("table", "table").OnLeaveWorld = function(self, p1, p2)
  self:_Reset()
end
BreakOutData.Commit()
return BreakOutData
