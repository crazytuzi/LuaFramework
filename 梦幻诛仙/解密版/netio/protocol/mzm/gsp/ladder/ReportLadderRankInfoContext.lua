local OctetsStream = require("netio.OctetsStream")
local ReportLadderRankInfoContext = class("ReportLadderRankInfoContext")
function ReportLadderRankInfoContext:ctor(count)
  self.count = count or nil
end
function ReportLadderRankInfoContext:marshal(os)
  os:marshalInt32(self.count)
end
function ReportLadderRankInfoContext:unmarshal(os)
  self.count = os:unmarshalInt32()
end
return ReportLadderRankInfoContext
