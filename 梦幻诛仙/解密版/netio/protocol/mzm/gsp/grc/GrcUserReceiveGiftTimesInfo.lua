local OctetsStream = require("netio.OctetsStream")
local GrcUserReceiveGiftTimesInfo = class("GrcUserReceiveGiftTimesInfo")
function GrcUserReceiveGiftTimesInfo:ctor(gift_type, today_receive_times)
  self.gift_type = gift_type or nil
  self.today_receive_times = today_receive_times or nil
end
function GrcUserReceiveGiftTimesInfo:marshal(os)
  os:marshalInt32(self.gift_type)
  os:marshalInt32(self.today_receive_times)
end
function GrcUserReceiveGiftTimesInfo:unmarshal(os)
  self.gift_type = os:unmarshalInt32()
  self.today_receive_times = os:unmarshalInt32()
end
return GrcUserReceiveGiftTimesInfo
