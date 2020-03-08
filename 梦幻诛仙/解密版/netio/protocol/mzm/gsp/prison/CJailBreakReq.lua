local CJailBreakReq = class("CJailBreakReq")
CJailBreakReq.TYPEID = 12620035
function CJailBreakReq:ctor()
  self.id = 12620035
end
function CJailBreakReq:marshal(os)
end
function CJailBreakReq:unmarshal(os)
end
function CJailBreakReq:sizepolicy(size)
  return size <= 65535
end
return CJailBreakReq
