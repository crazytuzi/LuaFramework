local SCancelInviteBeLeader = class("SCancelInviteBeLeader")
SCancelInviteBeLeader.TYPEID = 12588339
function SCancelInviteBeLeader:ctor()
  self.id = 12588339
end
function SCancelInviteBeLeader:marshal(os)
end
function SCancelInviteBeLeader:unmarshal(os)
end
function SCancelInviteBeLeader:sizepolicy(size)
  return size <= 65535
end
return SCancelInviteBeLeader
