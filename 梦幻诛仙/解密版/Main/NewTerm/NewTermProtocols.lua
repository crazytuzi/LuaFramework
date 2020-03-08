local Lplus = require("Lplus")
local NewTermData = require("Main.NewTerm.data.NewTermData")
local NewTermProtocols = Lplus.Class("NewTermProtocols")
local def = NewTermProtocols.define
def.static().RegisterProtocols = function()
end
def.static("number", "number").SendCGetAchievementGoalAward = function(activityId, achievementId)
  warn("[NewTermProtocols:SendCGetAchievementGoalAward] Send CGetAchievementGoalAward:", activityId, achievementId)
  local p = require("netio.protocol.mzm.gsp.achievement.CGetAchievementGoalAward").new(activityId, achievementId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSPetSoulInitPropRes = function(p)
end
NewTermProtocols.Commit()
return NewTermProtocols
