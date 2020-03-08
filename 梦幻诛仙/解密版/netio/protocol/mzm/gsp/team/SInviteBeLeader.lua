local SInviteBeLeader = class("SInviteBeLeader")
SInviteBeLeader.TYPEID = 12588337
function SInviteBeLeader:ctor()
  self.id = 12588337
end
function SInviteBeLeader:marshal(os)
end
function SInviteBeLeader:unmarshal(os)
end
function SInviteBeLeader:sizepolicy(size)
  return size <= 65535
end
return SInviteBeLeader
