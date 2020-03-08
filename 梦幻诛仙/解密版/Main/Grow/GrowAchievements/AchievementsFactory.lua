local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local AchievementsFactory = Lplus.Class(CUR_CLASS_NAME)
local Achievement = import(".Achievement")
local def = AchievementsFactory.define
local CreateAndInit = function(class, id)
  local obj = class()
  obj:Init(id)
  return obj
end
def.static("number", "=>", Achievement).CreateAchievement = function(achievementId)
  return CreateAndInit(Achievement, achievementId)
end
return AchievementsFactory.Commit()
