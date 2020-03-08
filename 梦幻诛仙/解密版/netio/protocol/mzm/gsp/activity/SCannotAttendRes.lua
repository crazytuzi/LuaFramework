local SCannotAttendRes = class("SCannotAttendRes")
SCannotAttendRes.TYPEID = 12587538
function SCannotAttendRes:ctor(roleid)
  self.id = 12587538
  self.roleid = roleid or nil
end
function SCannotAttendRes:marshal(os)
  os:marshalInt64(self.roleid)
end
function SCannotAttendRes:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function SCannotAttendRes:sizepolicy(size)
  return size <= 65535
end
return SCannotAttendRes
