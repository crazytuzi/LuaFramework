local CStartPKReq = class("CStartPKReq")
CStartPKReq.TYPEID = 12619792
function CStartPKReq:ctor(role_id)
  self.id = 12619792
  self.role_id = role_id or nil
end
function CStartPKReq:marshal(os)
  os:marshalInt64(self.role_id)
end
function CStartPKReq:unmarshal(os)
  self.role_id = os:unmarshalInt64()
end
function CStartPKReq:sizepolicy(size)
  return size <= 65535
end
return CStartPKReq
