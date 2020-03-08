local CGiftReq = class("CGiftReq")
CGiftReq.TYPEID = 12588842
function CGiftReq:ctor(activity_id, gift_bag_cfg_id, receiver_id)
  self.id = 12588842
  self.activity_id = activity_id or nil
  self.gift_bag_cfg_id = gift_bag_cfg_id or nil
  self.receiver_id = receiver_id or nil
end
function CGiftReq:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.gift_bag_cfg_id)
  os:marshalInt64(self.receiver_id)
end
function CGiftReq:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.gift_bag_cfg_id = os:unmarshalInt32()
  self.receiver_id = os:unmarshalInt64()
end
function CGiftReq:sizepolicy(size)
  return size <= 65535
end
return CGiftReq
