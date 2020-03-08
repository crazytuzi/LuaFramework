local CCancelForceDivorce = class("CCancelForceDivorce")
CCancelForceDivorce.TYPEID = 12599828
function CCancelForceDivorce:ctor()
  self.id = 12599828
end
function CCancelForceDivorce:marshal(os)
end
function CCancelForceDivorce:unmarshal(os)
end
function CCancelForceDivorce:sizepolicy(size)
  return size <= 65535
end
return CCancelForceDivorce
