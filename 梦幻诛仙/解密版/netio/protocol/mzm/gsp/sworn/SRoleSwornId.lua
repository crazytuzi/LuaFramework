local SRoleSwornId = class("SRoleSwornId")
SRoleSwornId.TYPEID = 12597781
function SRoleSwornId:ctor(swornid)
  self.id = 12597781
  self.swornid = swornid or nil
end
function SRoleSwornId:marshal(os)
  os:marshalInt64(self.swornid)
end
function SRoleSwornId:unmarshal(os)
  self.swornid = os:unmarshalInt64()
end
function SRoleSwornId:sizepolicy(size)
  return size <= 65535
end
return SRoleSwornId
