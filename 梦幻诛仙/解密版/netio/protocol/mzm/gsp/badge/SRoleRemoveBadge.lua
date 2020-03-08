local SRoleRemoveBadge = class("SRoleRemoveBadge")
SRoleRemoveBadge.TYPEID = 12597507
function SRoleRemoveBadge:ctor(badgeId)
  self.id = 12597507
  self.badgeId = badgeId or nil
end
function SRoleRemoveBadge:marshal(os)
  os:marshalInt32(self.badgeId)
end
function SRoleRemoveBadge:unmarshal(os)
  self.badgeId = os:unmarshalInt32()
end
function SRoleRemoveBadge:sizepolicy(size)
  return size <= 65535
end
return SRoleRemoveBadge
