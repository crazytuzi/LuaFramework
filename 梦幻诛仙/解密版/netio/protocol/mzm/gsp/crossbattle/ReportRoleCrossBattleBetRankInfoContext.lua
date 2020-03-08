local OctetsStream = require("netio.OctetsStream")
local ReportRoleCrossBattleBetRankInfoContext = class("ReportRoleCrossBattleBetRankInfoContext")
function ReportRoleCrossBattleBetRankInfoContext:ctor(count)
  self.count = count or nil
end
function ReportRoleCrossBattleBetRankInfoContext:marshal(os)
  os:marshalUInt8(self.count)
end
function ReportRoleCrossBattleBetRankInfoContext:unmarshal(os)
  self.count = os:unmarshalUInt8()
end
return ReportRoleCrossBattleBetRankInfoContext
