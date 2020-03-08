local SSetCardVisibleSuccess = class("SSetCardVisibleSuccess")
SSetCardVisibleSuccess.TYPEID = 12624402
function SSetCardVisibleSuccess:ctor()
  self.id = 12624402
end
function SSetCardVisibleSuccess:marshal(os)
end
function SSetCardVisibleSuccess:unmarshal(os)
end
function SSetCardVisibleSuccess:sizepolicy(size)
  return size <= 65535
end
return SSetCardVisibleSuccess
