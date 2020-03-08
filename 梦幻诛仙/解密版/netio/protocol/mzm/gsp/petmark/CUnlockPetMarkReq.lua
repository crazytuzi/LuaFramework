local CUnlockPetMarkReq = class("CUnlockPetMarkReq")
CUnlockPetMarkReq.TYPEID = 12628486
function CUnlockPetMarkReq:ctor(item_uuid)
  self.id = 12628486
  self.item_uuid = item_uuid or nil
end
function CUnlockPetMarkReq:marshal(os)
  os:marshalInt64(self.item_uuid)
end
function CUnlockPetMarkReq:unmarshal(os)
  self.item_uuid = os:unmarshalInt64()
end
function CUnlockPetMarkReq:sizepolicy(size)
  return size <= 65535
end
return CUnlockPetMarkReq
