local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local GoalFactory = Lplus.Class(CUR_CLASS_NAME)
local BaseGoal = import(".BaseGoal")
local GrowUtils = import("..GrowUtils")
local def = GoalFactory.define
local CreateAndInit = function(class, targetId)
  local obj = class()
  obj:Init(targetId)
  return obj
end
def.static("number", "=>", BaseGoal).CreateGoal = function(targetId)
  local cfg = GrowUtils.GetGrowAchievementCfg(targetId)
  return CreateAndInit(BaseGoal, targetId)
end
return GoalFactory.Commit()
