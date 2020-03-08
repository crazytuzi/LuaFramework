local SRoleSwornTitleChange = class("SRoleSwornTitleChange")
SRoleSwornTitleChange.TYPEID = 12597783
function SRoleSwornTitleChange:ctor(swornid, roleid, title)
  self.id = 12597783
  self.swornid = swornid or nil
  self.roleid = roleid or nil
  self.title = title or nil
end
function SRoleSwornTitleChange:marshal(os)
  os:marshalInt64(self.swornid)
  os:marshalInt64(self.roleid)
  os:marshalString(self.title)
end
function SRoleSwornTitleChange:unmarshal(os)
  self.swornid = os:unmarshalInt64()
  self.roleid = os:unmarshalInt64()
  self.title = os:unmarshalString()
end
function SRoleSwornTitleChange:sizepolicy(size)
  return size <= 65535
end
return SRoleSwornTitleChange
