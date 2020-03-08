local SNotifyFinalResultOut = class("SNotifyFinalResultOut")
SNotifyFinalResultOut.TYPEID = 12617083
function SNotifyFinalResultOut:ctor()
  self.id = 12617083
end
function SNotifyFinalResultOut:marshal(os)
end
function SNotifyFinalResultOut:unmarshal(os)
end
function SNotifyFinalResultOut:sizepolicy(size)
  return size <= 65535
end
return SNotifyFinalResultOut
