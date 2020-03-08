local CChildrenWearPetEquipReq = class("CChildrenWearPetEquipReq")
CChildrenWearPetEquipReq.TYPEID = 12609424
function CChildrenWearPetEquipReq:ctor(childrenid, itemKey)
  self.id = 12609424
  self.childrenid = childrenid or nil
  self.itemKey = itemKey or nil
end
function CChildrenWearPetEquipReq:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.itemKey)
end
function CChildrenWearPetEquipReq:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.itemKey = os:unmarshalInt32()
end
function CChildrenWearPetEquipReq:sizepolicy(size)
  return size <= 65535
end
return CChildrenWearPetEquipReq
