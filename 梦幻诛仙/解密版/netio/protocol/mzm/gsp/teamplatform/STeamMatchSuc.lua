local STeamMatchSuc = class("STeamMatchSuc")
STeamMatchSuc.TYPEID = 12593673
function STeamMatchSuc:ctor()
  self.id = 12593673
end
function STeamMatchSuc:marshal(os)
end
function STeamMatchSuc:unmarshal(os)
end
function STeamMatchSuc:sizepolicy(size)
  return size <= 65535
end
return STeamMatchSuc
