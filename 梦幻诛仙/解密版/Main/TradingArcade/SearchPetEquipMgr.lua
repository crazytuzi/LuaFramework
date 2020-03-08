local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SearchBase = import(".SearchBase")
local SearchPetEquipMgr = Lplus.Extend(SearchBase, MODULE_NAME)
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
local PetUtility = require("Main.Pet.PetUtility")
local SkillUtility = require("Main.Skill.SkillUtility")
local PetEquipType = require("consts.mzm.gsp.petequip.confbean.PetEquipType")
local def = SearchPetEquipMgr.define
def.const("number").PET_EQUIP_BIG_TYPE_ID = 420100003
def.const("table").LOWER_SKILLS_ID_MAP = {
  [110500001] = true
}
local instance
def.static("=>", SearchPetEquipMgr).Instance = function()
  if instance == nil then
    instance = SearchPetEquipMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.override("table").Search = function(self, params)
  SearchBase.Search(self, params)
  local state, pricesort, page = params.state, params.pricesort, params.page
  TradingArcadeProtocol.CSearchPetEquipReq(self.m_condition, state, pricesort, page)
end
def.override("table", "table", "=>", "boolean").CompareCondition = function(self, lc, rc)
  if lc.subid ~= rc.subid then
    return false
  end
  if lc.property ~= rc.property then
    return false
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
def.method("=>", "table").GetAllPetEquipmentType = function(self)
  local types = {}
  local bigTypeCfg = TradingArcadeUtils.GetMarketBigTypeCfg(SearchPetEquipMgr.PET_EQUIP_BIG_TYPE_ID)
  for i, subId in ipairs(bigTypeCfg.subIds) do
    local subTypeCfg = TradingArcadeUtils.GetMarketSubTypeCfg(subId)
    table.insert(types, subTypeCfg)
  end
  return types
end
def.method("number", "=>", "table").GetEquipmentProps = function(self, subId)
  local allMarketItems = TradingArcadeUtils.GetAllMarketItemCfgs()
  local itemId
  for i, v in ipairs(allMarketItems) do
    if v.subid == subId then
      itemId = v.itemid
      break
    end
  end
  if itemId == nil then
    return nil
  end
  local petEquipCfg = PetUtility.GetPetEquipmentCfg(itemId)
  if petEquipCfg.petPropertyTableId == 0 then
    return nil
  end
  local petEquipPropCfg = PetUtility.GetPetEquipmentPropertyCfg(petEquipCfg.petPropertyTableId)
  return petEquipPropCfg.props
end
def.method("number", "=>", "table").GetEquipmentSkills = function(self, subId)
  local allMarketItems = TradingArcadeUtils.GetAllMarketItemCfgs()
  local itemId
  for i, v in ipairs(allMarketItems) do
    if v.subid == subId then
      itemId = v.itemid
      break
    end
  end
  if itemId == nil then
    return nil
  end
  local skillColorMap = {}
  local skillColorCfgs = PetUtility.GetAllPetSkillColorCfgs()
  for i, v in ipairs(skillColorCfgs) do
    skillColorMap[v.id] = v
  end
  local levelSkills = {}
  local petEquipCfg = PetUtility.GetPetEquipmentCfg(itemId)
  for i, skillId in ipairs(petEquipCfg.skills) do
    local skillList = SkillUtility.GetMonsterSkillCfg(skillId)
    if #skillList > 0 then
      local skillId = skillList[1]
      local skillScoreCfg = PetUtility.GetPetSkillScoreCfg(skillId)
      local skillColorCfg = skillColorMap[skillScoreCfg.skillLevelId]
      local skillLevel = skillColorCfg.skillLevel
      levelSkills[skillLevel] = levelSkills[skillLevel] or {}
      for i, v in ipairs(skillList) do
        table.insert(levelSkills[skillLevel], v)
      end
    end
  end
  local skills = {}
  for k, v in pairs(levelSkills) do
    v.skillLevel = k
    table.insert(skills, v)
  end
  table.sort(skills, function(l, r)
    return l.skillLevel < r.skillLevel
  end)
  return skills
end
def.method("number", "=>", "table").GetDefaultValues = function(self, subId)
  local defaults = {}
  local bigTypeCfg = TradingArcadeUtils.GetMarketBigTypeCfg(SearchPetEquipMgr.PET_EQUIP_BIG_TYPE_ID)
  for i, v in ipairs(bigTypeCfg.subIds) do
    if v == subId then
      local subTypeCfg = TradingArcadeUtils.GetMarketSubTypeCfg(subId)
      defaults.type = subTypeCfg
      return defaults
    end
  end
  return defaults
end
return SearchPetEquipMgr.Commit()
