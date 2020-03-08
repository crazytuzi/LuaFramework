local CakeStageInfo = require("netio.protocol.mzm.gsp.cake.CakeStageInfo")
local SMakeCakeStageBro = class("SMakeCakeStageBro")
SMakeCakeStageBro.TYPEID = 12627715
function SMakeCakeStageBro:ctor(activityId, stageInfo)
  self.id = 12627715
  self.activityId = activityId or nil
  self.stageInfo = stageInfo or CakeStageInfo.new()
end
function SMakeCakeStageBro:marshal(os)
  os:marshalInt32(self.activityId)
  self.stageInfo:marshal(os)
end
function SMakeCakeStageBro:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.stageInfo = CakeStageInfo.new()
  self.stageInfo:unmarshal(os)
end
function SMakeCakeStageBro:sizepolicy(size)
  return size <= 65535
end
return SMakeCakeStageBro
