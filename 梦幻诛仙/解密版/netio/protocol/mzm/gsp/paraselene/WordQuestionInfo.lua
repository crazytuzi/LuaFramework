local OctetsStream = require("netio.OctetsStream")
local WordQuestionInfo = class("WordQuestionInfo")
function WordQuestionInfo:ctor(roleid, name, sex, level, occupation, rightnum, totalnum, avatarId, avatarFrameId)
  self.roleid = roleid or nil
  self.name = name or nil
  self.sex = sex or nil
  self.level = level or nil
  self.occupation = occupation or nil
  self.rightnum = rightnum or nil
  self.totalnum = totalnum or nil
  self.avatarId = avatarId or nil
  self.avatarFrameId = avatarFrameId or nil
end
function WordQuestionInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.name)
  os:marshalInt32(self.sex)
  os:marshalInt32(self.level)
  os:marshalInt32(self.occupation)
  os:marshalInt32(self.rightnum)
  os:marshalInt32(self.totalnum)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatarFrameId)
end
function WordQuestionInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.sex = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.occupation = os:unmarshalInt32()
  self.rightnum = os:unmarshalInt32()
  self.totalnum = os:unmarshalInt32()
  self.avatarId = os:unmarshalInt32()
  self.avatarFrameId = os:unmarshalInt32()
end
return WordQuestionInfo
