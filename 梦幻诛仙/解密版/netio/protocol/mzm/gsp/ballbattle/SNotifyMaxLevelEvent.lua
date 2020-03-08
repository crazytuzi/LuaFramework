local SNotifyMaxLevelEvent = class("SNotifyMaxLevelEvent")
SNotifyMaxLevelEvent.TYPEID = 12629268
function SNotifyMaxLevelEvent:ctor(role_id, level_reset_time)
  self.id = 12629268
  self.role_id = role_id or nil
  self.level_reset_time = level_reset_time or nil
end
function SNotifyMaxLevelEvent:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalInt32(self.level_reset_time)
end
function SNotifyMaxLevelEvent:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.level_reset_time = os:unmarshalInt32()
end
function SNotifyMaxLevelEvent:sizepolicy(size)
  return size <= 65535
end
return SNotifyMaxLevelEvent
