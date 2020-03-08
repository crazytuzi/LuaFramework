local STriggerMapItemsBrd = class("STriggerMapItemsBrd")
STriggerMapItemsBrd.TYPEID = 12598533
function STriggerMapItemsBrd:ctor(delay_seconds)
  self.id = 12598533
  self.delay_seconds = delay_seconds or nil
end
function STriggerMapItemsBrd:marshal(os)
  os:marshalInt32(self.delay_seconds)
end
function STriggerMapItemsBrd:unmarshal(os)
  self.delay_seconds = os:unmarshalInt32()
end
function STriggerMapItemsBrd:sizepolicy(size)
  return size <= 65535
end
return STriggerMapItemsBrd
