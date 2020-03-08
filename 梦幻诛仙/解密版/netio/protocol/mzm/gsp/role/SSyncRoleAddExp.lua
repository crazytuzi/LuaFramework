local SSyncRoleAddExp = class("SSyncRoleAddExp")
SSyncRoleAddExp.TYPEID = 12586012
function SSyncRoleAddExp:ctor(addExp)
  self.id = 12586012
  self.addExp = addExp or nil
end
function SSyncRoleAddExp:marshal(os)
  os:marshalInt32(self.addExp)
end
function SSyncRoleAddExp:unmarshal(os)
  self.addExp = os:unmarshalInt32()
end
function SSyncRoleAddExp:sizepolicy(size)
  return size <= 65535
end
return SSyncRoleAddExp
