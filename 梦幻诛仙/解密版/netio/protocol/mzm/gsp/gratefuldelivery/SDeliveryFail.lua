local SDeliveryFail = class("SDeliveryFail")
SDeliveryFail.TYPEID = 12615694
SDeliveryFail.NO_ITEM = 1
SDeliveryFail.ALREADY_DELIVERED = 2
SDeliveryFail.NOT_ONLINE = 3
function SDeliveryFail:ctor(retcode, target_id, activity_id)
  self.id = 12615694
  self.retcode = retcode or nil
  self.target_id = target_id or nil
  self.activity_id = activity_id or nil
end
function SDeliveryFail:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt64(self.target_id)
  os:marshalInt32(self.activity_id)
end
function SDeliveryFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.target_id = os:unmarshalInt64()
  self.activity_id = os:unmarshalInt32()
end
function SDeliveryFail:sizepolicy(size)
  return size <= 65535
end
return SDeliveryFail
