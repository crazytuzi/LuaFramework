local CAgreeSwornNameReq = class("CAgreeSwornNameReq")
CAgreeSwornNameReq.TYPEID = 12597767
function CAgreeSwornNameReq:ctor(swornid)
  self.id = 12597767
  self.swornid = swornid or nil
end
function CAgreeSwornNameReq:marshal(os)
  os:marshalInt64(self.swornid)
end
function CAgreeSwornNameReq:unmarshal(os)
  self.swornid = os:unmarshalInt64()
end
function CAgreeSwornNameReq:sizepolicy(size)
  return size <= 65535
end
return CAgreeSwornNameReq
