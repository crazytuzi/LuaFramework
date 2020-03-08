local SRevengeItemAssignRoleFail = class("SRevengeItemAssignRoleFail")
SRevengeItemAssignRoleFail.TYPEID = 12619789
SRevengeItemAssignRoleFail.TARGET_NOT_FOUND = 1
SRevengeItemAssignRoleFail.CANNOT_ASSIGN_SELF = 2
SRevengeItemAssignRoleFail.ALREADY_ASSIGNED = 3
function SRevengeItemAssignRoleFail:ctor(retcode)
  self.id = 12619789
  self.retcode = retcode or nil
end
function SRevengeItemAssignRoleFail:marshal(os)
  os:marshalInt32(self.retcode)
end
function SRevengeItemAssignRoleFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SRevengeItemAssignRoleFail:sizepolicy(size)
  return size <= 65535
end
return SRevengeItemAssignRoleFail
