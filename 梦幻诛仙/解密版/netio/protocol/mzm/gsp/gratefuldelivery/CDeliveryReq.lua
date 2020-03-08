local CDeliveryReq = class("CDeliveryReq")
CDeliveryReq.TYPEID = 12615686
function CDeliveryReq:ctor(target_id, activity_id)
  self.id = 12615686
  self.target_id = target_id or nil
  self.activity_id = activity_id or nil
end
function CDeliveryReq:marshal(os)
  os:marshalInt64(self.target_id)
  os:marshalInt32(self.activity_id)
end
function CDeliveryReq:unmarshal(os)
  self.target_id = os:unmarshalInt64()
  self.activity_id = os:unmarshalInt32()
end
function CDeliveryReq:sizepolicy(size)
  return size <= 65535
end
return CDeliveryReq
