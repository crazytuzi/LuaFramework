local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SearchBase = import(".SearchBase")
local CustomizedSearchMgr = Lplus.Extend(SearchBase, MODULE_NAME)
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
local PetUtility = require("Main.Pet.PetUtility")
local SkillUtility = require("Main.Skill.SkillUtility")
local PetType = require("consts.mzm.gsp.pet.confbean.PetType")
local SearchEquipMgr = require("Main.TradingArcade.SearchEquipMgr")
local SearchPetMgr = require("Main.TradingArcade.SearchPetMgr")
local SearchPetEquipMgr = require("Main.TradingArcade.SearchPetEquipMgr")
local Currency = require("Main.Currency.Yuanbao")
local CustomizedSearchEquip = require("Main.TradingArcade.data.CustomizedSearchEquip")
local CustomizedSearchPetEquip = require("Main.TradingArcade.data.CustomizedSearchPetEquip")
local CustomizedSearchPet = require("Main.TradingArcade.data.CustomizedSearchPet")
local def = CustomizedSearchMgr.define
def.field("table").m_customizedSearchs = nil
local instance
def.static("=>", CustomizedSearchMgr).Instance = function()
  if instance == nil then
    instance = CustomizedSearchMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_customizedSearchs = {}
end
def.method("=>", "table").GetCustomizedSearchs = function(self)
  return self.m_customizedSearchs
end
def.method("=>", "number").GetMaxCustomizedSearchNum = function(self)
  return _G.constant.MarketConsts.MAX_CUSTOMIZED_CONDITION_NUM
end
def.method("table", "=>", "boolean").CustomizeEquipReq = function(self, condition)
  local searchMgr = SearchEquipMgr.Instance()
  if self:CheckCondition(searchMgr, condition) == false then
    return false
  end
  self:CustomizeConfirm(CustomizedSearchEquip, condition, function(...)
    TradingArcadeProtocol.CAddEquipConditionReq(condition)
  end)
  return true
end
def.method("table", "=>", "boolean").CustomizePetReq = function(self, condition)
  local searchMgr = SearchPetMgr.Instance()
  if self:CheckCondition(searchMgr, condition) == false then
    return false
  end
  self:CustomizeConfirm(CustomizedSearchPet, condition, function(...)
    TradingArcadeProtocol.CAddPetConditionReq(condition)
  end)
  return true
end
def.method("table", "=>", "boolean").CustomizePetEquipReq = function(self, condition)
  local searchMgr = SearchPetEquipMgr.Instance()
  if self:CheckCondition(searchMgr, condition) == false then
    return false
  end
  self:CustomizeConfirm(CustomizedSearchPetEquip, condition, function(...)
    TradingArcadeProtocol.CAddPetEquipConditionReq(condition)
  end)
  return true
end
def.method("table", "table", "function").CustomizeConfirm = function(self, CustomizeSearch, condition, func)
  local customizeSearch = CustomizeSearch()
  customizeSearch:Init()
  customizeSearch.condition = condition
  local displayName = customizeSearch:GetDisplayName()
  local conditionDesc = customizeSearch:GetConditionDesc()
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local needNum = Int64.new(_G.constant.MarketConsts.CUSTOMIZED_NEED_YUANBAO_NUM or 0)
  local title = textRes.TradingArcade[232]
  local desc = string.format(textRes.TradingArcade[233], tostring(needNum), displayName, conditionDesc)
  CommonConfirmDlg.ShowConfirm(title, desc, function(s)
    if s == 1 then
      local yuanbao = Currency.Instance()
      local needNum = Int64.new(_G.constant.MarketConsts.CUSTOMIZED_NEED_YUANBAO_NUM or 0)
      local haveNum = yuanbao:GetHaveNum()
      if needNum > haveNum then
        yuanbao:AcquireWithQuery()
        return
      end
      func()
    end
  end, nil)
end
def.method("table", "table", "=>", "boolean").CheckCondition = function(self, searchMgr, condition)
  local capacity = self:GetMaxCustomizedSearchNum()
  if capacity <= #self.m_customizedSearchs then
    Toast(textRes.TradingArcade[230])
    return false
  end
  for i, v in ipairs(self.m_customizedSearchs) do
    if searchMgr:CompareCondition(v.condition, condition) == true then
      Toast(textRes.TradingArcade[221])
      return false
    end
  end
  return true
