local SInHomeRes = class("SInHomeRes")
SInHomeRes.TYPEID = 12605481
function SInHomeRes:ctor()
  self.id = 12605481
end
function SInHomeRes:marshal(os)
end
function SInHomeRes:unmarshal(os)
end
function SInHomeRes:sizepolicy(size)
  return size <= 65535
end
return SInHomeRes
