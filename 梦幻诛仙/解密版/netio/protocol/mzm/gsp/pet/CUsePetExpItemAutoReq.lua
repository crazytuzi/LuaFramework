local CUsePetExpItemAutoReq = class("CUsePetExpItemAutoReq")
CUsePetExpItemAutoReq.TYPEID = 12590599
function CUsePetExpItemAutoReq:ctor(petId, itemKey)
  self.id = 12590599
  self.petId = petId or nil
  self.itemKey = itemKey or nil
end
function CUsePetExpItemAutoReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.itemKey)
end
function CUsePetExpItemAutoReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.itemKey = os:unmarshalInt32()
end
function CUsePetExpItemAutoReq:sizepolicy(size)
  return size <= 65535
end
return CUsePetExpItemAutoReq
