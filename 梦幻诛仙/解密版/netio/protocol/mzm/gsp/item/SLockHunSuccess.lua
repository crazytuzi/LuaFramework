local SLockHunSuccess = class("SLockHunSuccess")
SLockHunSuccess.TYPEID = 12584820
function SLockHunSuccess:ctor(bagid, uuid, hunIndex)
  self.id = 12584820
  self.bagid = bagid or nil
  self.uuid = uuid or nil
  self.hunIndex = hunIndex or nil
end
function SLockHunSuccess:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt64(self.uuid)
  os:marshalUInt8(self.hunIndex)
end
function SLockHunSuccess:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.uuid = os:unmarshalInt64()
  self.hunIndex = os:unmarshalUInt8()
end
function SLockHunSuccess:sizepolicy(size)
  return size <= 65535
end
return SLockHunSuccess
