local CGetVoteStatusReq = class("CGetVoteStatusReq")
CGetVoteStatusReq.TYPEID = 12602113
function CGetVoteStatusReq:ctor()
  self.id = 12602113
end
function CGetVoteStatusReq:marshal(os)
end
function CGetVoteStatusReq:unmarshal(os)
end
function CGetVoteStatusReq:sizepolicy(size)
  return size <= 65535
end
return CGetVoteStatusReq
