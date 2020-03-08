local OctetsStream = require("netio.OctetsStream")
local LeiTaiRoleInfo = class("LeiTaiRoleInfo")
function LeiTaiRoleInfo:ctor(roleid, name, level, menPai, gender)
  self.roleid = roleid or nil
  self.name = name or nil
  self.level = level or nil
  self.menPai = menPai or nil
  self.gender = gender or nil
end
function LeiTaiRoleInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.name)
  os:marshalInt32(self.level)
  os:marshalInt32(self.menPai)
  os:marshalInt32(self.gender)
end
function LeiTaiRoleInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.level = os:unmarshalInt32()
  self.menPai = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
end
return LeiTaiRoleInfo
