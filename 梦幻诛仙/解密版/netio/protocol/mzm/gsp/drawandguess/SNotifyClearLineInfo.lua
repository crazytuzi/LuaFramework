local SNotifyClearLineInfo = class("SNotifyClearLineInfo")
SNotifyClearLineInfo.TYPEID = 12617256
function SNotifyClearLineInfo:ctor()
  self.id = 12617256
end
function SNotifyClearLineInfo:marshal(os)
end
function SNotifyClearLineInfo:unmarshal(os)
end
function SNotifyClearLineInfo:sizepolicy(size)
  return size <= 65535
end
return SNotifyClearLineInfo
