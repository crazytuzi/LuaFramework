local OctetsStream = require("netio.OctetsStream")
local RebateInfo = class("RebateInfo")
function RebateInfo:ctor(total_num, receive_time, receive_num)
  self.total_num = total_num or nil
  self.receive_time = receive_time or nil
  self.receive_num = receive_num or nil
end
function RebateInfo:marshal(os)
  os:marshalInt32(self.total_num)
  os:marshalInt32(self.receive_time)
  os:marshalInt32(self.receive_num)
end
function RebateInfo:unmarshal(os)
  self.total_num = os:unmarshalInt32()
  self.receive_time = os:unmarshalInt32()
  self.receive_num = os:unmarshalInt32()
end
return RebateInfo
