local STriggerMinimumGuarantee = class("STriggerMinimumGuarantee")
STriggerMinimumGuarantee.TYPEID = 12590665
function STriggerMinimumGuarantee:ctor(guarantee_skill_num)
  self.id = 12590665
  self.guarantee_skill_num = guarantee_skill_num or nil
end
function STriggerMinimumGuarantee:marshal(os)
  os:marshalInt32(self.guarantee_skill_num)
end
function STriggerMinimumGuarantee:unmarshal(os)
  self.guarantee_skill_num = os:unmarshalInt32()
end
function STriggerMinimumGuarantee:sizepolicy(size)
  return size <= 65535
end
return STriggerMinimumGuarantee
