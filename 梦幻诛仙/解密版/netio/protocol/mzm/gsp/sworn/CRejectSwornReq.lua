local CRejectSwornReq = class("CRejectSwornReq")
CRejectSwornReq.TYPEID = 12597773
function CRejectSwornReq:ctor(swornid)
  self.id = 12597773
  self.swornid = swornid or nil
end
function CRejectSwornReq:marshal(os)
  os:marshalInt64(self.swornid)
end
function CRejectSwornReq:unmarshal(os)
  self.swornid = os:unmarshalInt64()
end
function CRejectSwornReq:sizepolicy(size)
  return size <= 65535
end
return CRejectSwornReq
