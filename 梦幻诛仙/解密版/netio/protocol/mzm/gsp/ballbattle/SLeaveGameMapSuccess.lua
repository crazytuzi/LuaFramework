local SLeaveGameMapSuccess = class("SLeaveGameMapSuccess")
SLeaveGameMapSuccess.TYPEID = 12629251
function SLeaveGameMapSuccess:ctor()
  self.id = 12629251
end
function SLeaveGameMapSuccess:marshal(os)
end
function SLeaveGameMapSuccess:unmarshal(os)
end
function SLeaveGameMapSuccess:sizepolicy(size)
  return size <= 65535
end
return SLeaveGameMapSuccess
