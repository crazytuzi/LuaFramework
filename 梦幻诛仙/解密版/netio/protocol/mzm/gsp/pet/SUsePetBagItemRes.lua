local SUsePetBagItemRes = class("SUsePetBagItemRes")
SUsePetBagItemRes.TYPEID = 12590644
function SUsePetBagItemRes:ctor(petCfgId)
  self.id = 12590644
  self.petCfgId = petCfgId or nil
end
function SUsePetBagItemRes:marshal(os)
  os:marshalInt32(self.petCfgId)
end
function SUsePetBagItemRes:unmarshal(os)
  self.petCfgId = os:unmarshalInt32()
end
function SUsePetBagItemRes:sizepolicy(size)
  return size <= 65535
end
return SUsePetBagItemRes
