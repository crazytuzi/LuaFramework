local CSendInviteStartTaskReq = class("CSendInviteStartTaskReq")
CSendInviteStartTaskReq.TYPEID = 12610320
function CSendInviteStartTaskReq:ctor(typeid, graphid)
  self.id = 12610320
  self.typeid = typeid or nil
  self.graphid = graphid or nil
end
function CSendInviteStartTaskReq:marshal(os)
  os:marshalInt32(self.typeid)
  os:marshalInt32(self.graphid)
end
function CSendInviteStartTaskReq:unmarshal(os)
  self.typeid = os:unmarshalInt32()
  self.graphid = os:unmarshalInt32()
end
function CSendInviteStartTaskReq:sizepolicy(size)
  return size <= 65535
end
return CSendInviteStartTaskReq
