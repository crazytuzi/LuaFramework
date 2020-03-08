local SSyncVitalityBrd = class("SSyncVitalityBrd")
SSyncVitalityBrd.TYPEID = 12589977
function SSyncVitalityBrd:ctor(vitality)
  self.id = 12589977
  self.vitality = vitality or nil
end
function SSyncVitalityBrd:marshal(os)
  os:marshalInt32(self.vitality)
end
function SSyncVitalityBrd:unmarshal(os)
  self.vitality = os:unmarshalInt32()
end
function SSyncVitalityBrd:sizepolicy(size)
  return size <= 65535
end
return SSyncVitalityBrd
