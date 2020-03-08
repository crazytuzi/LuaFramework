local SLeavePrepareMapSuccess = class("SLeavePrepareMapSuccess")
SLeavePrepareMapSuccess.TYPEID = 12629250
function SLeavePrepareMapSuccess:ctor()
  self.id = 12629250
end
function SLeavePrepareMapSuccess:marshal(os)
end
function SLeavePrepareMapSuccess:unmarshal(os)
end
function SLeavePrepareMapSuccess:sizepolicy(size)
  return size <= 65535
end
return SLeavePrepareMapSuccess
