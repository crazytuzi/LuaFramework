local SBeFiredProtectStateChange = class("SBeFiredProtectStateChange")
SBeFiredProtectStateChange.TYPEID = 12588345
SBeFiredProtectStateChange.ENTER_PROTECT = 1
SBeFiredProtectStateChange.OUT_PROTECT = 2
function SBeFiredProtectStateChange:ctor(roleId, protectState)
  self.id = 12588345
  self.roleId = roleId or nil
  self.protectState = protectState or nil
end
function SBeFiredProtectStateChange:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.protectState)
end
function SBeFiredProtectStateChange:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.protectState = os:unmarshalInt32()
end
function SBeFiredProtectStateChange:sizepolicy(size)
  return size <= 65535
end
return SBeFiredProtectStateChange
