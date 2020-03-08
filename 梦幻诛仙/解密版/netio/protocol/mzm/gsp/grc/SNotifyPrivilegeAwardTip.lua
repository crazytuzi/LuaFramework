local SNotifyPrivilegeAwardTip = class("SNotifyPrivilegeAwardTip")
SNotifyPrivilegeAwardTip.TYPEID = 12600345
SNotifyPrivilegeAwardTip.AWARD_TYPE_SIGN = 1
function SNotifyPrivilegeAwardTip:ctor(award_type, privilege_type)
  self.id = 12600345
  self.award_type = award_type or nil
  self.privilege_type = privilege_type or nil
end
function SNotifyPrivilegeAwardTip:marshal(os)
  os:marshalInt32(self.award_type)
  os:marshalInt32(self.privilege_type)
end
function SNotifyPrivilegeAwardTip:unmarshal(os)
  self.award_type = os:unmarshalInt32()
  self.privilege_type = os:unmarshalInt32()
end
function SNotifyPrivilegeAwardTip:sizepolicy(size)
  return size <= 65535
end
return SNotifyPrivilegeAwardTip
