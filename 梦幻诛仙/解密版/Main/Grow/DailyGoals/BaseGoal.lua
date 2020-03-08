local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local BaseGoal = Lplus.Class(CUR_CLASS_NAME)
local Operation = require("Main.Grow.Operations.Operation")
local AchievementsFactory = require("Main.Grow.GrowAchievements.AchievementsFactory")
local GrowUtils = import("..GrowUtils")
local def = BaseGoal.define
def.field("number").type = 0
def.field("number").state = 0
def.field("number").progress = 0
def.field("table").award = nil
def.field("number").id = 0
def.field("table").achievement = nil
def.method("number").Init = function(self, id)
  self.id = id
  self.achievement = AchievementsFactory.CreateAchievement(self.id)
end
def.virtual("=>", "boolean").Go = function(self)
  self.achievement:InitData()
  return self.achievement:Go()
end
return BaseGoal.Commit()
