local CFuMoSkillVigorSellReq = class("CFuMoSkillVigorSellReq")
CFuMoSkillVigorSellReq.TYPEID = 12584965
function CFuMoSkillVigorSellReq:ctor(skillId, skillBagId, price, num)
  self.id = 12584965
  self.skillId = skillId or nil
  self.skillBagId = skillBagId or nil
  self.price = price or nil
  self.num = num or nil
end
function CFuMoSkillVigorSellReq:marshal(os)
  os:marshalInt32(self.skillId)
  os:marshalInt32(self.skillBagId)
  os:marshalInt32(self.price)
  os:marshalInt32(self.num)
end
function CFuMoSkillVigorSellReq:unmarshal(os)
  self.skillId = os:unmarshalInt32()
  self.skillBagId = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function CFuMoSkillVigorSellReq:sizepolicy(size)
  return size <= 65535
end
return CFuMoSkillVigorSellReq
