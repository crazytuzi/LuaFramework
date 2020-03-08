local SExpressionPlayRes = class("SExpressionPlayRes")
SExpressionPlayRes.TYPEID = 12590945
function SExpressionPlayRes:ctor(roleid, actionEnum)
  self.id = 12590945
  self.roleid = roleid or nil
  self.actionEnum = actionEnum or nil
end
function SExpressionPlayRes:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.actionEnum)
end
function SExpressionPlayRes:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.actionEnum = os:unmarshalInt32()
end
function SExpressionPlayRes:sizepolicy(size)
  return size <= 65535
end
return SExpressionPlayRes
