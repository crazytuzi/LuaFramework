local CJoinBaoTuReq = class("CJoinBaoTuReq")
CJoinBaoTuReq.TYPEID = 12583683
function CJoinBaoTuReq:ctor()
  self.id = 12583683
end
function CJoinBaoTuReq:marshal(os)
end
function CJoinBaoTuReq:unmarshal(os)
end
function CJoinBaoTuReq:sizepolicy(size)
  return size <= 65535
end
return CJoinBaoTuReq
