local SGetRoleInfoByNameFail = class("SGetRoleInfoByNameFail")
SGetRoleInfoByNameFail.TYPEID = 12586035
SGetRoleInfoByNameFail.NO_SUCH_ROLE = 1
function SGetRoleInfoByNameFail:ctor(res)
  self.id = 12586035
  self.res = res or nil
end
function SGetRoleInfoByNameFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetRoleInfoByNameFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetRoleInfoByNameFail:sizepolicy(size)
  return size <= 65535
end
return SGetRoleInfoByNameFail
