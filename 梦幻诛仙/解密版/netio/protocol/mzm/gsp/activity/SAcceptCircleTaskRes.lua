local SAcceptCircleTaskRes = class("SAcceptCircleTaskRes")
SAcceptCircleTaskRes.TYPEID = 12587536
function SAcceptCircleTaskRes:ctor()
  self.id = 12587536
end
function SAcceptCircleTaskRes:marshal(os)
end
function SAcceptCircleTaskRes:unmarshal(os)
end
function SAcceptCircleTaskRes:sizepolicy(size)
  return size <= 65535
end
return SAcceptCircleTaskRes
