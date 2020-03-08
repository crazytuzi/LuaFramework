local CGetMemberExtroInfoReq = class("CGetMemberExtroInfoReq")
CGetMemberExtroInfoReq.TYPEID = 12617491
function CGetMemberExtroInfoReq:ctor(member)
  self.id = 12617491
  self.member = member or nil
end
function CGetMemberExtroInfoReq:marshal(os)
  os:marshalInt64(self.member)
end
function CGetMemberExtroInfoReq:unmarshal(os)
  self.member = os:unmarshalInt64()
end
function CGetMemberExtroInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetMemberExtroInfoReq
