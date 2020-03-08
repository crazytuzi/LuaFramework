local OctetsStream = require("netio.OctetsStream")
local CreateRoleArg = class("CreateRoleArg")
function CreateRoleArg:ctor(name, occupation, gender, level, invite_code)
  self.name = name or nil
  self.occupation = occupation or nil
  self.gender = gender or nil
  self.level = level or nil
  self.invite_code = invite_code or nil
end
function CreateRoleArg:marshal(os)
  os:marshalString(self.name)
  os:marshalInt32(self.occupation)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.level)
  os:marshalOctets(self.invite_code)
end
function CreateRoleArg:unmarshal(os)
  self.name = os:unmarshalString()
  self.occupation = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.invite_code = os:unmarshalOctets()
end
return CreateRoleArg
