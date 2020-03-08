local SNotifyBuffEvent = class("SNotifyBuffEvent")
SNotifyBuffEvent.TYPEID = 12629249
function SNotifyBuffEvent:ctor(role_id, buff_type, position_x, position_y)
  self.id = 12629249
  self.role_id = role_id or nil
  self.buff_type = buff_type or nil
  self.position_x = position_x or nil
  self.position_y = position_y or nil
end
function SNotifyBuffEvent:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalInt32(self.buff_type)
  os:marshalInt32(self.position_x)
  os:marshalInt32(self.position_y)
end
function SNotifyBuffEvent:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.buff_type = os:unmarshalInt32()
  self.position_x = os:unmarshalInt32()
  self.position_y = os:unmarshalInt32()
end
function SNotifyBuffEvent:sizepolicy(size)
  return size <= 65535
end
return SNotifyBuffEvent
