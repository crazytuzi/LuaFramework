local OctetsStream = require("netio.OctetsStream")
local MassExpInfo = class("MassExpInfo")
MassExpInfo.STATUS_INIT = 0
MassExpInfo.STATUS_ACCEPTED = 1
MassExpInfo.STATUS_END = 2
function MassExpInfo:ctor(status, cur_index, start_timestamp, end_time)
  self.status = status or nil
  self.cur_index = cur_index or nil
  self.start_timestamp = start_timestamp or nil
  self.end_time = end_time or nil
end
function MassExpInfo:marshal(os)
  os:marshalInt32(self.status)
  os:marshalInt32(self.cur_index)
  os:marshalInt32(self.start_timestamp)
  os:marshalInt32(self.end_time)
end
function MassExpInfo:unmarshal(os)
  self.status = os:unmarshalInt32()
  self.cur_index = os:unmarshalInt32()
  self.start_timestamp = os:unmarshalInt32()
  self.end_time = os:unmarshalInt32()
end
return MassExpInfo
