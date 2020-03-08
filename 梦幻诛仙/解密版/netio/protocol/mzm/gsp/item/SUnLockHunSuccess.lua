local SUnLockHunSuccess = class("SUnLockHunSuccess")
SUnLockHunSuccess.TYPEID = 12584816
function SUnLockHunSuccess:ctor(bagid, uuid, hunIndex)
  self.id = 12584816
  self.bagid = bagid or nil
  self.uuid = uuid or nil
  self.hunIndex = hunIndex or nil
end
function SUnLockHunSuccess:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt64(self.uuid)
  os:marshalUInt8(self.hunIndex)
end
function SUnLockHunSuccess:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.uuid = os:unmarshalInt64()
  self.hunIndex = os:unmarshalUInt8()
end
function SUnLockHunSuccess:sizepolicy(size)
  return size <= 65535
end
return SUnLockHunSuccess
