local ReceiverGiftInfo = require("netio.protocol.mzm.gsp.qingfu.ReceiverGiftInfo")
local SGiftRsp = class("SGiftRsp")
SGiftRsp.TYPEID = 12588838
function SGiftRsp:ctor(activity_id, gift_bag_cfg_id, send_available, receiver_id, receiver_gift_info)
  self.id = 12588838
  self.activity_id = activity_id or nil
  self.gift_bag_cfg_id = gift_bag_cfg_id or nil
  self.send_available = send_available or nil
  self.receiver_id = receiver_id or nil
  self.receiver_gift_info = receiver_gift_info or ReceiverGiftInfo.new()
end
function SGiftRsp:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.gift_bag_cfg_id)
  os:marshalInt32(self.send_available)
  os:marshalInt64(self.receiver_id)
  self.receiver_gift_info:marshal(os)
end
function SGiftRsp:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.gift_bag_cfg_id = os:unmarshalInt32()
  self.send_available = os:unmarshalInt32()
  self.receiver_id = os:unmarshalInt64()
  self.receiver_gift_info = ReceiverGiftInfo.new()
  self.receiver_gift_info:unmarshal(os)
end
function SGiftRsp:sizepolicy(size)
  return size <= 65535
end
return SGiftRsp
