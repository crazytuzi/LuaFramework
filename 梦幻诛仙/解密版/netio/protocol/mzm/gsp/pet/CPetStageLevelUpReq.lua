local CPetStageLevelUpReq = class("CPetStageLevelUpReq")
CPetStageLevelUpReq.TYPEID = 12590658
function CPetStageLevelUpReq:ctor(petId, isCostYuanBao, curYuanBao, costYuanBao)
  self.id = 12590658
  self.petId = petId or nil
  self.isCostYuanBao = isCostYuanBao or nil
  self.curYuanBao = curYuanBao or nil
  self.costYuanBao = costYuanBao or nil
end
function CPetStageLevelUpReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.isCostYuanBao)
  os:marshalInt64(self.curYuanBao)
  os:marshalInt32(self.costYuanBao)
end
function CPetStageLevelUpReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.isCostYuanBao = os:unmarshalInt32()
  self.curYuanBao = os:unmarshalInt64()
  self.costYuanBao = os:unmarshalInt32()
end
function CPetStageLevelUpReq:sizepolicy(size)
  return size <= 65535
end
return CPetStageLevelUpReq
