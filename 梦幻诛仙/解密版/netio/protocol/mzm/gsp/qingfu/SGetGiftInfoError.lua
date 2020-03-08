local SGetGiftInfoError = class("SGetGiftInfoError")
SGetGiftInfoError.TYPEID = 12588843
SGetGiftInfoError.ACTIVITY_CLOSE = 1
function SGetGiftInfoError:ctor(code, activity_id, gift_bag_cfg_id)
  self.id = 12588843
  self.code = code or nil
  self.activity_id = activity_id or nil
  self.gift_bag_cfg_id = gift_bag_cfg_id or nil
end
function SGetGiftInfoError:marshal(os)
  os:marshalInt32(self.code)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.gift_bag_cfg_id)
end
function SGetGiftInfoError:unmarshal(os)
  self.code = os:unmarshalInt32()
  self.activity_id = os:unmarshalInt32()
  self.gift_bag_cfg_id = os:unmarshalInt32()
end
function SGetGiftInfoError:sizepolicy(size)
  return size <= 65535
end
return SGetGiftInfoError
