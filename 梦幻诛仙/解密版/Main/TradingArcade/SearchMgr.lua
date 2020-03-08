local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SearchMgr = Lplus.Class(MODULE_NAME)
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
local ItemUtils = require("Main.Item.ItemUtils")
local PetUtility = require("Main.Pet.PetUtility")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local def = SearchMgr.define
local instance
def.static("=>", SearchMgr).Instance = function()
  if instance == nil then
    instance = SearchMgr()
    instance:Init()
  end
  return instance
end
def.const("string").SEARCH_HISTORYS_KEY = "TradingArcade_SearchHistorys"
def.const("number").MAX_SEARCH_HISTORY_NUM = 6
def.field("table").searchHistorys = nil
def.field("userdata").searchRoleId = nil
def.field("table").curSearchMgr = nil
def.method().Init = function(self)
end
def.method("table", "table", "table").InvokeSearch = function(self, searchMgr, condition, params)
  self:SetCurSearchMgr(searchMgr)
  searchMgr:SetSearchCondition(condition)
  local TradingArcadeNode = require("Main.TradingArcade.ui.TradingArcadeNode")
  local ConditionState = require("netio.protocol.mzm.gsp.market.ConditionState")
  local targetNode = TradingArcadeNode.NodeId.BUY
  if params.periodState == ConditionState.IN_PUBLIC then
    targetNode = TradingArcadeNode.NodeId.PUBLIC
  end
  TradingArcadeNode.Instance():SetSearchMgr(targetNode, searchMgr)
  TradingArcadeNode.Instance():OpenSubTypePage(targetNode, condition.subid, 0)
end
def.method("table").SetCurSearchMgr = function(self, searchMgr)
  if self.curSearchMgr then
    self.curSearchMgr:ClearSearchDatas()
  end
  self.curSearchMgr = searchMgr
  warn("Set SearchMgr", searchMgr)
end
def.method("=>", "table").GetCurSearchMgr = function(self)
  return self.curSearchMgr
end
def.method("string", "=>", "table").SearchByName = function(self, goodsName)
  local results = {}
  local itemCfgs = TradingArcadeUtils.GetAllMarketItemCfgs()
  local nameMap = {}
  local subCfgs = {}
  local function getSubCfg(id)
    if subCfgs[id] == nil then
      local cfg = TradingArcadeUtils.GetMarketSubTypeCfg(id)
      subCfgs[id] = cfg
    end
    return subCfgs[id]
  end
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local function filterSubCfg(subid, useLevel)
    local subCfg = getSubCfg(subid)
    if heroLevel < subCfg.needlevel then
      return false
    end
    if subCfg.islevelsift and (useLevel < subCfg.initLevel or useLevel > heroLevel + subCfg.levelDelta) then
      return false
    end
    return true
  end
  for i, v in ipairs(itemCfgs) do
    local itemBase = ItemUtils.GetItemBase(v.itemid)
    if itemBase and nameMap[itemBase.name] == nil and string.find(itemBase.name, goodsName, 1, true) and filterSubCfg(v.subid, itemBase.useLevel) then
      local result = {
        name = itemBase.name,
        subid = v.subid,
        level = itemBase.useLevel
      }
      table.insert(results, result)
      nameMap[result.name] = true
    end
  end
  local petCfgs = TradingArcadeUtils.GetAllMarketPetCfgs()
  local nameMap = {}
  for i, v in ipairs(petCfgs) do
    local petCfg = PetUtility.Instance():GetPetCfg(v.petid)
    if petCfg and nameMap[petCfg.templateName] == nil and string.find(petCfg.templateName, goodsName, 1, true) and filterSubCfg(v.subid, 0) then
      local result = {
        name = petCfg.templateName,
        subid = v.subid,
        level = petCfg.carryLevel
      }
      table.insert(results, result)
      nameMap[result.name] = true
    end
  end
  return results
end
def.method("=>", "table").GetSearchHistorys = function(self)
  if self.searchHistorys == nil then
    self:InitSearchHistory()
  elseif _G.GetMyRoleID() ~= self.searchRoleId then
    self:InitSearchHistory()
  end
  return self.searchHistorys
end
def.method("table", "=>", "boolean").AddToSearchHistory = function(self, searchResult)
  local oldIndex
  for i, v in ipairs(self.searchHistorys) do
    if v.subid == searchResult.subid and v.name == searchResult.name then
      oldIndex = i
      break
    end
  end
  if oldIndex then
    local v = table.remove(self.searchHistorys, oldIndex)
    table.insert(self.searchHistorys, searchResult)
    self:SaveSearchHistory(self.searchHistorys)
    return false
  end
  table.insert(self.searchHistorys, searchResult)
  if #self.searchHistorys > SearchMgr.MAX_SEARCH_HISTORY_NUM then
    table.remove(self.searchHistorys, 1)
  end
  self:SaveSearchHistory(self.searchHistorys)
  return true
end
def.method().InitSearchHistory = function(self)
  self.searchHistorys = self:LoadSearchHistory() or {}
  self.searchRoleId = _G.GetMyRoleID()
end
def.method("=>", "table").LoadSearchHistory = function(self)
  local key = SearchMgr.SEARCH_HISTORYS_KEY
  if not LuaPlayerPrefs.HasRoleKey(key) then
    return nil
  end
  return LuaPlayerPrefs.GetRoleTable(key)
end
def.method("table").SaveSearchHistory = function(self, historys)
  local key = SearchMgr.SEARCH_HISTORYS_KEY
  LuaPlayerPrefs.SetRoleTable(key, historys)
  LuaPlayerPrefs.Save()
end
return SearchMgr.Commit()
