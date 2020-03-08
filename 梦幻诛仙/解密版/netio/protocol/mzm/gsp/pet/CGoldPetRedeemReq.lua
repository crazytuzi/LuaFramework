local CGoldPetRedeemReq = class("CGoldPetRedeemReq")
CGoldPetRedeemReq.TYPEID = 12590648
CGoldPetRedeemReq.REDEEM_NPC_SERVICE_ID = 150205300
function CGoldPetRedeemReq:ctor(petCfgId)
  self.id = 12590648
  self.petCfgId = petCfgId or nil
end
function CGoldPetRedeemReq:marshal(os)
  os:marshalInt32(self.petCfgId)
end
function CGoldPetRedeemReq:unmarshal(os)
  self.petCfgId = os:unmarshalInt32()
end
function CGoldPetRedeemReq:sizepolicy(size)
  return size <= 65535
end
return CGoldPetRedeemReq
