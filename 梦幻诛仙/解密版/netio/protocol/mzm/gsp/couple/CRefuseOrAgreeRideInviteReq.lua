local CRefuseOrAgreeRideInviteReq = class("CRefuseOrAgreeRideInviteReq")
CRefuseOrAgreeRideInviteReq.TYPEID = 12600584
CRefuseOrAgreeRideInviteReq.AGREE = 0
CRefuseOrAgreeRideInviteReq.REFUSE = 1
function CRefuseOrAgreeRideInviteReq:ctor(sessionid, operate)
  self.id = 12600584
  self.sessionid = sessionid or nil
  self.operate = operate or nil
end
function CRefuseOrAgreeRideInviteReq:marshal(os)
  os:marshalInt64(self.sessionid)
  os:marshalInt32(self.operate)
end
function CRefuseOrAgreeRideInviteReq:unmarshal(os)
  self.sessionid = os:unmarshalInt64()
  self.operate = os:unmarshalInt32()
end
function CRefuseOrAgreeRideInviteReq:sizepolicy(size)
  return size <= 65535
end
return CRefuseOrAgreeRideInviteReq
