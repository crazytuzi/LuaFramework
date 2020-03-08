local OctetsStream = require("netio.OctetsStream")
local LeiTaiRoleInfo = require("netio.protocol.mzm.gsp.leitai.LeiTaiRoleInfo")
local LeiTaiFightInfo = class("LeiTaiFightInfo")
function LeiTaiFightInfo:ctor(activeRoleInfo, activeTeamNum, passiveRoleInfo, passiveTeamNum)
  self.activeRoleInfo = activeRoleInfo or LeiTaiRoleInfo.new()
  self.activeTeamNum = activeTeamNum or nil
  self.passiveRoleInfo = passiveRoleInfo or LeiTaiRoleInfo.new()
  self.passiveTeamNum = passiveTeamNum or nil
end
function LeiTaiFightInfo:marshal(os)
  self.activeRoleInfo:marshal(os)
  os:marshalInt32(self.activeTeamNum)
  self.passiveRoleInfo:marshal(os)
  os:marshalInt32(self.passiveTeamNum)
end
function LeiTaiFightInfo:unmarshal(os)
  self.activeRoleInfo = LeiTaiRoleInfo.new()
  self.activeRoleInfo:unmarshal(os)
  self.activeTeamNum = os:unmarshalInt32()
  self.passiveRoleInfo = LeiTaiRoleInfo.new()
  self.passiveRoleInfo:unmarshal(os)
  self.passiveTeamNum = os:unmarshalInt32()
end
return LeiTaiFightInfo
