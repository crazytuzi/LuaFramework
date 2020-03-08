local CForbiddenTalkReq = class("CForbiddenTalkReq")
CForbiddenTalkReq.TYPEID = 12589837
function CForbiddenTalkReq:ctor(roleId)
  self.id = 12589837
  self.roleId = roleId or nil
end
function CForbiddenTalkReq:marshal(os)
  os:marshalInt64(self.roleId)
end
function CForbiddenTalkReq:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function CForbiddenTalkReq:sizepolicy(size)
  return size <= 65535
end
return CForbiddenTalkReq
