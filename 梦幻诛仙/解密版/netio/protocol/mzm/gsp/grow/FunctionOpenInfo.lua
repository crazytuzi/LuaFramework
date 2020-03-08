local OctetsStream = require("netio.OctetsStream")
local FunctionOpenInfo = class("FunctionOpenInfo")
FunctionOpenInfo.ST_ON_GOING = 1
FunctionOpenInfo.ST_FINISHED = 2
FunctionOpenInfo.ST_HAND_UP = 3
function FunctionOpenInfo:ctor(targetId, targetState)
  self.targetId = targetId or nil
  self.targetState = targetState or nil
end
function FunctionOpenInfo:marshal(os)
  os:marshalInt32(self.targetId)
  os:marshalInt32(self.targetState)
end
function FunctionOpenInfo:unmarshal(os)
  self.targetId = os:unmarshalInt32()
  self.targetState = os:unmarshalInt32()
end
return FunctionOpenInfo
