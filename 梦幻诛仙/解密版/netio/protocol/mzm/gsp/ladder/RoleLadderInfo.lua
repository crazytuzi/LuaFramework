local OctetsStream = require("netio.OctetsStream")
local RoleLadderInfo = class("RoleLadderInfo")
function RoleLadderInfo:ctor(roleid, stage, score, winCount, loseCount)
  self.roleid = roleid or nil
  self.stage = stage or nil
  self.score = score or nil
  self.winCount = winCount or nil
  self.loseCount = loseCount or nil
end
function RoleLadderInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.stage)
  os:marshalInt32(self.score)
  os:marshalInt32(self.winCount)
  os:marshalInt32(self.loseCount)
end
function RoleLadderInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.stage = os:unmarshalInt32()
  self.score = os:unmarshalInt32()
  self.winCount = os:unmarshalInt32()
  self.loseCount = os:unmarshalInt32()
end
return RoleLadderInfo
