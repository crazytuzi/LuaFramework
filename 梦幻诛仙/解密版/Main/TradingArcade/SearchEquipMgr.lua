local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SearchBase = import(".SearchBase")
local SearchEquipMgr = Lplus.Extend(SearchBase, MODULE_NAME)
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
local ItemUtils = require("Main.Item.ItemUtils")
local EquipUtils = require("Main.Equip.EquipUtils")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local def = SearchEquipMgr.define
local instance
def.static("=>", SearchEquipMgr).Instance = function()
  if instance == nil then
    instance = SearchEquipMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.override("table").Search = function(self, params)
  SearchBase.Search(self, params)
  local state, pricesort, page = params.state, params.pricesort, params.page
  TradingArcadeProtocol.CSearchEquipReq(self.m_condition, state, pricesort, page)
end
def.override("table", "table", "=>", "boolean").CompareCondition = function(self, lc, rc)
  if lc.subid ~= rc.subid then
    return false
  end
  if lc.level ~= rc.level then
    return false
  end
  if table.nums(lc.colors) ~= table.nums(rc.colors) then
    return false
  end
  for k, v in pairs(lc.colors) do
    if rc.colors[k] == nil then
      return false
    end
  end
  if table.nums(lc.skillIds) ~= table.nums(rc.skillIds) then
    return false
  end
  for k, v in pairs(lc.skillIds) do
    if rc.skillIds[k] == nil then
      return false
    end
  end
  return true
end
local _allEquipTypes
def.method("=>", "table").GetAllEquipTypes = function(self)
  if _allEquipTypes then
    return _allEquipTypes
  end
  local genEquipTypeKey = function(equipBase)
    return equipBase.wearpos .. "_" .. equipBase.menpai .. "_" .. equipBase.sex
  end
  _allEquipTypes = {}
  local equipTypeMap = {}
  local allMarketItems = TradingArcadeUtils.GetAllMarketItemCfgs()
  for i, v in ipairs(allMarketItems) do
    local itemBase = ItemUtils.GetItemBase(v.itemid)
    if itemBase.itemType == ItemType.EQUIP then
      local equipBase = ItemUtils.GetEquipBase(itemBase.itemid)
      local equipTypeKey = genEquipTypeKey(equipBase)
      if equipTypeMap[equipTypeKey] == nil then
        equipTypeMap[equipTypeKey] = {
          itemTypeName = itemBase.itemTypeName,
          equipTypeKey = equipTypeKey,
          subId = v.subid
        }
        table.insert(_allEquipTypes, equipTypeMap[equipTypeKey])
      end
    end
  end
  return _allEquipTypes
end
def.method("=>", "table").GetAllEquipSkills = function(self)
  return EquipUtils.GetAllEquipSkillCfgs()
end
def.method("number", "=>", "table").GetCommonSkillsByWearPos = function(self, wearpos)
  local allSkillLists = self:GetAllEquipSkills()
  local skillList
  local skillIdMap = {}
  for i, v in ipairs(allSkillLists) do
    if v.wearpos == wearpos then
      if skillList == nil then
        skillList = v.skills
      end
    else
      for i, skillId in ipairs(v.skills) do
        skillIdMap[skillId] = skillId
      end
    end
  end
  local commonSkillList = {}
  if skillList == nil then
    return commonSkillList
  end
  for i, v in ipairs(skillList) do
    if skillIdMap[v] then
      table.insert(commonSkillList, v)
    end
  end
  return commonSkillList
end
def.method("number", "=>", "table").GetEquipSkillsByWearPos = function(self, wearpos)
  local allSkillLists = self:GetAllEquipSkills()
  local skillList
  local skillIdMap = {}
  for i, v in ipairs(allSkillLists) do
    if v.wearpos == wearpos then
      if skillList == nil then
        skillList = v.skills
      end
    else
      for i, skillId in ipairs(v.skills) do
        skillIdMap[skillId] = skillId
      end
    end
  end
  local equipSkillList = {}
  if skillList == nil then
    return equipSkillList
  end
  for i, v in ipairs(skillList) do
    if skillIdMap[v] == nil then
      table.insert(equipSkillList, v)
    end
  end
  return equipSkillList
end
def.method("number", "=>", "table").GetDefaultValues = function(self, subId)
  local genEquipTypeKey = function(equipBase)
    return equipBase.wearpos .. "_" .. equipBase.menpai .. "_" .. equipBase.sex
  end
  local defaults = {}
  local allMarketItems = TradingArcadeUtils.GetAllMarketItemCfgs()
  for i, v in ipairs(allMarketItems) do
    if v.subid == subId then
      local itemBase = ItemUtils.GetItemBase(v.itemid)
      if itemBase.itemType == ItemType.EQUIP then
        local equipBase = ItemUtils.GetEquipBase(itemBase.itemid)
        local equipTypeKey = genEquipTypeKey(equipBase)
        defaults.type = {
          itemTypeName = itemBase.itemTypeName,
          equipTypeKey = equipTypeKey,
          subId = v.subid
        }
        return defaults
      end
    end
  end
  return defaults
end
return SearchEquipMgr.Commit()
