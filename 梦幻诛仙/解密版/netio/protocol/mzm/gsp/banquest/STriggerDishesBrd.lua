local STriggerDishesBrd = class("STriggerDishesBrd")
STriggerDishesBrd.TYPEID = 12605956
function STriggerDishesBrd:ctor(tigger_count, delay_seconds)
  self.id = 12605956
  self.tigger_count = tigger_count or nil
  self.delay_seconds = delay_seconds or nil
end
function STriggerDishesBrd:marshal(os)
  os:marshalInt32(self.tigger_count)
  os:marshalInt32(self.delay_seconds)
end
function STriggerDishesBrd:unmarshal(os)
  self.tigger_count = os:unmarshalInt32()
  self.delay_seconds = os:unmarshalInt32()
end
function STriggerDishesBrd:sizepolicy(size)
  return size <= 65535
end
return STriggerDishesBrd
