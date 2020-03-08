local SDeliveryCountRsp = class("SDeliveryCountRsp")
SDeliveryCountRsp.TYPEID = 12615691
function SDeliveryCountRsp:ctor(delivery_count, activity_id)
  self.id = 12615691
  self.delivery_count = delivery_count or nil
  self.activity_id = activity_id or nil
end
function SDeliveryCountRsp:marshal(os)
  os:marshalInt32(self.delivery_count)
  os:marshalInt32(self.activity_id)
end
function SDeliveryCountRsp:unmarshal(os)
  self.delivery_count = os:unmarshalInt32()
  self.activity_id = os:unmarshalInt32()
end
function SDeliveryCountRsp:sizepolicy(size)
  return size <= 65535
end
return SDeliveryCountRsp
