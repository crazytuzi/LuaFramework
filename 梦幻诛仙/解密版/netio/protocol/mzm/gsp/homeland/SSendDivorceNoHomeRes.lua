local SSendDivorceNoHomeRes = class("SSendDivorceNoHomeRes")
SSendDivorceNoHomeRes.TYPEID = 12605496
function SSendDivorceNoHomeRes:ctor()
  self.id = 12605496
end
function SSendDivorceNoHomeRes:marshal(os)
end
function SSendDivorceNoHomeRes:unmarshal(os)
end
function SSendDivorceNoHomeRes:sizepolicy(size)
  return size <= 65535
end
return SSendDivorceNoHomeRes
