local CCampsInfoReq = class("CCampsInfoReq")
CCampsInfoReq.TYPEID = 12596743
function CCampsInfoReq:ctor()
  self.id = 12596743
end
function CCampsInfoReq:marshal(os)
end
function CCampsInfoReq:unmarshal(os)
end
function CCampsInfoReq:sizepolicy(size)
  return size <= 65535
end
return CCampsInfoReq
