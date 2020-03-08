local CGiveUpTaskReq = class("CGiveUpTaskReq")
CGiveUpTaskReq.TYPEID = 12592139
function CGiveUpTaskReq:ctor(taskId, graphId)
  self.id = 12592139
  self.taskId = taskId or nil
  self.graphId = graphId or nil
end
function CGiveUpTaskReq:marshal(os)
  os:marshalInt32(self.taskId)
  os:marshalInt32(self.graphId)
end
function CGiveUpTaskReq:unmarshal(os)
  self.taskId = os:unmarshalInt32()
  self.graphId = os:unmarshalInt32()
end
function CGiveUpTaskReq:sizepolicy(size)
  return size <= 65535
end
return CGiveUpTaskReq
