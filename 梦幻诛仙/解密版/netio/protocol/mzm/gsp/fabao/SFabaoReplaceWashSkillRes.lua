local SFabaoReplaceWashSkillRes = class("SFabaoReplaceWashSkillRes")
SFabaoReplaceWashSkillRes.TYPEID = 12596030
function SFabaoReplaceWashSkillRes:ctor(equiped, fabaouuid, skillid)
  self.id = 12596030
  self.equiped = equiped or nil
  self.fabaouuid = fabaouuid or nil
  self.skillid = skillid or nil
end
function SFabaoReplaceWashSkillRes:marshal(os)
  os:marshalInt32(self.equiped)
  os:marshalInt64(self.fabaouuid)
  os:marshalInt32(self.skillid)
end
function SFabaoReplaceWashSkillRes:unmarshal(os)
  self.equiped = os:unmarshalInt32()
  self.fabaouuid = os:unmarshalInt64()
  self.skillid = os:unmarshalInt32()
end
function SFabaoReplaceWashSkillRes:sizepolicy(size)
  return size <= 65535
end
return SFabaoReplaceWashSkillRes
