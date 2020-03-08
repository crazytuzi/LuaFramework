local SForceDivorceSucRes = class("SForceDivorceSucRes")
SForceDivorceSucRes.TYPEID = 12599832
function SForceDivorceSucRes:ctor()
  self.id = 12599832
end
function SForceDivorceSucRes:marshal(os)
end
function SForceDivorceSucRes:unmarshal(os)
end
function SForceDivorceSucRes:sizepolicy(size)
  return size <= 65535
end
return SForceDivorceSucRes
