local CJoinHulaReq = class("CJoinHulaReq")
CJoinHulaReq.TYPEID = 12608779
function CJoinHulaReq:ctor()
  self.id = 12608779
end
function CJoinHulaReq:marshal(os)
end
function CJoinHulaReq:unmarshal(os)
end
function CJoinHulaReq:sizepolicy(size)
  return size <= 65535
end
return CJoinHulaReq
