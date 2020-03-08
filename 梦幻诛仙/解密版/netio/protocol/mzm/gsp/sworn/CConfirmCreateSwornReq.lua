local CConfirmCreateSwornReq = class("CConfirmCreateSwornReq")
CConfirmCreateSwornReq.TYPEID = 12597782
function CConfirmCreateSwornReq:ctor(swornid)
  self.id = 12597782
  self.swornid = swornid or nil
end
function CConfirmCreateSwornReq:marshal(os)
  os:marshalInt64(self.swornid)
end
function CConfirmCreateSwornReq:unmarshal(os)
  self.swornid = os:unmarshalInt64()
end
function CConfirmCreateSwornReq:sizepolicy(size)
  return size <= 65535
end
return CConfirmCreateSwornReq
