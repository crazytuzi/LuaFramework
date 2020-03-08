local SLeaderRemendMemberRes = class("SLeaderRemendMemberRes")
SLeaderRemendMemberRes.TYPEID = 12607275
function SLeaderRemendMemberRes:ctor()
  self.id = 12607275
end
function SLeaderRemendMemberRes:marshal(os)
end
function SLeaderRemendMemberRes:unmarshal(os)
end
function SLeaderRemendMemberRes:sizepolicy(size)
  return size <= 65535
end
return SLeaderRemendMemberRes
