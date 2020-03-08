local TaskState = require("netio.protocol.mzm.gsp.task.TaskState")
local SUpdateTaskState = class("SUpdateTaskState")
SUpdateTaskState.TYPEID = 12592143
function SUpdateTaskState:ctor(taskState)
  self.id = 12592143
  self.taskState = taskState or TaskState.new()
end
function SUpdateTaskState:marshal(os)
  self.taskState:marshal(os)
end
function SUpdateTaskState:unmarshal(os)
  self.taskState = TaskState.new()
  self.taskState:unmarshal(os)
end
function SUpdateTaskState:sizepolicy(size)
  return size <= 65535
end
return SUpdateTaskState
