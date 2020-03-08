local CVisitHomeReq = class("CVisitHomeReq")
CVisitHomeReq.TYPEID = 12605468
function CVisitHomeReq:ctor(roleid)
  self.id = 12605468
  self.roleid = roleid or nil
end
function CVisitHomeReq:marshal(os)
  os:marshalInt64(self.roleid)
end
function CVisitHomeReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function CVisitHomeReq:sizepolicy(size)
  return size <= 65535
end
return CVisitHomeReq
