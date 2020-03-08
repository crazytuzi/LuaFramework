local SSyncCancelTanHe = class("SSyncCancelTanHe")
SSyncCancelTanHe.TYPEID = 12589870
function SSyncCancelTanHe:ctor(roleId)
  self.id = 12589870
  self.roleId = roleId or nil
end
function SSyncCancelTanHe:marshal(os)
  os:marshalInt64(self.roleId)
end
function SSyncCancelTanHe:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function SSyncCancelTanHe:sizepolicy(size)
  return size <= 65535
end
return SSyncCancelTanHe
