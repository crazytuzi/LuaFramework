local OctetsStream = require("netio.OctetsStream")
local FireWorkStageInfo = class("FireWorkStageInfo")
FireWorkStageInfo.STAGE_FIND = 1
FireWorkStageInfo.STAGE_COUNT_DOWN = 2
FireWorkStageInfo.STAGE_SHOW = 3
function FireWorkStageInfo:ctor(stage, stageStartTime)
  self.stage = stage or nil
  self.stageStartTime = stageStartTime or nil
end
function FireWorkStageInfo:marshal(os)
  os:marshalInt32(self.stage)
  os:marshalInt64(self.stageStartTime)
end
function FireWorkStageInfo:unmarshal(os)
  self.stage = os:unmarshalInt32()
  self.stageStartTime = os:unmarshalInt64()
end
return FireWorkStageInfo
