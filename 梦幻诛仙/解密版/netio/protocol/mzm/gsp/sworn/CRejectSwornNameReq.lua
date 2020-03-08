local CRejectSwornNameReq = class("CRejectSwornNameReq")
CRejectSwornNameReq.TYPEID = 12597770
function CRejectSwornNameReq:ctor(swornid)
  self.id = 12597770
  self.swornid = swornid or nil
end
function CRejectSwornNameReq:marshal(os)
  os:marshalInt64(self.swornid)
end
function CRejectSwornNameReq:unmarshal(os)
  self.swornid = os:unmarshalInt64()
end
function CRejectSwornNameReq:sizepolicy(size)
  return size <= 65535
end
return CRejectSwornNameReq
