local SDeductActionPointNotify = class("SDeductActionPointNotify")
SDeductActionPointNotify.TYPEID = 12616722
SDeductActionPointNotify.REASON__ENTER_LATER = 1
SDeductActionPointNotify.REASON__ATTACK = 2
SDeductActionPointNotify.REASON__LOSE_FIGHT = 3
SDeductActionPointNotify.REASON__ESCAPE_FIGHT = 4
function SDeductActionPointNotify:ctor(deduct_value, reason)
  self.id = 12616722
  self.deduct_value = deduct_value or nil
  self.reason = reason or nil
end
function SDeductActionPointNotify:marshal(os)
  os:marshalInt32(self.deduct_value)
  os:marshalInt32(self.reason)
end
function SDeductActionPointNotify:unmarshal(os)
  self.deduct_value = os:unmarshalInt32()
  self.reason = os:unmarshalInt32()
end
function SDeductActionPointNotify:sizepolicy(size)
  return size <= 65535
end
return SDeductActionPointNotify
