local OctetsStream = require("netio.OctetsStream")
local RemoveLadderRankInfoContext = class("RemoveLadderRankInfoContext")
function RemoveLadderRankInfoContext:ctor(count)
  self.count = count or nil
end
function RemoveLadderRankInfoContext:marshal(os)
  os:marshalInt32(self.count)
end
function RemoveLadderRankInfoContext:unmarshal(os)
  self.count = os:unmarshalInt32()
end
return RemoveLadderRankInfoContext
