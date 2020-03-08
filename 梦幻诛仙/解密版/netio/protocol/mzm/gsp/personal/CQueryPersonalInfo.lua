local CQueryPersonalInfo = class("CQueryPersonalInfo")
CQueryPersonalInfo.TYPEID = 12603656
function CQueryPersonalInfo:ctor(roleId)
  self.id = 12603656
  self.roleId = roleId or nil
end
function CQueryPersonalInfo:marshal(os)
  os:marshalInt64(self.roleId)
end
function CQueryPersonalInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function CQueryPersonalInfo:sizepolicy(size)
  return size <= 65535
end
return CQueryPersonalInfo
