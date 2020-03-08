local CFactionListReq = class("CFactionListReq")
CFactionListReq.TYPEID = 12616731
function CFactionListReq:ctor()
  self.id = 12616731
end
function CFactionListReq:marshal(os)
end
function CFactionListReq:unmarshal(os)
end
function CFactionListReq:sizepolicy(size)
  return size <= 65535
end
return CFactionListReq
