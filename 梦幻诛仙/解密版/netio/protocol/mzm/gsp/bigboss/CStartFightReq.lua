local CStartFightReq = class("CStartFightReq")
CStartFightReq.TYPEID = 12598021
function CStartFightReq:ctor()
  self.id = 12598021
end
function CStartFightReq:marshal(os)
end
function CStartFightReq:unmarshal(os)
end
function CStartFightReq:sizepolicy(size)
  return size <= 65535
end
return CStartFightReq
