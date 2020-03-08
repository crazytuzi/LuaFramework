local CStartWatchmoonReq = class("CStartWatchmoonReq")
CStartWatchmoonReq.TYPEID = 12600844
function CStartWatchmoonReq:ctor()
  self.id = 12600844
end
function CStartWatchmoonReq:marshal(os)
end
function CStartWatchmoonReq:unmarshal(os)
end
function CStartWatchmoonReq:sizepolicy(size)
  return size <= 65535
end
return CStartWatchmoonReq
