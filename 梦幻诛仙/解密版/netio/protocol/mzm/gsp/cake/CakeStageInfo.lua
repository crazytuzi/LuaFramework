local OctetsStream = require("netio.OctetsStream")
local CakeStageInfo = class("CakeStageInfo")
function CakeStageInfo:ctor(turn, stage, stageStartTime)
  self.turn = turn or nil
  self.stage = stage or nil
  self.stageStartTime = stageStartTime or nil
end
function CakeStageInfo:marshal(os)
  os:marshalInt32(self.turn)
  os:marshalInt32(self.stage)
  os:marshalInt64(self.stageStartTime)
end
function CakeStageInfo:unmarshal(os)
  self.turn = os:unmarshalInt32()
  self.stage = os:unmarshalInt32()
  self.stageStartTime = os:unmarshalInt64()
end
return CakeStageInfo
