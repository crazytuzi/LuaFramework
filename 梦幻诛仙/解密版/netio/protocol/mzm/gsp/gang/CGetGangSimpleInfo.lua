local CGetGangSimpleInfo = class("CGetGangSimpleInfo")
CGetGangSimpleInfo.TYPEID = 12589874
function CGetGangSimpleInfo:ctor(roleId)
  self.id = 12589874
  self.roleId = roleId or nil
end
function CGetGangSimpleInfo:marshal(os)
  os:marshalInt64(self.roleId)
end
function CGetGangSimpleInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function CGetGangSimpleInfo:sizepolicy(size)
  return size <= 65535
end
return CGetGangSimpleInfo
