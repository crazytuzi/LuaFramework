local SSetCardInvisibleSuccess = class("SSetCardInvisibleSuccess")
SSetCardInvisibleSuccess.TYPEID = 12624395
function SSetCardInvisibleSuccess:ctor()
  self.id = 12624395
end
function SSetCardInvisibleSuccess:marshal(os)
end
function SSetCardInvisibleSuccess:unmarshal(os)
end
function SSetCardInvisibleSuccess:sizepolicy(size)
  return size <= 65535
end
return SSetCardInvisibleSuccess
