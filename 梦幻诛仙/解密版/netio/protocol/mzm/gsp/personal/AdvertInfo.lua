local OctetsStream = require("netio.OctetsStream")
local AdvertInfo = class("AdvertInfo")
function AdvertInfo:ctor(roleId, advertId, advertType, headImage, headImageUrl, realGender, name, gender, occupationId, level, content, avatar_frameid)
  self.roleId = roleId or nil
  self.advertId = advertId or nil
  self.advertType = advertType or nil
  self.headImage = headImage or nil
  self.headImageUrl = headImageUrl or nil
  self.realGender = realGender or nil
  self.name = name or nil
  self.gender = gender or nil
  self.occupationId = occupationId or nil
  self.level = level or nil
  self.content = content or nil
  self.avatar_frameid = avatar_frameid or nil
end
function AdvertInfo:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt64(self.advertId)
  os:marshalInt32(self.advertType)
  os:marshalInt32(self.headImage)
  os:marshalOctets(self.headImageUrl)
  os:marshalInt32(self.realGender)
  os:marshalOctets(self.name)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.level)
  os:marshalOctets(self.content)
  os:marshalInt32(self.avatar_frameid)
end
function AdvertInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.advertId = os:unmarshalInt64()
  self.advertType = os:unmarshalInt32()
  self.headImage = os:unmarshalInt32()
  self.headImageUrl = os:unmarshalOctets()
  self.realGender = os:unmarshalInt32()
  self.name = os:unmarshalOctets()
  self.gender = os:unmarshalInt32()
  self.occupationId = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
  self.avatar_frameid = os:unmarshalInt32()
end
return AdvertInfo
