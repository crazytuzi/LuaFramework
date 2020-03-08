local OctetsStream = require("netio.OctetsStream")
local RoleFightValueRankData = class("RoleFightValueRankData")
function RoleFightValueRankData:ctor(no, roleId, name, occupationId, fightValue, step)
  self.no = no or nil
  self.roleId = roleId or nil
  self.name = name or nil
  self.occupationId = occupationId or nil
  self.fightValue = fightValue or nil
  self.step = step or nil
end
function RoleFightValueRankData:marshal(os)
  os:marshalInt32(self.no)
  os:marshalInt64(self.roleId)
  os:marshalString(self.name)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.fightValue)
  os:marshalInt32(self.step)
end
function RoleFightValueRankData:unmarshal(os)
  self.no = os:unmarshalInt32()
  self.roleId = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.occupationId = os:unmarshalInt32()
  self.fightValue = os:unmarshalInt32()
  self.step = os:unmarshalInt32()
end
return RoleFightValueRankData
