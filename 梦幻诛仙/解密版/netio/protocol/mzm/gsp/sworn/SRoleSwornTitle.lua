local SRoleSwornTitle = class("SRoleSwornTitle")
SRoleSwornTitle.TYPEID = 12597778
function SRoleSwornTitle:ctor(swornid, roleid, title)
  self.id = 12597778
  self.swornid = swornid or nil
  self.roleid = roleid or nil
  self.title = title or nil
end
function SRoleSwornTitle:marshal(os)
  os:marshalInt64(self.swornid)
  os:marshalInt64(self.roleid)
  os:marshalString(self.title)
end
function SRoleSwornTitle:unmarshal(os)
  self.swornid = os:unmarshalInt64()
  self.roleid = os:unmarshalInt64()
  self.title = os:unmarshalString()
end
function SRoleSwornTitle:sizepolicy(size)
  return size <= 65535
end
return SRoleSwornTitle
