local OctetsStream = require("netio.OctetsStream")
local RoleJingjiRankData = class("RoleJingjiRankData")
function RoleJingjiRankData:ctor(no, roleId, name, phase, winpoint)
  self.no = no or nil
  self.roleId = roleId or nil
  self.name = name or nil
  self.phase = phase or nil
  self.winpoint = winpoint or nil
end
function RoleJingjiRankData:marshal(os)
  os:marshalInt32(self.no)
  os:marshalInt64(self.roleId)
  os:marshalString(self.name)
  os:marshalInt32(self.phase)
  os:marshalInt32(self.winpoint)
end
function RoleJingjiRankData:unmarshal(os)
  self.no = os:unmarshalInt32()
  self.roleId = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.phase = os:unmarshalInt32()
  self.winpoint = os:unmarshalInt32()
end
return RoleJingjiRankData
