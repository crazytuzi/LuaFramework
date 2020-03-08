local OctetsStream = require("netio.OctetsStream")
local ReportRoleBigBossRemoteRankInfoContext = class("ReportRoleBigBossRemoteRankInfoContext")
function ReportRoleBigBossRemoteRankInfoContext:ctor(count)
  self.count = count or nil
end
function ReportRoleBigBossRemoteRankInfoContext:marshal(os)
  os:marshalUInt8(self.count)
end
function ReportRoleBigBossRemoteRankInfoContext:unmarshal(os)
  self.count = os:unmarshalUInt8()
end
return ReportRoleBigBossRemoteRankInfoContext
