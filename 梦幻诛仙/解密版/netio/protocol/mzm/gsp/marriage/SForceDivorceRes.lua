local SForceDivorceRes = class("SForceDivorceRes")
SForceDivorceRes.TYPEID = 12599827
function SForceDivorceRes:ctor()
  self.id = 12599827
end
function SForceDivorceRes:marshal(os)
end
function SForceDivorceRes:unmarshal(os)
end
function SForceDivorceRes:sizepolicy(size)
  return size <= 65535
end
return SForceDivorceRes
