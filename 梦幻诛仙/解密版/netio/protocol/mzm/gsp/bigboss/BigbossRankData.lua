local OctetsStream = require("netio.OctetsStream")
local BigbossRankData = class("BigbossRankData")
function BigbossRankData:ctor(rank, roleId, name, occupationId, damagepoint, step)
  self.rank = rank or nil
  self.roleId = roleId or nil
  self.name = name or nil
  self.occupationId = occupationId or nil
  self.damagepoint = damagepoint or nil
  self.step = step or nil
end
function BigbossRankData:marshal(os)
  os:marshalInt32(self.rank)
  os:marshalInt64(self.roleId)
  os:marshalString(self.name)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.damagepoint)
  os:marshalInt32(self.step)
end
function BigbossRankData:unmarshal(os)
  self.rank = os:unmarshalInt32()
  self.roleId = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.occupationId = os:unmarshalInt32()
  self.damagepoint = os:unmarshalInt32()
  self.step = os:unmarshalInt32()
end
return BigbossRankData
