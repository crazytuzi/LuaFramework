local OctetsStream = require("netio.OctetsStream")
local LadderRankRoleData = class("LadderRankRoleData")
function LadderRankRoleData:ctor(rank, roleid, occupation, roleName, stage, score)
  self.rank = rank or nil
  self.roleid = roleid or nil
  self.occupation = occupation or nil
  self.roleName = roleName or nil
  self.stage = stage or nil
  self.score = score or nil
end
function LadderRankRoleData:marshal(os)
  os:marshalInt32(self.rank)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.occupation)
  os:marshalString(self.roleName)
  os:marshalInt32(self.stage)
  os:marshalInt32(self.score)
end
function LadderRankRoleData:unmarshal(os)
  self.rank = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.occupation = os:unmarshalInt32()
  self.roleName = os:unmarshalString()
  self.stage = os:unmarshalInt32()
  self.score = os:unmarshalInt32()
end
return LadderRankRoleData
