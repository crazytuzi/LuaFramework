local SNotifyFinalBegin = class("SNotifyFinalBegin")
SNotifyFinalBegin.TYPEID = 12617059
function SNotifyFinalBegin:ctor()
  self.id = 12617059
end
function SNotifyFinalBegin:marshal(os)
end
function SNotifyFinalBegin:unmarshal(os)
end
function SNotifyFinalBegin:sizepolicy(size)
  return size <= 65535
end
return SNotifyFinalBegin
