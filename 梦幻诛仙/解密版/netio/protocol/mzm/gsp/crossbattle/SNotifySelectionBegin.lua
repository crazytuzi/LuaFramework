local SNotifySelectionBegin = class("SNotifySelectionBegin")
SNotifySelectionBegin.TYPEID = 12616997
function SNotifySelectionBegin:ctor()
  self.id = 12616997
end
function SNotifySelectionBegin:marshal(os)
end
function SNotifySelectionBegin:unmarshal(os)
end
function SNotifySelectionBegin:sizepolicy(size)
  return size <= 65535
end
return SNotifySelectionBegin
