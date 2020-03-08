local OctetsStream = require("netio.OctetsStream")
local BadgeInfo = class("BadgeInfo")
function BadgeInfo:ctor(badgeId, timeLimit)
  self.badgeId = badgeId or nil
  self.timeLimit = timeLimit or nil
end
function BadgeInfo:marshal(os)
  os:marshalInt32(self.badgeId)
  os:marshalInt32(self.timeLimit)
end
function BadgeInfo:unmarshal(os)
  self.badgeId = os:unmarshalInt32()
  self.timeLimit = os:unmarshalInt32()
end
return BadgeInfo
