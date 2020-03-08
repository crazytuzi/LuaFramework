local SNotifyAutoDelivery = class("SNotifyAutoDelivery")
SNotifyAutoDelivery.TYPEID = 12615693
function SNotifyAutoDelivery:ctor(target_id, target_name, activity_id)
  self.id = 12615693
  self.target_id = target_id or nil
  self.target_name = target_name or nil
  self.activity_id = activity_id or nil
end
function SNotifyAutoDelivery:marshal(os)
  os:marshalInt64(self.target_id)
  os:marshalOctets(self.target_name)
  os:marshalInt32(self.activity_id)
end
function SNotifyAutoDelivery:unmarshal(os)
  self.target_id = os:unmarshalInt64()
  self.target_name = os:unmarshalOctets()
  self.activity_id = os:unmarshalInt32()
end
function SNotifyAutoDelivery:sizepolicy(size)
  return size <= 65535
end
return SNotifyAutoDelivery
