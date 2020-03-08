local OctetsStream = require("netio.OctetsStream")
local JigsawInfo = class("JigsawInfo")
function JigsawInfo:ctor(roleid, name, sex, level, occupation, ispass, avatarId, avatarFrameId)
  self.roleid = roleid or nil
  self.name = name or nil
  self.sex = sex or nil
  self.level = level or nil
  self.occupation = occupation or nil
  self.ispass = ispass or nil
  self.avatarId = avatarId or nil
  self.avatarFrameId = avatarFrameId or nil
end
function JigsawInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.name)
  os:marshalInt32(self.sex)
  os:marshalInt32(self.level)
  os:marshalInt32(self.occupation)
  os:marshalInt32(self.ispass)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatarFrameId)
end
function JigsawInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.sex = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.occupation = os:unmarshalInt32()
  self.ispass = os:unmarshalInt32()
  self.avatarId = os:unmarshalInt32()
  self.avatarFrameId = os:unmarshalInt32()
end
return JigsawInfo
