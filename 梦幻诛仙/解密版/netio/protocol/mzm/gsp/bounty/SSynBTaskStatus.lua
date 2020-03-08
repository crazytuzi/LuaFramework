local SSynBTaskStatus = class("SSynBTaskStatus")
SSynBTaskStatus.TYPEID = 12584197
function SSynBTaskStatus:ctor(graphId, taskId, taskState, bountyCount)
  self.id = 12584197
  self.graphId = graphId or nil
  self.taskId = taskId or nil
  self.taskState = taskState or nil
  self.bountyCount = bountyCount or nil
end
function SSynBTaskStatus:marshal(os)
  os:marshalInt32(self.graphId)
  os:marshalInt32(self.taskId)
  os:marshalInt32(self.taskState)
  os:marshalInt32(self.bountyCount)
end
function SSynBTaskStatus:unmarshal(os)
  self.graphId = os:unmarshalInt32()
  self.taskId = os:unmarshalInt32()
  self.taskState = os:unmarshalInt32()
  self.bountyCount = os:unmarshalInt32()
end
function SSynBTaskStatus:sizepolicy(size)
  return size <= 65535
end
return SSynBTaskStatus
