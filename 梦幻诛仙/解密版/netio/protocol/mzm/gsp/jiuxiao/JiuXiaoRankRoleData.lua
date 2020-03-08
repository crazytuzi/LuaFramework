local OctetsStream = require("netio.OctetsStream")
local JiuXiaoRankRoleData = class("JiuXiaoRankRoleData")
function JiuXiaoRankRoleData:ctor(rank, roleid, occupation, roleName, layer, time)
  self.rank = rank or nil
  self.roleid = roleid or nil
  self.occupation = occupation or nil
  self.roleName = roleName or nil
  self.layer = layer or nil
  self.time = time or nil
end
function JiuXiaoRankRoleData:marshal(os)
  os:marshalInt32(self.rank)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.occupation)
  os:marshalString(self.roleName)
  os:marshalInt32(self.layer)
  os:marshalInt32(self.time)
end
function JiuXiaoRankRoleData:unmarshal(os)
  self.rank = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.occupation = os:unmarshalInt32()
  self.roleName = os:unmarshalString()
  self.layer = os:unmarshalInt32()
  self.time = os:unmarshalInt32()
end
return JiuXiaoRankRoleData
