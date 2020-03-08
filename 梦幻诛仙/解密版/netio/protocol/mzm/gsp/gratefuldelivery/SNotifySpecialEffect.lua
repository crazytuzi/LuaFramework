local SNotifySpecialEffect = class("SNotifySpecialEffect")
SNotifySpecialEffect.TYPEID = 12615696
function SNotifySpecialEffect:ctor(activity_id)
  self.id = 12615696
  self.activity_id = activity_id or nil
end
function SNotifySpecialEffect:marshal(os)
  os:marshalInt32(self.activity_id)
end
function SNotifySpecialEffect:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
end
function SNotifySpecialEffect:sizepolicy(size)
  return size <= 65535
end
return SNotifySpecialEffect
