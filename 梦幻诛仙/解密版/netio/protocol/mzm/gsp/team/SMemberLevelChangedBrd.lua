local SMemberLevelChangedBrd = class("SMemberLevelChangedBrd")
SMemberLevelChangedBrd.TYPEID = 12588308
function SMemberLevelChangedBrd:ctor(member, level)
  self.id = 12588308
  self.member = member or nil
  self.level = level or nil
end
function SMemberLevelChangedBrd:marshal(os)
  os:marshalInt64(self.member)
  os:marshalInt32(self.level)
end
function SMemberLevelChangedBrd:unmarshal(os)
  self.member = os:unmarshalInt64()
  self.level = os:unmarshalInt32()
end
function SMemberLevelChangedBrd:sizepolicy(size)
  return size <= 65535
end
return SMemberLevelChangedBrd
