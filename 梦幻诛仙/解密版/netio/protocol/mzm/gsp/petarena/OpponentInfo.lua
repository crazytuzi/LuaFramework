local OctetsStream = require("netio.OctetsStream")
local OpponentInfo = class("OpponentInfo")
OpponentInfo.MAIL = 1
OpponentInfo.FEMAIL = 2
function OpponentInfo:ctor(rank, roleid, avatar, avatar_frame, name, level, occupation, gender, score)
  self.rank = rank or nil
  self.roleid = roleid or nil
  self.avatar = avatar or nil
  self.avatar_frame = avatar_frame or nil
  self.name = name or nil
  self.level = level or nil
  self.occupation = occupation or nil
  self.gender = gender or nil
  self.score = score or nil
end
function OpponentInfo:marshal(os)
  os:marshalInt32(self.rank)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.avatar)
  os:marshalInt32(self.avatar_frame)
  os:marshalOctets(self.name)
  os:marshalInt32(self.level)
  os:marshalInt32(self.occupation)
  os:marshalUInt8(self.gender)
  os:marshalInt32(self.score)
end
function OpponentInfo:unmarshal(os)
  self.rank = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.avatar = os:unmarshalInt32()
  self.avatar_frame = os:unmarshalInt32()
  self.name = os:unmarshalOctets()
  self.level = os:unmarshalInt32()
  self.occupation = os:unmarshalInt32()
  self.gender = os:unmarshalUInt8()
  self.score = os:unmarshalInt32()
end
return OpponentInfo
