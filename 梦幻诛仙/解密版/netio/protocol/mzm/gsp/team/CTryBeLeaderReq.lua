local CTryBeLeaderReq = class("CTryBeLeaderReq")
CTryBeLeaderReq.TYPEID = 12588336
function CTryBeLeaderReq:ctor()
  self.id = 12588336
end
function CTryBeLeaderReq:marshal(os)
end
function CTryBeLeaderReq:unmarshal(os)
end
function CTryBeLeaderReq:sizepolicy(size)
  return size <= 65535
end
return CTryBeLeaderReq
