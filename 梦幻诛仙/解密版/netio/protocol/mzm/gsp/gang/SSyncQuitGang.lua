local SSyncQuitGang = class("SSyncQuitGang")
SSyncQuitGang.TYPEID = 12589853
function SSyncQuitGang:ctor(roleId)
  self.id = 12589853
  self.roleId = roleId or nil
end
function SSyncQuitGang:marshal(os)
  os:marshalInt64(self.roleId)
end
function SSyncQuitGang:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function SSyncQuitGang:sizepolicy(size)
  return size <= 65535
end
return SSyncQuitGang
