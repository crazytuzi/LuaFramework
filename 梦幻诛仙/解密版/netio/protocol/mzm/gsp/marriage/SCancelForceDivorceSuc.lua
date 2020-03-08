local SCancelForceDivorceSuc = class("SCancelForceDivorceSuc")
SCancelForceDivorceSuc.TYPEID = 12599829
function SCancelForceDivorceSuc:ctor()
  self.id = 12599829
end
function SCancelForceDivorceSuc:marshal(os)
end
function SCancelForceDivorceSuc:unmarshal(os)
end
function SCancelForceDivorceSuc:sizepolicy(size)
  return size <= 65535
end
return SCancelForceDivorceSuc
