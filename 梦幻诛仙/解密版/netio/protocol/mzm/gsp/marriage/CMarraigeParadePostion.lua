local CMarraigeParadePostion = class("CMarraigeParadePostion")
CMarraigeParadePostion.TYPEID = 12599845
function CMarraigeParadePostion:ctor()
  self.id = 12599845
end
function CMarraigeParadePostion:marshal(os)
end
function CMarraigeParadePostion:unmarshal(os)
end
function CMarraigeParadePostion:sizepolicy(size)
  return size <= 65535
end
return CMarraigeParadePostion
