local AchievementType = require("consts.mzm.gsp.grow.confbean.GoalType")
local AchievementData = require("Main.achievement.AchievementData")
local getActivityJoinFinishGoal = function(goalCfg, params)
  return params[1], goalCfg.params[2]
end
local getActivityJoinOnlyFinishGoal = function(goalCfg, params)
  return params[1], goalCfg.params[2]
end
local getRoleLevelUpFinishGoal = function(goalCfg, params)
  local param = params[1]
  if param <= 0 then
    param = 1
  end
  return param, goalCfg.params[1]
end
local getShopBuyGoal = function(goalCfg, params)
  return params[1], goalCfg.params[2]
end
local getColorEquipGoal = function(goalCfg, params)
  return params[1], goalCfg.params[2]
end
local getPetOwnGoal = function(goalCfg, params)
  return params[1], goalCfg.params[2]
end
local getSkillShenghuoLevelUpGoal = function(goalCfg, params)
  if 1 < goalCfg.params[1] then
    return params[1], goalCfg.params[1]
  else
    return params[2], goalCfg.params[2]
  end
end
local getEquipmentQilingLevelGoal = function(goalCfg, params)
  if 1 < goalCfg.params[1] then
    return params[1], goalCfg.params[1]
  else
    return params[2], goalCfg.params[2]
  end
end
local getSkillXiulianLevelUpGoal = function(goalCfg, params)
  if 1 < goalCfg.params[1] then
    return params[1], goalCfg.params[1]
  else
    return params[2], goalCfg.params[2]
  end
end
local getMenPaiShengJiGoal = function(goalCfg, params)
  if 1 < goalCfg.params[1] then
    return params[1], goalCfg.params[1]
  else
    return params[2], goalCfg.params[2]
  end
end
local getLuckyBagGoal = function(goalCfg, params)
  local p = params[2] or params[1]
  return p, goalCfg.params[2]
end
local defaultFinishGoal = function(goalCfg, params)
  local pos = goalCfg.paramPos
  if pos and pos > 0 then
    return params[1], goalCfg.params[pos]
  else
    return params[1], goalCfg.params[1]
  end
end
local AchievementFinishInfo = {
  [AchievementType.ACTIVITY_JOIN] = getActivityJoinFinishGoal,
  [AchievementType.ACTIVITY_JOIN_ONLY] = getActivityJoinOnlyFinishGoal,
  [AchievementType.ROLE_LEVEL_UP] = getRoleLevelUpFinishGoal,
  [AchievementType.EXCHANGE_SHANG_CHENG_BUY] = getShopBuyGoal,
  [AchievementType.GET_COLOR_EQUIPMENT] = getColorEquipGoal,
  [AchievementType.PET_OWN] = getPetOwnGoal,
  [AchievementType.SKILL_SHENG_HUO_LEVEL_UP] = getSkillShenghuoLevelUpGoal,
  [AchievementType.EQUIPMENT_QILING_LEVEL] = getEquipmentQilingLevelGoal,
  [AchievementType.SKILL_XIULIAN_LEVELUP] = getSkillXiulianLevelUpGoal,
  [AchievementType.OPEN_LUCK_BAG] = getLuckyBagGoal,
  [AchievementType.SKILL_MENPAI_SHENGJI] = getMenPaiShengJiGoal
}
function AchievementFinishInfo.getFinishInfoData(goalCfg, params)
  local func = AchievementFinishInfo[goalCfg.goalType]
  local numerator, denominator = 0, 0
  if func then
    numerator, denominator = func(goalCfg, params)
  else
    numerator, denominator = defaultFinishGoal(goalCfg, params)
  end
  return numerator, denominator
end
function AchievementFinishInfo.getFinishInfoStr(goalCfg, params)
  local numerator, denominator = AchievementFinishInfo.getFinishInfoData(goalCfg, params)
  if _G.IsNil(numerator) then
    warn("--------------AchievementFinishInfo.getFinishInfoStr params ERROR!! id=", goalCfg.id, "type=", goalCfg.goalType, ", numerator=", numerator)
    numerator = 0
  end
  if _G.IsNil(denominator) then
    warn("--------------AchievementFinishInfo.getFinishInfoStr cfgParams ERROR!! id=", goalCfg.id, "type=", goalCfg.goalType, ", denominator=", denominator)
    denominator = 0
  end
  return string.format("%d/%d", numerator, denominator)
end
return AchievementFinishInfo
