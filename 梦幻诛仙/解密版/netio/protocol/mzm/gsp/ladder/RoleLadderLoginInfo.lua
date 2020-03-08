local OctetsStream = require("netio.OctetsStream")
local RoleLadderInfo = require("netio.protocol.mzm.gsp.ladder.RoleLadderInfo")
local RoleLadderLoginInfo = class("RoleLadderLoginInfo")
RoleLadderLoginInfo.NOMAL_STAGE = 0
RoleLadderLoginInfo.READY_STAGE = 1
RoleLadderLoginInfo.MATCH_STAGE = 2
function RoleLadderLoginInfo:ctor(roleLadderInfo, matchStage)
  self.roleLadderInfo = roleLadderInfo or RoleLadderInfo.new()
  self.matchStage = matchStage or nil
end
function RoleLadderLoginInfo:marshal(os)
  self.roleLadderInfo:marshal(os)
  os:marshalInt32(self.matchStage)
end
function RoleLadderLoginInfo:unmarshal(os)
  self.roleLadderInfo = RoleLadderInfo.new()
  self.roleLadderInfo:unmarshal(os)
  self.matchStage = os:unmarshalInt32()
end
return RoleLadderLoginInfo
