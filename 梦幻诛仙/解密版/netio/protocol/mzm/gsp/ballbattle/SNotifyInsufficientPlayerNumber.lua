local SNotifyInsufficientPlayerNumber = class("SNotifyInsufficientPlayerNumber")
SNotifyInsufficientPlayerNumber.TYPEID = 12629267
function SNotifyInsufficientPlayerNumber:ctor()
  self.id = 12629267
end
function SNotifyInsufficientPlayerNumber:marshal(os)
end
function SNotifyInsufficientPlayerNumber:unmarshal(os)
end
function SNotifyInsufficientPlayerNumber:sizepolicy(size)
  return size <= 65535
end
return SNotifyInsufficientPlayerNumber
