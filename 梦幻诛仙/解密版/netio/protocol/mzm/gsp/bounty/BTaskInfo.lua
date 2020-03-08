local OctetsStream = require("netio.OctetsStream")
local BTaskInfo = class("BTaskInfo")
BTaskInfo.UN_ACCEPTED = 0
BTaskInfo.ALREADY_ACCEPTED = 1
BTaskInfo.FINISHED = 2
BTaskInfo.GIVE_UP = 3
function BTaskInfo:ctor(taskId, taskState)
  self.taskId = taskId or nil
  self.taskState = taskState or nil
end
function BTaskInfo:marshal(os)
  os:marshalInt32(self.taskId)
  os:marshalInt32(self.taskState)
end
function BTaskInfo:unmarshal(os)
  self.taskId = os:unmarshalInt32()
  self.taskState = os:unmarshalInt32()
end
return BTaskInfo
