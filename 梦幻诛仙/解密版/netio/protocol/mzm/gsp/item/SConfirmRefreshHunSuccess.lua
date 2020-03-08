local SConfirmRefreshHunSuccess = class("SConfirmRefreshHunSuccess")
SConfirmRefreshHunSuccess.TYPEID = 12584817
function SConfirmRefreshHunSuccess:ctor(bagid, uuid, isReplace)
  self.id = 12584817
  self.bagid = bagid or nil
  self.uuid = uuid or nil
  self.isReplace = isReplace or nil
end
function SConfirmRefreshHunSuccess:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt64(self.uuid)
  os:marshalUInt8(self.isReplace)
end
function SConfirmRefreshHunSuccess:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.uuid = os:unmarshalInt64()
  self.isReplace = os:unmarshalUInt8()
end
function SConfirmRefreshHunSuccess:sizepolicy(size)
  return size <= 65535
end
return SConfirmRefreshHunSuccess
