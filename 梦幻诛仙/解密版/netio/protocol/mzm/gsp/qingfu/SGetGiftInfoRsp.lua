local SGetGiftInfoRsp = class("SGetGiftInfoRsp")
SGetGiftInfoRsp.TYPEID = 12588841
function SGetGiftInfoRsp:ctor(activity_id, gift_bag_cfg_id, send_available, receiver_gift_info_map)
  self.id = 12588841
  self.activity_id = activity_id or nil
  self.gift_bag_cfg_id = gift_bag_cfg_id or nil
  self.send_available = send_available or nil
  self.receiver_gift_info_map = receiver_gift_info_map or {}
end
function SGetGiftInfoRsp:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.gift_bag_cfg_id)
  os:marshalInt32(self.send_available)
  local _size_ = 0
  for _, _ in pairs(self.receiver_gift_info_map) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.receiver_gift_info_map) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function SGetGiftInfoRsp:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.gift_bag_cfg_id = os:unmarshalInt32()
  self.send_available = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.qingfu.ReceiverGiftInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.receiver_gift_info_map[k] = v
  end
end
function SGetGiftInfoRsp:sizepolicy(size)
  return size <= 65535
end
return SGetGiftInfoRsp
