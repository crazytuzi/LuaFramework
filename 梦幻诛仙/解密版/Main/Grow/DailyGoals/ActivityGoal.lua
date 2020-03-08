local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local BaseGoal = import(".BaseGoal")
local ActivityGoal = Lplus.Extend(BaseGoal, CUR_CLASS_NAME)
local def = ActivityGoal.define
def.field("number").activityId = 0
def.override("=>", "boolean").Go = function(self)
  local ParticipateActivity = import("..Operations.ParticipateActivity", CUR_CLASS_NAME)
  return ParticipateActivity():Operate({
    self.activityId
  })
end
return ActivityGoal.Commit()
