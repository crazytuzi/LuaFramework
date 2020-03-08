local CConfirmRefreshHunReq = class("CConfirmRefreshHunReq")
CConfirmRefreshHunReq.TYPEID = 12584819
function CConfirmRefreshHunReq:ctor(bagid, uuid, isReplace)
  self.id = 12584819
  self.bagid = bagid or nil
  self.uuid = uuid or nil
  self.isReplace = isReplace or nil
end
function CConfirmRefreshHunReq:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt64(self.uuid)
  os:marshalUInt8(self.isReplace)
end
function CConfirmRefreshHunReq:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.uuid = os:unmarshalInt64()
  self.isReplace = os:unmarshalUInt8()
end
function CConfirmRefreshHunReq:sizepolicy(size)
  return size <= 65535
end
return CConfirmRefreshHunReq
