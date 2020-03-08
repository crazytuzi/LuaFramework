local SNotifySelectionMatchBegin = class("SNotifySelectionMatchBegin")
SNotifySelectionMatchBegin.TYPEID = 12617027
function SNotifySelectionMatchBegin:ctor()
  self.id = 12617027
end
function SNotifySelectionMatchBegin:marshal(os)
end
function SNotifySelectionMatchBegin:unmarshal(os)
end
function SNotifySelectionMatchBegin:sizepolicy(size)
  return size <= 65535
end
return SNotifySelectionMatchBegin
