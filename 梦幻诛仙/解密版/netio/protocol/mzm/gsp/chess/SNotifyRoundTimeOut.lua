local SNotifyRoundTimeOut = class("SNotifyRoundTimeOut")
SNotifyRoundTimeOut.TYPEID = 12619025
function SNotifyRoundTimeOut:ctor()
  self.id = 12619025
end
function SNotifyRoundTimeOut:marshal(os)
end
function SNotifyRoundTimeOut:unmarshal(os)
end
function SNotifyRoundTimeOut:sizepolicy(size)
  return size <= 65535
end
return SNotifyRoundTimeOut
