local Lplus = require("Lplus")
local EquipMakeData = Lplus.Class("EquipMakeData")
local EquipUtils = require("Main.Equip.EquipUtils")
local def = EquipMakeData.define
local instance
def.field("table")._makeEquips = nil
def.field("number")._curMakeEquipMaxLevel = 0
def.field("table")._equipId2MakeCfgId = nil
def.static("=>", EquipMakeData).Instance = function()
  if nil == instance then
    instance = EquipMakeData()
    instance._makeEquips = {}
  end
  return instance
end
def.method().Init = function(self)
  self._makeEquips = {}
  self:SetMakeEquipMaxLevel()
  self._equipId2MakeCfgId = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_EQUIP_MAKE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local equipMake = {}
    equipMake.id = DynamicRecord.GetIntValue(entry, "id")
    equipMake.eqpId = DynamicRecord.GetIntValue(entry, "eqpId")
    equipMake.makeCfgId = DynamicRecord.GetIntValue(entry, "makeCfgId")
    equipMake.equipInfo = EquipUtils.GetEquipBasicInfo(equipMake.eqpId)
    local itemRecord = require("Main.Item.ItemUtils").GetItemBase(equipMake.eqpId)
    if nil ~= itemRecord then
      equipMake.equipInfo.itemType = itemRecord.itemType
      equipMake.equipInfo.typeName = itemRecord.itemTypeName
      equipMake.equipInfo.name = itemRecord.name
      equipMake.equipInfo.iconId = itemRecord.icon
      equipMake.equipInfo.namecolor = itemRecord.namecolor
      equipMake.equipInfo.useLevel = itemRecord.useLevel
      if equipMake.equipInfo.useLevel < self._curMakeEquipMaxLevel then
        local equipMakeKey = equipMake.equipInfo.menpai .. "_" .. equipMake.equipInfo.sex
        if nil == self._makeEquips[equipMakeKey] then
          self._makeEquips[equipMakeKey] = {}
        end
        if nil == self._makeEquips[equipMakeKey][equipMake.equipInfo.useLevel] then
          self._makeEquips[equipMakeKey][equipMake.equipInfo.useLevel] = {}
        end
        self._makeEquips[equipMakeKey][equipMake.equipInfo.useLevel][#self._makeEquips[equipMakeKey][equipMake.equipInfo.useLevel] + 1] = equipMake
      end
      self._equipId2MakeCfgId[equipMake.eqpId] = equipMake.makeCfgId
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method().SetMakeEquipMaxLevel = function(self)
  local limitLv = 150
  if IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_EQUIP_MAKE_N_LEVEL) then
    limitLv = limitLv + 10
  end
  self._curMakeEquipMaxLevel = limitLv
end
def.method("=>", "number").GetMakeEquipMaxLevel = function(self)
  if self._curMakeEquipMaxLevel == 0 then
    self:SetMakeEquipMaxLevel()
  end
  return self._curMakeEquipMaxLevel
end
def.method("string", "=>", "table").GetMakeEquips = function(self, key)
  if nil ~= self._makeEquips[key] then
    return self._makeEquips[key]
  else
    return nil
  end
end
def.method("number", "=>", "number").GetMakeEquipCfgId = function(self, equipId)
  if self._equipId2MakeCfgId == nil then
    self:Init()
  end
  return self._equipId2MakeCfgId[equipId] or -1
end
EquipMakeData.Commit()
return EquipMakeData
