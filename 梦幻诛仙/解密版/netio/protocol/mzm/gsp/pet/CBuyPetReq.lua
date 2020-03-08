local CBuyPetReq = class("CBuyPetReq")
CBuyPetReq.TYPEID = 12590624
function CBuyPetReq:ctor(petCfgId)
  self.id = 12590624
  self.petCfgId = petCfgId or nil
end
function CBuyPetReq:marshal(os)
  os:marshalInt32(self.petCfgId)
end
function CBuyPetReq:unmarshal(os)
  self.petCfgId = os:unmarshalInt32()
end
function CBuyPetReq:sizepolicy(size)
  return size <= 65535
end
return CBuyPetReq
