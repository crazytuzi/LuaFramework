local CGetSwornInfoReq = class("CGetSwornInfoReq")
CGetSwornInfoReq.TYPEID = 12597785
function CGetSwornInfoReq:ctor(swornid)
  self.id = 12597785
  self.swornid = swornid or nil
end
function CGetSwornInfoReq:marshal(os)
  os:marshalInt64(self.swornid)
end
function CGetSwornInfoReq:unmarshal(os)
  self.swornid = os:unmarshalInt64()
end
function CGetSwornInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetSwornInfoReq
