local OctetsStream = require("netio.OctetsStream")
local RecallRoleInfo = class("RecallRoleInfo")
function RecallRoleInfo:ctor(roleid, rolename, level, gender, occupation, zoneid, fight)
  self.roleid = roleid or nil
  self.rolename = rolename or nil
  self.level = level or nil
  self.gender = gender or nil
  self.occupation = occupation or nil
  self.zoneid = zoneid or nil
  self.fight = fight or nil
end
function RecallRoleInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalOctets(self.rolename)
  os:marshalInt32(self.level)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.occupation)
  os:marshalInt32(self.zoneid)
  os:marshalInt32(self.fight)
end
function RecallRoleInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.rolename = os:unmarshalOctets()
  self.level = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.occupation = os:unmarshalInt32()
  self.zoneid = os:unmarshalInt32()
  self.fight = os:unmarshalInt32()
end
return RecallRoleInfo
