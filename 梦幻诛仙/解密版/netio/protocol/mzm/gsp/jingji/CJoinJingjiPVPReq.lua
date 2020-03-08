local CJoinJingjiPVPReq = class("CJoinJingjiPVPReq")
CJoinJingjiPVPReq.TYPEID = 12595717
function CJoinJingjiPVPReq:ctor()
  self.id = 12595717
end
function CJoinJingjiPVPReq:marshal(os)
end
function CJoinJingjiPVPReq:unmarshal(os)
end
function CJoinJingjiPVPReq:sizepolicy(size)
  return size <= 65535
end
return CJoinJingjiPVPReq
