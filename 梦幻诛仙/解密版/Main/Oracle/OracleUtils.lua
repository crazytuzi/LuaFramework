local Lplus = require("Lplus")
local HeroModule = require("Main.Hero.HeroModule")
local OracleData = require("Main.Oracle.data.OracleData")
local SkillUtility = require("Main.Skill.SkillUtility")
local OracleUtils = Lplus.Class("OracleUtils")
local def = OracleUtils.define
def.static("=>", "number").GetHeroTotalPoint = function()
  local result = 0
  local heroLevel = HeroModule.Instance():GetHeroProp().level
  if heroLevel >= constant.COracleConsts.OPEN_LEVEL then
    result = constant.COracleConsts.BASIC_POINT
    if 0 < constant.COracleConsts.ADD_POINT_INTERVAL_LEVEL then
      local levelWithLimit = math.min(heroLevel, constant.COracleConsts.MAX_LEVEL)
      local levelInterval = math.max(0, levelWithLimit - constant.COracleConsts.OPEN_LEVEL)
      result = result + math.floor(levelInterval / constant.COracleConsts.ADD_POINT_INTERVAL_LEVEL) * constant.COracleConsts.ADD_POINT_NUM
      result = result + OracleData.Instance():GetExtraPoints()
      result = math.min(result, constant.COracleConsts.MAX_POINT)
    end
  end
  return result
end
def.static("number", "=>", "number").GetTalentMaxPoint = function(talentId)
  local result = 0
  local talentCfg = OracleData.Instance():GetTalentCfg(talentId)
  if talentCfg then
    result = talentCfg.maxPoints
  end
  return result
end
def.static("number", "=>", "number").GetTalentAboveLayerPoint = function(talentId)
  local result = 0
  local talentCfg = OracleData.Instance():GetTalentCfg(talentId)
  if talentCfg then
    result = talentCfg.previousPoint
  end
  return result
end
def.static("number", "number", "=>", "table").GetTalentSkillCfg = function(talentId, talentPoint)
  local skillId = OracleUtils.GetSkillIdByTalentPoint(talentId, talentPoint)
  local skillCfg = SkillUtility.GetSkillCfg(skillId)
  return skillCfg
end
def.static("number", "number", "=>", "number").GetSkillIdByTalentPoint = function(talentId, point)
  local result = 0
  local talentCfg = OracleData.Instance():GetTalentCfg(talentId)
  if talentCfg then
    local index = math.max(1, point)
    index = math.min(index, #talentCfg.skills)
    result = talentCfg.skills[index]
  end
  return result and result or 0
end
OracleUtils.Commit()
return OracleUtils
