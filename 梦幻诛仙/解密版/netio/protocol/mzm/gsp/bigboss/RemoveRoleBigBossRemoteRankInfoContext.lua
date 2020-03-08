local OctetsStream = require("netio.OctetsStream")
local RemoveRoleBigBossRemoteRankInfoContext = class("RemoveRoleBigBossRemoteRankInfoContext")
function RemoveRoleBigBossRemoteRankInfoContext:ctor(count)
  self.count = count or nil
end
function RemoveRoleBigBossRemoteRankInfoContext:marshal(os)
  os:marshalUInt8(self.count)
end
function RemoveRoleBigBossRemoteRankInfoContext:unmarshal(os)
  self.count = os:unmarshalUInt8()
end
return RemoveRoleBigBossRemoteRankInfoContext
