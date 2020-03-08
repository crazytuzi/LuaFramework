local CLockHunReq = class("CLockHunReq")
CLockHunReq.TYPEID = 12584787
function CLockHunReq:ctor(bagid, uuid, hunIndex, isAutoCostYuanbao)
  self.id = 12584787
  self.bagid = bagid or nil
  self.uuid = uuid or nil
  self.hunIndex = hunIndex or nil
  self.isAutoCostYuanbao = isAutoCostYuanbao or nil
end
function CLockHunReq:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt64(self.uuid)
  os:marshalUInt8(self.hunIndex)
  os:marshalUInt8(self.isAutoCostYuanbao)
end
function CLockHunReq:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.uuid = os:unmarshalInt64()
  self.hunIndex = os:unmarshalUInt8()
  self.isAutoCostYuanbao = os:unmarshalUInt8()
end
function CLockHunReq:sizepolicy(size)
  return size <= 65535
end
return CLockHunReq
