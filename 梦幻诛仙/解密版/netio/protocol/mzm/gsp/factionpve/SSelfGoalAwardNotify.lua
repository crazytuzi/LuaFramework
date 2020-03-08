local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SSelfGoalAwardNotify = class("SSelfGoalAwardNotify")
SSelfGoalAwardNotify.TYPEID = 12613652
function SSelfGoalAwardNotify:ctor(goal_times, award)
  self.id = 12613652
  self.goal_times = goal_times or nil
  self.award = award or AwardBean.new()
end
function SSelfGoalAwardNotify:marshal(os)
  os:marshalInt32(self.goal_times)
  self.award:marshal(os)
end
function SSelfGoalAwardNotify:unmarshal(os)
  self.goal_times = os:unmarshalInt32()
  self.award = AwardBean.new()
  self.award:unmarshal(os)
end
function SSelfGoalAwardNotify:sizepolicy(size)
  return size <= 65535
end
return SSelfGoalAwardNotify
