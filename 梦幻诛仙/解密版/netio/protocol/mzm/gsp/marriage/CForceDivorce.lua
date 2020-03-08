local CForceDivorce = class("CForceDivorce")
CForceDivorce.TYPEID = 12599817
function CForceDivorce:ctor()
  self.id = 12599817
end
function CForceDivorce:marshal(os)
end
function CForceDivorce:unmarshal(os)
end
function CForceDivorce:sizepolicy(size)
  return size <= 65535
end
return CForceDivorce
