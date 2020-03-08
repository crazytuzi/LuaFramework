local SReceiveInviteStartTaskRes = class("SReceiveInviteStartTaskRes")
SReceiveInviteStartTaskRes.TYPEID = 12610313
function SReceiveInviteStartTaskRes:ctor(typeid, graphid)
  self.id = 12610313
  self.typeid = typeid or nil
  self.graphid = graphid or nil
end
function SReceiveInviteStartTaskRes:marshal(os)
  os:marshalInt32(self.typeid)
  os:marshalInt32(self.graphid)
end
function SReceiveInviteStartTaskRes:unmarshal(os)
  self.typeid = os:unmarshalInt32()
  self.graphid = os:unmarshalInt32()
end
function SReceiveInviteStartTaskRes:sizepolicy(size)
  return size <= 65535
end
return SReceiveInviteStartTaskRes
