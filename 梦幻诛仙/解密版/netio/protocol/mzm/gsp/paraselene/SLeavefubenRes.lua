local SLeavefubenRes = class("SLeavefubenRes")
SLeavefubenRes.TYPEID = 12598284
function SLeavefubenRes:ctor()
  self.id = 12598284
end
function SLeavefubenRes:marshal(os)
end
function SLeavefubenRes:unmarshal(os)
end
function SLeavefubenRes:sizepolicy(size)
  return size <= 65535
end
return SLeavefubenRes
