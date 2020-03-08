local CPVPOtherReq = class("CPVPOtherReq")
CPVPOtherReq.TYPEID = 12591876
function CPVPOtherReq:ctor(passiveRoleid)
  self.id = 12591876
  self.passiveRoleid = passiveRoleid or nil
end
function CPVPOtherReq:marshal(os)
  os:marshalInt64(self.passiveRoleid)
end
function CPVPOtherReq:unmarshal(os)
  self.passiveRoleid = os:unmarshalInt64()
end
function CPVPOtherReq:sizepolicy(size)
  return size <= 65535
end
return CPVPOtherReq
