local OctetsStream = require("netio.OctetsStream")
local LevelGuideInfo = class("LevelGuideInfo")
LevelGuideInfo.ST_ON_GOING = 1
LevelGuideInfo.ST_FINISHED = 2
LevelGuideInfo.ST_HAND_UP = 3
function LevelGuideInfo:ctor(targetId, targetState)
  self.targetId = targetId or nil
  self.targetState = targetState or nil
end
function LevelGuideInfo:marshal(os)
  os:marshalInt32(self.targetId)
  os:marshalInt32(self.targetState)
end
function LevelGuideInfo:unmarshal(os)
  self.targetId = os:unmarshalInt32()
  self.targetState = os:unmarshalInt32()
end
return LevelGuideInfo
