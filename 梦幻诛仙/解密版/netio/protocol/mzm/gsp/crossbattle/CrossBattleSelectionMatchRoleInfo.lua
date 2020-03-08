local OctetsStream = require("netio.OctetsStream")
local CrossBattleSelectionMatchRoleInfo = class("CrossBattleSelectionMatchRoleInfo")
function CrossBattleSelectionMatchRoleInfo:ctor(roleId, process, gender, occupation, role_name, avatar_id, role_level)
  self.roleId = roleId or nil
  self.process = process or nil
  self.gender = gender or nil
  self.occupation = occupation or nil
  self.role_name = role_name or nil
  self.avatar_id = avatar_id or nil
  self.role_level = role_level or nil
end
function CrossBattleSelectionMatchRoleInfo:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.process)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.occupation)
  os:marshalOctets(self.role_name)
  os:marshalInt32(self.avatar_id)
  os:marshalInt32(self.role_level)
end
function CrossBattleSelectionMatchRoleInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.process = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.occupation = os:unmarshalInt32()
  self.role_name = os:unmarshalOctets()
  self.avatar_id = os:unmarshalInt32()
  self.role_level = os:unmarshalInt32()
end
return CrossBattleSelectionMatchRoleInfo
