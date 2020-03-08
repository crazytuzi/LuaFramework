local CTransforToRobLocation = class("CTransforToRobLocation")
CTransforToRobLocation.TYPEID = 12599850
function CTransforToRobLocation:ctor()
  self.id = 12599850
end
function CTransforToRobLocation:marshal(os)
end
function CTransforToRobLocation:unmarshal(os)
end
function CTransforToRobLocation:sizepolicy(size)
  return size <= 65535
end
return CTransforToRobLocation
