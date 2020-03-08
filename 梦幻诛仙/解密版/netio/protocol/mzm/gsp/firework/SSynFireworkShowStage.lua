local FireWorkStageInfo = require("netio.protocol.mzm.gsp.firework.FireWorkStageInfo")
local SSynFireworkShowStage = class("SSynFireworkShowStage")
SSynFireworkShowStage.TYPEID = 12625157
function SSynFireworkShowStage:ctor(activityId, stageInfo)
  self.id = 12625157
  self.activityId = activityId or nil
  self.stageInfo = stageInfo or FireWorkStageInfo.new()
end
function SSynFireworkShowStage:marshal(os)
  os:marshalInt32(self.activityId)
  self.stageInfo:marshal(os)
end
function SSynFireworkShowStage:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.stageInfo = FireWorkStageInfo.new()
  self.stageInfo:unmarshal(os)
end
function SSynFireworkShowStage:sizepolicy(size)
  return size <= 65535
end
return SSynFireworkShowStage
