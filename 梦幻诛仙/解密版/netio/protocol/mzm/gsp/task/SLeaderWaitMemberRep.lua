local SLeaderWaitMemberRep = class("SLeaderWaitMemberRep")
SLeaderWaitMemberRep.TYPEID = 12592146
function SLeaderWaitMemberRep:ctor()
  self.id = 12592146
end
function SLeaderWaitMemberRep:marshal(os)
end
function SLeaderWaitMemberRep:unmarshal(os)
end
function SLeaderWaitMemberRep:sizepolicy(size)
  return size <= 65535
end
return SLeaderWaitMemberRep
