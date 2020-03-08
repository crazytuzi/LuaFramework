local SReplaceBadgeBro = class("SReplaceBadgeBro")
SReplaceBadgeBro.TYPEID = 12617488
function SReplaceBadgeBro:ctor(badgeId)
  self.id = 12617488
  self.badgeId = badgeId or nil
end
function SReplaceBadgeBro:marshal(os)
  os:marshalInt32(self.badgeId)
end
function SReplaceBadgeBro:unmarshal(os)
  self.badgeId = os:unmarshalInt32()
end
function SReplaceBadgeBro:sizepolicy(size)
  return size <= 65535
end
return SReplaceBadgeBro
