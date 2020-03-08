local SMemberStatusChangedBrd = class("SMemberStatusChangedBrd")
SMemberStatusChangedBrd.TYPEID = 12588311
function SMemberStatusChangedBrd:ctor(member, status)
  self.id = 12588311
  self.member = member or nil
  self.status = status or nil
end
function SMemberStatusChangedBrd:marshal(os)
  os:marshalInt64(self.member)
  os:marshalInt32(self.status)
end
function SMemberStatusChangedBrd:unmarshal(os)
  self.member = os:unmarshalInt64()
  self.status = os:unmarshalInt32()
end
function SMemberStatusChangedBrd:sizepolicy(size)
  return size <= 65535
end
return SMemberStatusChangedBrd