end
def.method("table").SetAllCustomize = function(self, p)
  self.m_customizedSearchs = {}
  for k, v in pairs(p.subid2EquipCons) do
    for index, condition in ipairs(v.equipCons) do
      local customizedSearch = self:AddEquipCustomize(index, condition)
      if v.conditionState and v.conditionState[index] then
        customizedSearch.periodState = v.conditionState[index]
      end
    end
  end
  for k, v in pairs(p.subid2PetEquipCons) do
    for index, condition in ipairs(v.petEquipCons) do
      local customizedSearch = self:AddPetEquipCustomize(index, condition)
      if v.conditionState and v.conditionState[index] then
        customizedSearch.periodState = v.conditionState[index]
      end
    end
  end
  for k, v in pairs(p.subid2PetCons) do
    for index, condition in ipairs(v.petCons) do
      local customizedSearch = self:AddPetCustomize(index, condition)
      if v.conditionState and v.conditionState[index] then
        customizedSearch.periodState = v.conditionState[index]
      end
    end
  end
end
def.method("number", "table", "=>", "table").AddEquipCustomize = function(self, vindex, condition)
  local customizedSearch = require("Main.TradingArcade.data.CustomizedSearchEquip")()
  customizedSearch:Init()
  customizedSearch.vindex = vindex
  customizedSearch.condition = condition
  self:AddCustomizedSearch(customizedSearch)
  return customizedSearch
end
def.method("number", "table", "=>", "table").AddPetEquipCustomize = function(self, vindex, condition)
  local customizedSearch = require("Main.TradingArcade.data.CustomizedSearchPetEquip")()
  customizedSearch:Init()
  customizedSearch.vindex = vindex
  customizedSearch.condition = condition
  self:AddCustomizedSearch(customizedSearch)
  return customizedSearch
end
def.method("number", "table", "=>", "table").AddPetCustomize = function(self, vindex, condition)
  local customizedSearch = require("Main.TradingArcade.data.CustomizedSearchPet")()
  customizedSearch:Init()
  customizedSearch.vindex = vindex
  customizedSearch.condition = condition
  self:AddCustomizedSearch(customizedSearch)
  return customizedSearch
end
def.method("table").AddCustomizedSearch = function(self, customizedSearch)
  table.insert(self.m_customizedSearchs, customizedSearch)
end
def.method("table").DeleteCustomizedSearchReq = function(self, customizedSearch)
  TradingArcadeProtocol.CDeleteConditionReq(customizedSearch.condition.subid, customizedSearch.vindex)
end
def.method("number", "number").DeleteCustomizedSearch = function(self, subid, vindex)
  for i, v in ipairs(self.m_customizedSearchs) do
    if v.condition.subid == subid and v.vindex == vindex then
      table.remove(self.m_customizedSearchs, i)
      break
    end
  end
end
def.method("table").SyncCustomizedSearchPeriodState = function(self, p)
  for i, v in ipairs(self.m_customizedSearchs) do
    if v.condition.subid == p.subid and v.vindex == p.index then
      v.periodState = p.pubOrsell
      break
    end
  end
end
def.method("=>", "boolean").HasNotify = function(self)
  local ConditionState = require("netio.protocol.mzm.gsp.market.ConditionState")
  for i, v in ipairs(self.m_customizedSearchs) do
    if v.periodState ~= ConditionState.NONE then
      return true
    end
  end
  return false
end
def.method("=>", "boolean").HasPublicNotify = function(self)
  local ConditionState = require("netio.protocol.mzm.gsp.market.ConditionState")
  for i, v in ipairs(self.m_customizedSearchs) do
    if v.periodState == ConditionState.IN_PUBLIC then
      return true
    end
  end
  return false
end
def.method("=>", "boolean").HasOnSellNotify = function(self)
  local ConditionState = require("netio.protocol.mzm.gsp.market.ConditionState")
  for i, v in ipairs(self.m_customizedSearchs) do
    if v.periodState == ConditionState.IN_SELL then
      return true
    end
  end
  return false
end
def.method("number", "=>", "boolean").HasCustomizeTypeNotify = function(self, customizeType)
  local ConditionState = require("netio.protocol.mzm.gsp.market.ConditionState")
  for i, v in ipairs(self.m_customizedSearchs) do
    if v.type == customizeType and v.periodState ~= ConditionState.NONE then
      return true
    end
  end
  return false
end
return CustomizedSearchMgr.Commit()
