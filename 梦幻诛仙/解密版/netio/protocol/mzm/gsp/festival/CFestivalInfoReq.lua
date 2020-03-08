local CFestivalInfoReq = class("CFestivalInfoReq")
CFestivalInfoReq.TYPEID = 12600066
function CFestivalInfoReq:ctor()
  self.id = 12600066
end
function CFestivalInfoReq:marshal(os)
end
function CFestivalInfoReq:unmarshal(os)
end
function CFestivalInfoReq:sizepolicy(size)
  return size <= 65535
end
return CFestivalInfoReq
