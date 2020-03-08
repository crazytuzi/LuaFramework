local CRemeberSkillReq = class("CRemeberSkillReq")
CRemeberSkillReq.TYPEID = 12590602
function CRemeberSkillReq:ctor(petId, skillId, costType, yuanBaoNum)
  self.id = 12590602
  self.petId = petId or nil
  self.skillId = skillId or nil
  self.costType = costType or nil
  self.yuanBaoNum = yuanBaoNum or nil
end
function CRemeberSkillReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.skillId)
  os:marshalInt32(self.costType)
  os:marshalInt64(self.yuanBaoNum)
end
function CRemeberSkillReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.skillId = os:unmarshalInt32()
  self.costType = os:unmarshalInt32()
  self.yuanBaoNum = os:unmarshalInt64()
end
function CRemeberSkillReq:sizepolicy(size)
  return size <= 65535
end
return CRemeberSkillReq
