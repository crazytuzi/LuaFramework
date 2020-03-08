local SSyncGangVitalityChange = class("SSyncGangVitalityChange")
SSyncGangVitalityChange.TYPEID = 12589827
function SSyncGangVitalityChange:ctor(vitality)
  self.id = 12589827
  self.vitality = vitality or nil
end
function SSyncGangVitalityChange:marshal(os)
  os:marshalInt32(self.vitality)
end
function SSyncGangVitalityChange:unmarshal(os)
  self.vitality = os:unmarshalInt32()
end
function SSyncGangVitalityChange:sizepolicy(size)
  return size <= 65535
end
return SSyncGangVitalityChange
