local SBeginSetSwornName = class("SBeginSetSwornName")
SBeginSetSwornName.TYPEID = 12597761
function SBeginSetSwornName:ctor(swornid, roleid)
  self.id = 12597761
  self.swornid = swornid or nil
  self.roleid = roleid or nil
end
function SBeginSetSwornName:marshal(os)
  os:marshalInt64(self.swornid)
  os:marshalInt64(self.roleid)
end
function SBeginSetSwornName:unmarshal(os)
  self.swornid = os:unmarshalInt64()
  self.roleid = os:unmarshalInt64()
end
function SBeginSetSwornName:sizepolicy(size)
  return size <= 65535
end
return SBeginSetSwornName
