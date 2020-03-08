local OctetsStream = require("netio.OctetsStream")
local BackGameActivityTaskInfo = class("BackGameActivityTaskInfo")
BackGameActivityTaskInfo.NOT_FINISHED = 0
BackGameActivityTaskInfo.FINISHED = 1
function BackGameActivityTaskInfo:ctor(task_state)
  self.task_state = task_state or nil
end
function BackGameActivityTaskInfo:marshal(os)
  os:marshalInt32(self.task_state)
end
function BackGameActivityTaskInfo:unmarshal(os)
  self.task_state = os:unmarshalInt32()
end
return BackGameActivityTaskInfo
