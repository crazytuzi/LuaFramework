local OctetsStream = require("netio.OctetsStream")
local ActiveData = class("ActiveData")
function ActiveData:ctor(activityid, activeCount)
  self.activityid = activityid or nil
  self.activeCount = activeCount or nil
end
function ActiveData:marshal(os)
  os:marshalInt32(self.activityid)
  os:marshalInt32(self.activeCount)
end
function ActiveData:unmarshal(os)
  self.activityid = os:unmarshalInt32()
  self.activeCount = os:unmarshalInt32()
end
return ActiveData
