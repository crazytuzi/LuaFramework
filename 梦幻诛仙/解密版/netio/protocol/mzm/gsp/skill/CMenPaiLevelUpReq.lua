local CMenPaiLevelUpReq = class("CMenPaiLevelUpReq")
CMenPaiLevelUpReq.TYPEID = 12591618
function CMenPaiLevelUpReq:ctor(skillBagId)
  self.id = 12591618
  self.skillBagId = skillBagId or nil
end
function CMenPaiLevelUpReq:marshal(os)
  os:marshalInt32(self.skillBagId)
end
function CMenPaiLevelUpReq:unmarshal(os)
  self.skillBagId = os:unmarshalInt32()
end
function CMenPaiLevelUpReq:sizepolicy(size)
  return size <= 65535
end
return CMenPaiLevelUpReq
