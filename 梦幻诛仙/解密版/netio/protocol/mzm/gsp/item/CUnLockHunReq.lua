local CUnLockHunReq = class("CUnLockHunReq")
CUnLockHunReq.TYPEID = 12584788
function CUnLockHunReq:ctor(bagid, uuid, hunIndex)
  self.id = 12584788
  self.bagid = bagid or nil
  self.uuid = uuid or nil
  self.hunIndex = hunIndex or nil
end
function CUnLockHunReq:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt64(self.uuid)
  os:marshalUInt8(self.hunIndex)
end
function CUnLockHunReq:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.uuid = os:unmarshalInt64()
  self.hunIndex = os:unmarshalUInt8()
end
function CUnLockHunReq:sizepolicy(size)
  return size <= 65535
end
return CUnLockHunReq
