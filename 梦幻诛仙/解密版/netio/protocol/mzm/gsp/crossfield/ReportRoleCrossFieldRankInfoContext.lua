local OctetsStream = require("netio.OctetsStream")
local ReportRoleCrossFieldRankInfoContext = class("ReportRoleCrossFieldRankInfoContext")
function ReportRoleCrossFieldRankInfoContext:ctor(count)
  self.count = count or nil
end
function ReportRoleCrossFieldRankInfoContext:marshal(os)
  os:marshalUInt8(self.count)
end
function ReportRoleCrossFieldRankInfoContext:unmarshal(os)
  self.count = os:unmarshalUInt8()
end
return ReportRoleCrossFieldRankInfoContext
