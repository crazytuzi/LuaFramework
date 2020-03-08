local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SearchBase = import(".SearchBase")
local SearchPetMgr = Lplus.Extend(SearchBase, MODULE_NAME)
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
local PetUtility = require("Main.Pet.PetUtility")
local SkillUtility = require("Main.Skill.SkillUtility")
local PetType = require("consts.mzm.gsp.pet.confbean.PetType")
local def = SearchPetMgr.define
local PET_START_CARRY_LEVEL = 5
local PET_CARRY_LEVEL_DELTA = 10
local instance
def.static("=>", SearchPetMgr).Instance = function()
  if instance == nil then
    instance = SearchPetMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.override("table").Search = function(self, params)
  SearchBase.Search(self, params)
  local state, pricesort, page = params.state, params.pricesort, params.page
  TradingArcadeProtocol.CSearchPetReq(self.m_condition, state, pricesort, page)
end
def.override("table", "table", "=>", "boolean").CompareCondition = function(self, lc, rc)
  if lc.subid ~= rc.subid then
    return false
  end
  if lc.skillNum ~= rc.skillNum then
    return false
  end
  if table.nums(lc.petTypes) ~= table.nums(rc.petTypes) then
    return false
  end
  for k, v in pairs(lc.petTypes) do
    if rc.petTypes[k] == nil then
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
def.method("=>", "table").GetPetCarryLevels = function(self)
  local MIN_LEVEL = PET_START_CARRY_LEVEL
  local LEVEL_STEP = PET_CARRY_LEVEL_DELTA
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local minLevel = math.max(MIN_LEVEL, math.min(MIN_LEVEL, math.floor(heroLevel / LEVEL_STEP) * LEVEL_STEP))
  local maxLevel = math.max(MIN_LEVEL, math.floor((heroLevel + LEVEL_STEP) / LEVEL_STEP) * LEVEL_STEP)
  local levels = {}
  for i = minLevel, maxLevel, LEVEL_STEP do
    local condition = {
      param = i,
      name = string.format(textRes.Common[3], i)
    }
    if math.floor(heroLevel / LEVEL_STEP) * LEVEL_STEP == i or heroLevel < minLevel then
      condition.default = true
    end
    table.insert(levels, condition)
  end
  return levels
end
def.method("number", "=>", "table").GetPetsByCarryLevel = function(self, carryLevel)
  local pets = {}
  local allPetCfgs = TradingArcadeUtils.GetAllMarketPetCfgs()
  for i, v in ipairs(allPetCfgs) do
    local petId = v.petid
    local petCfg = PetUtility.Instance():GetPetCfg(petId)
    if petCfg.carryLevel == carryLevel then
      table.insert(pets, {
        petCfg = petCfg,
        subId = v.subid
      })
    end
  end
  return pets
end
def.method("number", "number", "=>", "table").GetPetsByCarryLevelAndType = function(self, carryLevel, petType)
  local pets = self:GetPetsByCarryLevel(carryLevel)
  local cfgs = {}
  for i, v in ipairs(pets) do
    if v.petCfg.type == petType then
      cfgs[#cfgs + 1] = v
    end
  end
  return cfgs
end
def.method("=>", "table").GetAllPetSkillType = function(self)
  return PetUtility.GetAllPetSkillColorCfgs()
end
def.method("number", "=>", "table").GetPetSkillsByLevelId = function(self, id)
  local allSkills = PetUtility.GetAllPetSkill()
  local skills = {}
  for i, v in ipairs(allSkills) do
    if v.skillLevelId == id then
      local skillCfg = SkillUtility.GetSkillCfg(v.skillId)
      table.insert(skills, skillCfg)
    end
  end
  return skills
end
def.method("number", "=>", "table").GetDefaultValues = function(self, subId)
  local defaults = {}
  local allPetCfgs = TradingArcadeUtils.GetAllMarketPetCfgs()
  for i, v in ipairs(allPetCfgs) do
    if v.subid == subId then
      local petId = v.petid
      local petCfg = PetUtility.Instance():GetPetCfg(petId)
      defaults.pet = {
        petCfg = petCfg,
        subId = v.subid
      }
      local i = petCfg.carryLevel
      defaults.level = {
        param = i,
        name = string.format(textRes.Common[3], i)
      }
      return defaults
    end
  end
  return defaults
end
return SearchPetMgr.Commit()
