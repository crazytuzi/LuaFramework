local OctetsStream = require("netio.OctetsStream")
local ActivityStatus = class("ActivityStatus")
function ActivityStatus:ctor(round, role_number, is_preparing, stage_end_time)
  self.round = round or nil
  self.role_number = role_number or nil
  self.is_preparing = is_preparing or nil
  self.stage_end_time = stage_end_time or nil
end
function ActivityStatus:marshal(os)
  os:marshalInt32(self.round)
  os:marshalInt32(self.role_number)
  os:marshalInt32(self.is_preparing)
  os:marshalInt32(self.stage_end_time)
end
function ActivityStatus:unmarshal(os)
  self.round = os:unmarshalInt32()
  self.role_number = os:unmarshalInt32()
  self.is_preparing = os:unmarshalInt32()
  self.stage_end_time = os:unmarshalInt32()
end
return ActivityStatus
