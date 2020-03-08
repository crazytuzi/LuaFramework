local CItemClickRemoveReq = class("CItemClickRemoveReq")
CItemClickRemoveReq.TYPEID = 12584864
function CItemClickRemoveReq:ctor(uuid)
  self.id = 12584864
  self.uuid = uuid or nil
end
function CItemClickRemoveReq:marshal(os)
  os:marshalInt64(self.uuid)
end
function CItemClickRemoveReq:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CItemClickRemoveReq:sizepolicy(size)
  return size <= 65535
end
return CItemClickRemoveReq
