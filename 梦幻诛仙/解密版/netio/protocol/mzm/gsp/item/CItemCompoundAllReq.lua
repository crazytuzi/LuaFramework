local CItemCompoundAllReq = class("CItemCompoundAllReq")
CItemCompoundAllReq.TYPEID = 12584876
function CItemCompoundAllReq:ctor(uuid)
  self.id = 12584876
  self.uuid = uuid or nil
end
function CItemCompoundAllReq:marshal(os)
  os:marshalInt64(self.uuid)
end
function CItemCompoundAllReq:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CItemCompoundAllReq:sizepolicy(size)
  return size <= 65535
end
return CItemCompoundAllReq
