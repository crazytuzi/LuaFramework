local OctetsStream = require("netio.OctetsStream")
local RoleLevelRankData = class("RoleLevelRankData")
function RoleLevelRankData:ctor(no, roleId, name, occupationId, level, step)
  self.no = no or nil
  self.roleId = roleId or nil
  self.name = name or nil
  self.occupationId = occupationId or nil
  self.level = level or nil
  self.step = step or nil
end
function RoleLevelRankData:marshal(os)
  os:marshalInt32(self.no)
  os:marshalInt64(self.roleId)
  os:marshalString(self.name)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.level)
  os:marshalInt32(self.step)
end
function RoleLevelRankData:unmarshal(os)
  self.no = os:unmarshalInt32()
  self.roleId = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.occupationId = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.step = os:unmarshalInt32()
end
return RoleLevelRankData
