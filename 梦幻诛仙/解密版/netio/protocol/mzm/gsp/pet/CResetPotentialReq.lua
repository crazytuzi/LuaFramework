local CResetPotentialReq = class("CResetPotentialReq")
CResetPotentialReq.TYPEID = 12590626
function CResetPotentialReq:ctor(petId, itemNum, yuanBaoNum)
  self.id = 12590626
  self.petId = petId or nil
  self.itemNum = itemNum or nil
  self.yuanBaoNum = yuanBaoNum or nil
end
function CResetPotentialReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.itemNum)
  os:marshalInt64(self.yuanBaoNum)
end
function CResetPotentialReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.itemNum = os:unmarshalInt32()
  self.yuanBaoNum = os:unmarshalInt64()
end
function CResetPotentialReq:sizepolicy(size)
  return size <= 65535
end
return CResetPotentialReq
