local SNotifyFinalMatchBegin = class("SNotifyFinalMatchBegin")
SNotifyFinalMatchBegin.TYPEID = 12617060
function SNotifyFinalMatchBegin:ctor()
  self.id = 12617060
end
function SNotifyFinalMatchBegin:marshal(os)
end
function SNotifyFinalMatchBegin:unmarshal(os)
end
function SNotifyFinalMatchBegin:sizepolicy(size)
  return size <= 65535
end
return SNotifyFinalMatchBegin
