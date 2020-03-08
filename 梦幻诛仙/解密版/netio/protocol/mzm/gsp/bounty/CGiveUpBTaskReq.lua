local CGiveUpBTaskReq = class("CGiveUpBTaskReq")
CGiveUpBTaskReq.TYPEID = 12584198
function CGiveUpBTaskReq:ctor(graphId, taskId)
  self.id = 12584198
  self.graphId = graphId or nil
  self.taskId = taskId or nil
end
function CGiveUpBTaskReq:marshal(os)
  os:marshalInt32(self.graphId)
  os:marshalInt32(self.taskId)
end
function CGiveUpBTaskReq:unmarshal(os)
  self.graphId = os:unmarshalInt32()
  self.taskId = os:unmarshalInt32()
end
function CGiveUpBTaskReq:sizepolicy(size)
  return size <= 65535
end
return CGiveUpBTaskReq
