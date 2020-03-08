local OctetsStream = require("netio.OctetsStream")
local ActivityCompensate = class("ActivityCompensate")
function ActivityCompensate:ctor(activityid, times, free_exp, gold_exp, yuanbao_exp)
  self.activityid = activityid or nil
  self.times = times or nil
  self.free_exp = free_exp or nil
  self.gold_exp = gold_exp or nil
  self.yuanbao_exp = yuanbao_exp or nil
end
function ActivityCompensate:marshal(os)
  os:marshalInt32(self.activityid)
  os:marshalInt32(self.times)
  os:marshalInt32(self.free_exp)
  os:marshalInt32(self.gold_exp)
  os:marshalInt32(self.yuanbao_exp)
end
function ActivityCompensate:unmarshal(os)
  self.activityid = os:unmarshalInt32()
  self.times = os:unmarshalInt32()
  self.free_exp = os:unmarshalInt32()
  self.gold_exp = os:unmarshalInt32()
  self.yuanbao_exp = os:unmarshalInt32()
end
return ActivityCompensate
