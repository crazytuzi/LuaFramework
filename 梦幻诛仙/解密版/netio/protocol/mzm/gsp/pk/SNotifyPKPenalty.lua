local SNotifyPKPenalty = class("SNotifyPKPenalty")
SNotifyPKPenalty.TYPEID = 12619799
function SNotifyPKPenalty:ctor(moral_value_penalty, equipment_usability_penalty)
  self.id = 12619799
  self.moral_value_penalty = moral_value_penalty or nil
  self.equipment_usability_penalty = equipment_usability_penalty or nil
end
function SNotifyPKPenalty:marshal(os)
  os:marshalInt32(self.moral_value_penalty)
  os:marshalInt32(self.equipment_usability_penalty)
end
function SNotifyPKPenalty:unmarshal(os)
  self.moral_value_penalty = os:unmarshalInt32()
  self.equipment_usability_penalty = os:unmarshalInt32()
end
function SNotifyPKPenalty:sizepolicy(size)
  return size <= 65535
end
return SNotifyPKPenalty
