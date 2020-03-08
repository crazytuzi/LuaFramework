local SNotifyKnockOutCorpsQualification = class("SNotifyKnockOutCorpsQualification")
SNotifyKnockOutCorpsQualification.TYPEID = 12617082
function SNotifyKnockOutCorpsQualification:ctor(fight_type, is_has_qualification)
  self.id = 12617082
  self.fight_type = fight_type or nil
  self.is_has_qualification = is_has_qualification or nil
end
function SNotifyKnockOutCorpsQualification:marshal(os)
  os:marshalInt32(self.fight_type)
  os:marshalInt32(self.is_has_qualification)
end
function SNotifyKnockOutCorpsQualification:unmarshal(os)
  self.fight_type = os:unmarshalInt32()
  self.is_has_qualification = os:unmarshalInt32()
end
function SNotifyKnockOutCorpsQualification:sizepolicy(size)
  return size <= 65535
end
return SNotifyKnockOutCorpsQualification
