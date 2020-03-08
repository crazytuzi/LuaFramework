local SSynFriendTeamMem = class("SSynFriendTeamMem")
SSynFriendTeamMem.TYPEID = 12587018
function SSynFriendTeamMem:ctor(friendId, teamMemCount)
  self.id = 12587018
  self.friendId = friendId or nil
  self.teamMemCount = teamMemCount or nil
end
function SSynFriendTeamMem:marshal(os)
  os:marshalInt64(self.friendId)
  os:marshalInt32(self.teamMemCount)
end
function SSynFriendTeamMem:unmarshal(os)
  self.friendId = os:unmarshalInt64()
  self.teamMemCount = os:unmarshalInt32()
end
function SSynFriendTeamMem:sizepolicy(size)
  return size <= 65535
end
return SSynFriendTeamMem
