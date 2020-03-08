local CGetGiftInfoReq = class("CGetGiftInfoReq")
CGetGiftInfoReq.TYPEID = 12588840
function CGetGiftInfoReq:ctor(activity_id, gift_bag_cfg_id)
  self.id = 12588840
  self.activity_id = activity_id or nil
  self.gift_bag_cfg_id = gift_bag_cfg_id or nil
end
function CGetGiftInfoReq:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.gift_bag_cfg_id)
end
function CGetGiftInfoReq:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.gift_bag_cfg_id = os:unmarshalInt32()
end
function CGetGiftInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetGiftInfoReq
