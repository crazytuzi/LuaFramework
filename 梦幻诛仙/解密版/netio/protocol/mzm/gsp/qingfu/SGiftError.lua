local ReceiverGiftInfo = require("netio.protocol.mzm.gsp.qingfu.ReceiverGiftInfo")
local SGiftError = class("SGiftError")
SGiftError.TYPEID = 12588839
SGiftError.RECEIVER_REACH_MAX = 1
SGiftError.SENDER_REACH_MAX = 2
SGiftError.P2P_REACH_MAX = 3
SGiftError.INTIMACY_LOW = 4
SGiftError.SEND_MAIL_FAIL = 5
SGiftError.MONEY_NOT_ENOUGH = 6
function SGiftError:ctor(code, activity_id, gift_bag_cfg_id, send_available, receiver_id, receiver_gift_info)
  self.id = 12588839
  self.code = code or nil
  self.activity_id = activity_id or nil
  self.gift_bag_cfg_id = gift_bag_cfg_id or nil
  self.send_available = send_available or nil
  self.receiver_id = receiver_id or nil
  self.receiver_gift_info = receiver_gift_info or ReceiverGiftInfo.new()
end
function SGiftError:marshal(os)
  os:marshalInt32(self.code)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.gift_bag_cfg_id)
  os:marshalInt32(self.send_available)
  os:marshalInt64(self.receiver_id)
  self.receiver_gift_info:marshal(os)
end
function SGiftError:unmarshal(os)
  self.code = os:unmarshalInt32()
  self.activity_id = os:unmarshalInt32()
  self.gift_bag_cfg_id = os:unmarshalInt32()
  self.send_available = os:unmarshalInt32()
  self.receiver_id = os:unmarshalInt64()
  self.receiver_gift_info = ReceiverGiftInfo.new()
  self.receiver_gift_info:unmarshal(os)
end
function SGiftError:sizepolicy(size)
  return size <= 65535
end
return SGiftError
