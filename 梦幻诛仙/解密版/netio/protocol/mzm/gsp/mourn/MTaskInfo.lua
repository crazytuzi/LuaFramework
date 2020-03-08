local OctetsStream = require("netio.OctetsStream")
local MTaskInfo = class("MTaskInfo")
MTaskInfo.UN_ACCEPTED = 1
MTaskInfo.ALREADY_ACCEPTED = 2
MTaskInfo.FINISHED = 3
function MTaskInfo:ctor(state)
  self.state = state or nil
end
function MTaskInfo:marshal(os)
  os:marshalInt32(self.state)
end
function MTaskInfo:unmarshal(os)
  self.state = os:unmarshalInt32()
end
return MTaskInfo
