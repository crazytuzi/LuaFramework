local SRoleLeave = class("SRoleLeave")
SRoleLeave.TYPEID = 12597787
function SRoleLeave:ctor(swornid, roleid)
  self.id = 12597787
  self.swornid = swornid or nil
  self.roleid = roleid or nil
end
function SRoleLeave:marshal(os)
  os:marshalInt64(self.swornid)
  os:marshalInt64(self.roleid)
end
function SRoleLeave:unmarshal(os)
  self.swornid = os:unmarshalInt64()
  self.roleid = os:unmarshalInt64()
end
function SRoleLeave:sizepolicy(size)
  return size <= 65535
end
return SRoleLeave
