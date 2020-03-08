local SSellPetRes = class("SSellPetRes")
SSellPetRes.TYPEID = 12590634
function SSellPetRes:ctor(petCfgId, addMoney)
  self.id = 12590634
  self.petCfgId = petCfgId or nil
  self.addMoney = addMoney or nil
end
function SSellPetRes:marshal(os)
  os:marshalInt32(self.petCfgId)
  os:marshalInt32(self.addMoney)
end
function SSellPetRes:unmarshal(os)
  self.petCfgId = os:unmarshalInt32()
  self.addMoney = os:unmarshalInt32()
end
function SSellPetRes:sizepolicy(size)
  return size <= 65535
end
return SSellPetRes
