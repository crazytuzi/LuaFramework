local BackGameActivitySignInfo = require("netio.protocol.mzm.gsp.backgameactivity.BackGameActivitySignInfo")
local BackGameActivityExpAwardInfo = require("netio.protocol.mzm.gsp.backgameactivity.BackGameActivityExpAwardInfo")
local BackGameActivityTaskInfo = require("netio.protocol.mzm.gsp.backgameactivity.BackGameActivityTaskInfo")
local BackGameActivityAwardInfo = require("netio.protocol.mzm.gsp.backgameactivity.BackGameActivityAwardInfo")
local BackGameActivityGiftInfo = require("netio.protocol.mzm.gsp.backgameactivity.BackGameActivityGiftInfo")
local RechargeInfo = require("netio.protocol.mzm.gsp.backgameactivity.RechargeInfo")
local SSynBackGameActivityInfo = class("SSynBackGameActivityInfo")
SSynBackGameActivityInfo.TYPEID = 12620558
function SSynBackGameActivityInfo:ctor(activity_id, current_time, join_time, join_level, sign_info, exp_award_info, task_info, award_info, gift_info, rechargeInfo)
  self.id = 12620558
  self.activity_id = activity_id or nil
  self.current_time = current_time or nil
  self.join_time = join_time or nil
  self.join_level = join_level or nil
  self.sign_info = sign_info or BackGameActivitySignInfo.new()
  self.exp_award_info = exp_award_info or BackGameActivityExpAwardInfo.new()
  self.task_info = task_info or BackGameActivityTaskInfo.new()
  self.award_info = award_info or BackGameActivityAwardInfo.new()
  self.gift_info = gift_info or BackGameActivityGiftInfo.new()
  self.rechargeInfo = rechargeInfo or RechargeInfo.new()
end
function SSynBackGameActivityInfo:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt64(self.current_time)
  os:marshalInt64(self.join_time)
  os:marshalInt32(self.join_level)
  self.sign_info:marshal(os)
  self.exp_award_info:marshal(os)
  self.task_info:marshal(os)
  self.award_info:marshal(os)
  self.gift_info:marshal(os)
  self.rechargeInfo:marshal(os)
end
function SSynBackGameActivityInfo:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.current_time = os:unmarshalInt64()
  self.join_time = os:unmarshalInt64()
  self.join_level = os:unmarshalInt32()
  self.sign_info = BackGameActivitySignInfo.new()
  self.sign_info:unmarshal(os)
  self.exp_award_info = BackGameActivityExpAwardInfo.new()
  self.exp_award_info:unmarshal(os)
  self.task_info = BackGameActivityTaskInfo.new()
  self.task_info:unmarshal(os)
  self.award_info = BackGameActivityAwardInfo.new()
  self.award_info:unmarshal(os)
  self.gift_info = BackGameActivityGiftInfo.new()
  self.gift_info:unmarshal(os)
  self.rechargeInfo = RechargeInfo.new()
  self.rechargeInfo:unmarshal(os)
end
function SSynBackGameActivityInfo:sizepolicy(size)
  return size <= 65535
end
return SSynBackGameActivityInfo
