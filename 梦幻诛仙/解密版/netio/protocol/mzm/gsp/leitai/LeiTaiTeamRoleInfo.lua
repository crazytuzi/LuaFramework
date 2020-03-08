local OctetsStream = require("netio.OctetsStream")
local LeiTaiRoleInfo = require("netio.protocol.mzm.gsp.leitai.LeiTaiRoleInfo")
local LeiTaiTeamRoleInfo = class("LeiTaiTeamRoleInfo")
function LeiTaiTeamRoleInfo:ctor(roleInfo, num)
  self.roleInfo = roleInfo or LeiTaiRoleInfo.new()
  self.num = num or nil
end
function LeiTaiTeamRoleInfo:marshal(os)
  self.roleInfo:marshal(os)
  os:marshalInt32(self.num)
end
function LeiTaiTeamRoleInfo:unmarshal(os)
  self.roleInfo = LeiTaiRoleInfo.new()
  self.roleInfo:unmarshal(os)
  self.num = os:unmarshalInt32()
end
return LeiTaiTeamRoleInfo
