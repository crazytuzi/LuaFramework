local CSendStartTaskReq = class("CSendStartTaskReq")
CSendStartTaskReq.TYPEID = 12610319
function CSendStartTaskReq:ctor(result, typeid, graphid)
  self.id = 12610319
  self.result = result or nil
  self.typeid = typeid or nil
  self.graphid = graphid or nil
end
function CSendStartTaskReq:marshal(os)
  os:marshalInt32(self.result)
  os:marshalInt32(self.typeid)
  os:marshalInt32(self.graphid)
end
function CSendStartTaskReq:unmarshal(os)
  self.result = os:unmarshalInt32()
  self.typeid = os:unmarshalInt32()
  self.graphid = os:unmarshalInt32()
end
function CSendStartTaskReq:sizepolicy(size)
  return size <= 65535
end
return CSendStartTaskReq
