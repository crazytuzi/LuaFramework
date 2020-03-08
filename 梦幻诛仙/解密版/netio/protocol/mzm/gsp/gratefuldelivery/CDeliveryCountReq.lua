local CDeliveryCountReq = class("CDeliveryCountReq")
CDeliveryCountReq.TYPEID = 12615681
function CDeliveryCountReq:ctor(activity_id)
  self.id = 12615681
  self.activity_id = activity_id or nil
end
function CDeliveryCountReq:marshal(os)
  os:marshalInt32(self.activity_id)
end
function CDeliveryCountReq:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
end
function CDeliveryCountReq:sizepolicy(size)
  return size <= 65535
end
return CDeliveryCountReq
