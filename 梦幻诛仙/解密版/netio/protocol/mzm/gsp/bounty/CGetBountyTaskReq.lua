local CGetBountyTaskReq = class("CGetBountyTaskReq")
CGetBountyTaskReq.TYPEID = 12584195
function CGetBountyTaskReq:ctor(graphId, taskId)
  self.id = 12584195
  self.graphId = graphId or nil
  self.taskId = taskId or nil
end
function CGetBountyTaskReq:marshal(os)
  os:marshalInt32(self.graphId)
  os:marshalInt32(self.taskId)
end
function CGetBountyTaskReq:unmarshal(os)
  self.graphId = os:unmarshalInt32()
  self.taskId = os:unmarshalInt32()
end
function CGetBountyTaskReq:sizepolicy(size)
  return size <= 65535
end
return CGetBountyTaskReq
