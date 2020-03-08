local SNotifyPutInJail = class("SNotifyPutInJail")
SNotifyPutInJail.TYPEID = 12620048
function SNotifyPutInJail:ctor()
  self.id = 12620048
end
function SNotifyPutInJail:marshal(os)
end
function SNotifyPutInJail:unmarshal(os)
end
function SNotifyPutInJail:sizepolicy(size)
  return size <= 65535
end
return SNotifyPutInJail
