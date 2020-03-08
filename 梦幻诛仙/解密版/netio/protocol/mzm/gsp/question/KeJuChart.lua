local OctetsStream = require("netio.OctetsStream")
local KeJuChart = class("KeJuChart")
function KeJuChart:ctor(roleId, roleName, rankLevel, useTime)
  self.roleId = roleId or nil
  self.roleName = roleName or nil
  self.rankLevel = rankLevel or nil
  self.useTime = useTime or nil
end
function KeJuChart:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.roleName)
  os:marshalInt32(self.rankLevel)
  os:marshalInt32(self.useTime)
end
function KeJuChart:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.rankLevel = os:unmarshalInt32()
  self.useTime = os:unmarshalInt32()
end
return KeJuChart
