local CRobotFinishTask = class("CRobotFinishTask")
CRobotFinishTask.TYPEID = 12592145
function CRobotFinishTask:ctor(graphId, taskId)
  self.id = 12592145
  self.graphId = graphId or nil
  self.taskId = taskId or nil
end
function CRobotFinishTask:marshal(os)
  os:marshalInt32(self.graphId)
  os:marshalInt32(self.taskId)
end
function CRobotFinishTask:unmarshal(os)
  self.graphId = os:unmarshalInt32()
  self.taskId = os:unmarshalInt32()
end
function CRobotFinishTask:sizepolicy(size)
  return size <= 65535
end
return CRobotFinishTask
