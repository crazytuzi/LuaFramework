local SUseFuMoSkillRes = class("SUseFuMoSkillRes")
SUseFuMoSkillRes.TYPEID = 12591621
function SUseFuMoSkillRes:ctor(itemId)
  self.id = 12591621
  self.itemId = itemId or nil
end
function SUseFuMoSkillRes:marshal(os)
  os:marshalInt32(self.itemId)
end
function SUseFuMoSkillRes:unmarshal(os)
  self.itemId = os:unmarshalInt32()
end
function SUseFuMoSkillRes:sizepolicy(size)
  return size <= 65535
end
return SUseFuMoSkillRes
