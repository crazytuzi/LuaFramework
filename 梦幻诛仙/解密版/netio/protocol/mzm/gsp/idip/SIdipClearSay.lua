local SIdipClearSay = class("SIdipClearSay")
SIdipClearSay.TYPEID = 12601096
function SIdipClearSay:ctor(roleid)
  self.id = 12601096
  self.roleid = roleid or nil
end
function SIdipClearSay:marshal(os)
  os:marshalInt64(self.roleid)
end
function SIdipClearSay:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function SIdipClearSay:sizepolicy(size)
  return size <= 65535
end
return SIdipClearSay
