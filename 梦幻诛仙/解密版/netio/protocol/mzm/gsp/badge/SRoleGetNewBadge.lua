local SRoleGetNewBadge = class("SRoleGetNewBadge")
SRoleGetNewBadge.TYPEID = 12597506
function SRoleGetNewBadge:ctor(badgeId, timeLimit)
  self.id = 12597506
  self.badgeId = badgeId or nil
  self.timeLimit = timeLimit or nil
end
function SRoleGetNewBadge:marshal(os)
  os:marshalInt32(self.badgeId)
  os:marshalInt32(self.timeLimit)
end
function SRoleGetNewBadge:unmarshal(os)
  self.badgeId = os:unmarshalInt32()
  self.timeLimit = os:unmarshalInt32()
end
function SRoleGetNewBadge:sizepolicy(size)
  return size <= 65535
end
return SRoleGetNewBadge
