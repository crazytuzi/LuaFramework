local CJoinZhenyaoReq = class("CJoinZhenyaoReq")
CJoinZhenyaoReq.TYPEID = 12587525
function CJoinZhenyaoReq:ctor()
  self.id = 12587525
end
function CJoinZhenyaoReq:marshal(os)
end
function CJoinZhenyaoReq:unmarshal(os)
end
function CJoinZhenyaoReq:sizepolicy(size)
  return size <= 65535
end
return CJoinZhenyaoReq
