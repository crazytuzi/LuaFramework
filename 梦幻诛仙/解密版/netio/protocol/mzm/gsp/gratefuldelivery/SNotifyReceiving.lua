local SNotifyReceiving = class("SNotifyReceiving")
SNotifyReceiving.TYPEID = 12615685
function SNotifyReceiving:ctor(source_id, source_name, time, activity_id)
  self.id = 12615685
  self.source_id = source_id or nil
  self.source_name = source_name or nil
  self.time = time or nil
  self.activity_id = activity_id or nil
end
function SNotifyReceiving:marshal(os)
  os:marshalInt64(self.source_id)
  os:marshalOctets(self.source_name)
  os:marshalInt32(self.time)
  os:marshalInt32(self.activity_id)
end
function SNotifyReceiving:unmarshal(os)
  self.source_id = os:unmarshalInt64()
  self.source_name = os:unmarshalOctets()
  self.time = os:unmarshalInt32()
  self.activity_id = os:unmarshalInt32()
end
function SNotifyReceiving:sizepolicy(size)
  return size <= 65535
end
return SNotifyReceiving
