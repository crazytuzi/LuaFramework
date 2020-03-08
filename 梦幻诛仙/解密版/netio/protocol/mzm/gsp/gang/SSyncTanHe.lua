local SSyncTanHe = class("SSyncTanHe")
SSyncTanHe.TYPEID = 12589860
function SSyncTanHe:ctor(roleId)
  self.id = 12589860
  self.roleId = roleId or nil
end
function SSyncTanHe:marshal(os)
  os:marshalInt64(self.roleId)
end
function SSyncTanHe:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function SSyncTanHe:sizepolicy(size)
  return size <= 65535
end
return SSyncTanHe
