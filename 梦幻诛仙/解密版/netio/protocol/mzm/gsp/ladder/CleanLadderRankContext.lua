local OctetsStream = require("netio.OctetsStream")
local CleanLadderRankContext = class("CleanLadderRankContext")
function CleanLadderRankContext:ctor(count)
  self.count = count or nil
end
function CleanLadderRankContext:marshal(os)
  os:marshalInt32(self.count)
end
function CleanLadderRankContext:unmarshal(os)
  self.count = os:unmarshalInt32()
end
return CleanLadderRankContext
