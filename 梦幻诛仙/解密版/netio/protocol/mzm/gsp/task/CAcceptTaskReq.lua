local CAcceptTaskReq = class("CAcceptTaskReq")
CAcceptTaskReq.TYPEID = 12592134
function CAcceptTaskReq:ctor(taskId, graphId)
  self.id = 12592134
  self.taskId = taskId or nil
  self.graphId = graphId or nil
end
function CAcceptTaskReq:marshal(os)
  os:marshalInt32(self.taskId)
  os:marshalInt32(self.graphId)
end
function CAcceptTaskReq:unmarshal(os)
  self.taskId = os:unmarshalInt32()
  self.graphId = os:unmarshalInt32()
end
function CAcceptTaskReq:sizepolicy(size)
  return size <= 65535
end
return CAcceptTaskReq
