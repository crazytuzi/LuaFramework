local OctetsStream = require("netio.OctetsStream")
local TeamStat = class("TeamStat")
function TeamStat:ctor(location, speed)
  self.location = location or nil
  self.speed = speed or nil
end
function TeamStat:marshal(os)
  os:marshalFloat(self.location)
  os:marshalFloat(self.speed)
end
function TeamStat:unmarshal(os)
  self.location = os:unmarshalFloat()
  self.speed = os:unmarshalFloat()
end
return TeamStat
