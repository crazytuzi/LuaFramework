local CGetPetModelItemReq = class("CGetPetModelItemReq")
CGetPetModelItemReq.TYPEID = 12590664
function CGetPetModelItemReq:ctor(petId, isCostYuanBao, curYuanBao, costYuanBao)
  self.id = 12590664
  self.petId = petId or nil
  self.isCostYuanBao = isCostYuanBao or nil
  self.curYuanBao = curYuanBao or nil
  self.costYuanBao = costYuanBao or nil
end
function CGetPetModelItemReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.isCostYuanBao)
  os:marshalInt64(self.curYuanBao)
  os:marshalInt32(self.costYuanBao)
end
function CGetPetModelItemReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.isCostYuanBao = os:unmarshalInt32()
  self.curYuanBao = os:unmarshalInt64()
  self.costYuanBao = os:unmarshalInt32()
end
function CGetPetModelItemReq:sizepolicy(size)
  return size <= 65535
end
return CGetPetModelItemReq
