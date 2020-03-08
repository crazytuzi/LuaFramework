local CRefreshHunReq = class("CRefreshHunReq")
CRefreshHunReq.TYPEID = 12584818
function CRefreshHunReq:ctor(bagid, uuid, isUseYuanbao, clientYuanbaoNum, clientNeedYuanbaoNum)
  self.id = 12584818
  self.bagid = bagid or nil
  self.uuid = uuid or nil
  self.isUseYuanbao = isUseYuanbao or nil
  self.clientYuanbaoNum = clientYuanbaoNum or nil
  self.clientNeedYuanbaoNum = clientNeedYuanbaoNum or nil
end
function CRefreshHunReq:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt64(self.uuid)
  os:marshalInt32(self.isUseYuanbao)
  os:marshalInt64(self.clientYuanbaoNum)
  os:marshalInt32(self.clientNeedYuanbaoNum)
end
function CRefreshHunReq:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.uuid = os:unmarshalInt64()
  self.isUseYuanbao = os:unmarshalInt32()
  self.clientYuanbaoNum = os:unmarshalInt64()
  self.clientNeedYuanbaoNum = os:unmarshalInt32()
end
function CRefreshHunReq:sizepolicy(size)
  return size <= 65535
end
return CRefreshHunReq
