local OctetsStream = require("netio.OctetsStream")
local QMHWRankRoleData = class("QMHWRankRoleData")
function QMHWRankRoleData:ctor(rank, roleid, occupation, roleName, score)
  self.rank = rank or nil
  self.roleid = roleid or nil
  self.occupation = occupation or nil
  self.roleName = roleName or nil
  self.score = score or nil
end
function QMHWRankRoleData:marshal(os)
  os:marshalInt32(self.rank)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.occupation)
  os:marshalString(self.roleName)
  os:marshalInt32(self.score)
end
function QMHWRankRoleData:unmarshal(os)
  self.rank = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.occupation = os:unmarshalInt32()
  self.roleName = os:unmarshalString()
  self.score = os:unmarshalInt32()
end
return QMHWRankRoleData
