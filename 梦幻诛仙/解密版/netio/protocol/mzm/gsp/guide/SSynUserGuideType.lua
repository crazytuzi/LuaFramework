local SSynUserGuideType = class("SSynUserGuideType")
SSynUserGuideType.TYPEID = 12594951
function SSynUserGuideType:ctor(guidetype)
  self.id = 12594951
  self.guidetype = guidetype or nil
end
function SSynUserGuideType:marshal(os)
  os:marshalInt32(self.guidetype)
end
function SSynUserGuideType:unmarshal(os)
  self.guidetype = os:unmarshalInt32()
end
function SSynUserGuideType:sizepolicy(size)
  return size <= 65535
end
return SSynUserGuideType
