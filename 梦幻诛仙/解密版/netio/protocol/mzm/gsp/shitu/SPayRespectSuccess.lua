local SPayRespectSuccess = class("SPayRespectSuccess")
SPayRespectSuccess.TYPEID = 12601631
function SPayRespectSuccess:ctor()
  self.id = 12601631
end
function SPayRespectSuccess:marshal(os)
end
function SPayRespectSuccess:unmarshal(os)
end
function SPayRespectSuccess:sizepolicy(size)
  return size <= 65535
end
return SPayRespectSuccess
