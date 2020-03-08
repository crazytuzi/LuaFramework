local SNotifyCircleReduceEvent = class("SNotifyCircleReduceEvent")
SNotifyCircleReduceEvent.TYPEID = 12629256
function SNotifyCircleReduceEvent:ctor(circle_number)
  self.id = 12629256
  self.circle_number = circle_number or nil
end
function SNotifyCircleReduceEvent:marshal(os)
  os:marshalInt32(self.circle_number)
end
function SNotifyCircleReduceEvent:unmarshal(os)
  self.circle_number = os:unmarshalInt32()
end
function SNotifyCircleReduceEvent:sizepolicy(size)
  return size <= 65535
end
return SNotifyCircleReduceEvent
