local OctetsStream = require("netio.OctetsStream")
local RemoveRoleCrossBattleBetRankInfoContext = class("RemoveRoleCrossBattleBetRankInfoContext")
function RemoveRoleCrossBattleBetRankInfoContext:ctor(count)
  self.count = count or nil
end
function RemoveRoleCrossBattleBetRankInfoContext:marshal(os)
  os:marshalUInt8(self.count)
end
function RemoveRoleCrossBattleBetRankInfoContext:unmarshal(os)
  self.count = os:unmarshalUInt8()
end
return RemoveRoleCrossBattleBetRankInfoContext
