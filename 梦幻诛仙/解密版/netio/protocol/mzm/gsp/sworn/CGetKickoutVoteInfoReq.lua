local CGetKickoutVoteInfoReq = class("CGetKickoutVoteInfoReq")
CGetKickoutVoteInfoReq.TYPEID = 12597811
function CGetKickoutVoteInfoReq:ctor()
  self.id = 12597811
end
function CGetKickoutVoteInfoReq:marshal(os)
end
function CGetKickoutVoteInfoReq:unmarshal(os)
end
function CGetKickoutVoteInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetKickoutVoteInfoReq
