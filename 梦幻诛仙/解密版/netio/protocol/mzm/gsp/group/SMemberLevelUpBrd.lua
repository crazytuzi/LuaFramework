local SMemberLevelUpBrd = class("SMemberLevelUpBrd")
SMemberLevelUpBrd.TYPEID = 12605207
function SMemberLevelUpBrd:ctor(groupid, memberid, level, info_version)
  self.id = 12605207
  self.groupid = groupid or nil
  self.memberid = memberid or nil
  self.level = level or nil
  self.info_version = info_version or nil
end
function SMemberLevelUpBrd:marshal(os)
  os:marshalInt64(self.groupid)
  os:marshalInt64(self.memberid)
  os:marshalInt32(self.level)
  os:marshalInt64(self.info_version)
end
function SMemberLevelUpBrd:unmarshal(os)
  self.groupid = os:unmarshalInt64()
  self.memberid = os:unmarshalInt64()
  self.level = os:unmarshalInt32()
  self.info_version = os:unmarshalInt64()
end
function SMemberLevelUpBrd:sizepolicy(size)
  return size <= 65535
end
return SMemberLevelUpBrd
