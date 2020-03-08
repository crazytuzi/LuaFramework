local CReplaceBadgeReq = class("CReplaceBadgeReq")
CReplaceBadgeReq.TYPEID = 12617496
function CReplaceBadgeReq:ctor(badgeId)
  self.id = 12617496
  self.badgeId = badgeId or nil
end
function CReplaceBadgeReq:marshal(os)
  os:marshalInt32(self.badgeId)
end
function CReplaceBadgeReq:unmarshal(os)
  self.badgeId = os:unmarshalInt32()
end
function CReplaceBadgeReq:sizepolicy(size)
  return size <= 65535
end
return CReplaceBadgeReq
