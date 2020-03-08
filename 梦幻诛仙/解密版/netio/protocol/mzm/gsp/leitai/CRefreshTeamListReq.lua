local CRefreshTeamListReq = class("CRefreshTeamListReq")
CRefreshTeamListReq.TYPEID = 12591879
function CRefreshTeamListReq:ctor()
  self.id = 12591879
end
function CRefreshTeamListReq:marshal(os)
end
function CRefreshTeamListReq:unmarshal(os)
end
function CRefreshTeamListReq:sizepolicy(size)
  return size <= 65535
end
return CRefreshTeamListReq
