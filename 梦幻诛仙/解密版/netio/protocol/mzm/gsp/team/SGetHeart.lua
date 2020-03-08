local SGetHeart = class("SGetHeart")
SGetHeart.TYPEID = 12588346
function SGetHeart:ctor(otherRoleId, otherName, otherLv, otherMenpai, otherGender)
  self.id = 12588346
  self.otherRoleId = otherRoleId or nil
  self.otherName = otherName or nil
  self.otherLv = otherLv or nil
  self.otherMenpai = otherMenpai or nil
  self.otherGender = otherGender or nil
end
function SGetHeart:marshal(os)
  os:marshalInt64(self.otherRoleId)
  os:marshalString(self.otherName)
  os:marshalInt32(self.otherLv)
  os:marshalInt32(self.otherMenpai)
  os:marshalInt32(self.otherGender)
end
function SGetHeart:unmarshal(os)
  self.otherRoleId = os:unmarshalInt64()
  self.otherName = os:unmarshalString()
  self.otherLv = os:unmarshalInt32()
  self.otherMenpai = os:unmarshalInt32()
  self.otherGender = os:unmarshalInt32()
end
function SGetHeart:sizepolicy(size)
  return size <= 65535
end
return SGetHeart
