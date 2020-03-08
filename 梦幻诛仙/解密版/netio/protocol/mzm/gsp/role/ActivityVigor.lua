local OctetsStream = require("netio.OctetsStream")
local ActivityVigor = class("ActivityVigor")
function ActivityVigor:ctor(count, vigor)
  self.count = count or nil
  self.vigor = vigor or nil
end
function ActivityVigor:marshal(os)
  os:marshalInt32(self.count)
  os:marshalInt32(self.vigor)
end
function ActivityVigor:unmarshal(os)
  self.count = os:unmarshalInt32()
  self.vigor = os:unmarshalInt32()
end
return ActivityVigor
