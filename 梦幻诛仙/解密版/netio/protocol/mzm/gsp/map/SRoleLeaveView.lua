local SRoleLeaveView = class("SRoleLeaveView")
SRoleLeaveView.TYPEID = 12590851
function SRoleLeaveView:ctor(roleId)
  self.id = 12590851
  self.roleId = roleId or nil
end
function SRoleLeaveView:marshal(os)
  os:marshalInt64(self.roleId)
end
function SRoleLeaveView:unmarshal(os)
  self.roleId = os:unmarshalInt64()
end
function SRoleLeaveView:sizepolicy(size)
  return size <= 65535
end
return SRoleLeaveView
