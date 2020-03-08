local CDissolveGroupReq = class("CDissolveGroupReq")
CDissolveGroupReq.TYPEID = 12605197
function CDissolveGroupReq:ctor(groupid)
  self.id = 12605197
  self.groupid = groupid or nil
end
function CDissolveGroupReq:marshal(os)
  os:marshalInt64(self.groupid)
end
function CDissolveGroupReq:unmarshal(os)
  self.groupid = os:unmarshalInt64()
end
function CDissolveGroupReq:sizepolicy(size)
  return size <= 65535
end
return CDissolveGroupReq
