local CGetChangeNameVoteInfoReq = class("CGetChangeNameVoteInfoReq")
CGetChangeNameVoteInfoReq.TYPEID = 12597812
function CGetChangeNameVoteInfoReq:ctor()
  self.id = 12597812
end
function CGetChangeNameVoteInfoReq:marshal(os)
end
function CGetChangeNameVoteInfoReq:unmarshal(os)
end
function CGetChangeNameVoteInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetChangeNameVoteInfoReq
