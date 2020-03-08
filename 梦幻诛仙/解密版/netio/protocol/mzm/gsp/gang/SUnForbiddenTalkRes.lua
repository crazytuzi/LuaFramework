local SUnForbiddenTalkRes = class("SUnForbiddenTalkRes")
SUnForbiddenTalkRes.TYPEID = 12589984
function SUnForbiddenTalkRes:ctor(roleId)
  self.id = 12589984
  self.roleId = roleId or nil
end
function SUnForbiddenTalkRes:marshal(os)
  os:marshalInt64(self.roleId)
end
function SUnForbiddenTalkRes:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function SUnForbiddenTalkRes:sizepolicy(size)
  return size <= 65535
end
return SUnForbiddenTalkRes
