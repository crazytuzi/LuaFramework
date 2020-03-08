local CUnForbiddenTalkReq = class("CUnForbiddenTalkReq")
CUnForbiddenTalkReq.TYPEID = 12589887
function CUnForbiddenTalkReq:ctor(roleId)
  self.id = 12589887
  self.roleId = roleId or nil
end
function CUnForbiddenTalkReq:marshal(os)
  os:marshalInt64(self.roleId)
end
function CUnForbiddenTalkReq:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function CUnForbiddenTalkReq:sizepolicy(size)
  return size <= 65535
end
return CUnForbiddenTalkReq
