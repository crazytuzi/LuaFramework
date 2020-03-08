local OctetsStream = require("netio.OctetsStream")
local TaskState = class("TaskState")
function TaskState:ctor(taskId, graphId, state)
  self.taskId = taskId or nil
  self.graphId = graphId or nil
  self.state = state or nil
end
function TaskState:marshal(os)
  os:marshalInt32(self.taskId)
  os:marshalInt32(self.graphId)
  os:marshalInt32(self.state)
end
function TaskState:unmarshal(os)
  self.taskId = os:unmarshalInt32()
  self.graphId = os:unmarshalInt32()
  self.state = os:unmarshalInt32()
end
return TaskState
