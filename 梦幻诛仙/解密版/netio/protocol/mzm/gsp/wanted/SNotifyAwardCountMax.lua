local SNotifyAwardCountMax = class("SNotifyAwardCountMax")
SNotifyAwardCountMax.TYPEID = 12620300
function SNotifyAwardCountMax:ctor()
  self.id = 12620300
end
function SNotifyAwardCountMax:marshal(os)
end
function SNotifyAwardCountMax:unmarshal(os)
end
function SNotifyAwardCountMax:sizepolicy(size)
  return size <= 65535
end
return SNotifyAwardCountMax
