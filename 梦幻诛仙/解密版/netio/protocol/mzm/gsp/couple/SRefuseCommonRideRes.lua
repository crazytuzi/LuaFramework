local SRefuseCommonRideRes = class("SRefuseCommonRideRes")
SRefuseCommonRideRes.TYPEID = 12600583
function SRefuseCommonRideRes:ctor(refuseRoleid, refuseRoleName)
  self.id = 12600583
  self.refuseRoleid = refuseRoleid or nil
  self.refuseRoleName = refuseRoleName or nil
end
function SRefuseCommonRideRes:marshal(os)
  os:marshalInt64(self.refuseRoleid)
  os:marshalString(self.refuseRoleName)
end
function SRefuseCommonRideRes:unmarshal(os)
  self.refuseRoleid = os:unmarshalInt64()
  self.refuseRoleName = os:unmarshalString()
end
function SRefuseCommonRideRes:sizepolicy(size)
  return size <= 65535
end
return SRefuseCommonRideRes
