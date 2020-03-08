local CMoShouPetRedeemReq = class("CMoShouPetRedeemReq")
CMoShouPetRedeemReq.TYPEID = 12590650
CMoShouPetRedeemReq.REDEEM_NPC_SERVICE_ID = 150205303
function CMoShouPetRedeemReq:ctor(petCfgId)
  self.id = 12590650
  self.petCfgId = petCfgId or nil
end
function CMoShouPetRedeemReq:marshal(os)
  os:marshalInt32(self.petCfgId)
end
function CMoShouPetRedeemReq:unmarshal(os)
  self.petCfgId = os:unmarshalInt32()
end
function CMoShouPetRedeemReq:sizepolicy(size)
  return size <= 65535
end
return CMoShouPetRedeemReq
