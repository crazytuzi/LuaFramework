local CUsePetChangeModelItemReq = class("CUsePetChangeModelItemReq")
CUsePetChangeModelItemReq.TYPEID = 12590662
function CUsePetChangeModelItemReq:ctor(petId, itemKey)
  self.id = 12590662
  self.petId = petId or nil
  self.itemKey = itemKey or nil
end
function CUsePetChangeModelItemReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.itemKey)
end
function CUsePetChangeModelItemReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.itemKey = os:unmarshalInt32()
end
function CUsePetChangeModelItemReq:sizepolicy(size)
  return size <= 65535
end
return CUsePetChangeModelItemReq
