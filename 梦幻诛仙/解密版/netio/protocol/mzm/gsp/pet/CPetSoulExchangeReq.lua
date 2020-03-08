local CPetSoulExchangeReq = class("CPetSoulExchangeReq")
CPetSoulExchangeReq.TYPEID = 12590671
function CPetSoulExchangeReq:ctor(petId1, petId2, isUseYuanbao, useYuanBaoNum, totalYuanBaoNum)
  self.id = 12590671
  self.petId1 = petId1 or nil
  self.petId2 = petId2 or nil
  self.isUseYuanbao = isUseYuanbao or nil
  self.useYuanBaoNum = useYuanBaoNum or nil
  self.totalYuanBaoNum = totalYuanBaoNum or nil
end
function CPetSoulExchangeReq:marshal(os)
  os:marshalInt64(self.petId1)
  os:marshalInt64(self.petId2)
  os:marshalInt32(self.isUseYuanbao)
  os:marshalInt32(self.useYuanBaoNum)
  os:marshalInt64(self.totalYuanBaoNum)
end
function CPetSoulExchangeReq:unmarshal(os)
  self.petId1 = os:unmarshalInt64()
  self.petId2 = os:unmarshalInt64()
  self.isUseYuanbao = os:unmarshalInt32()
  self.useYuanBaoNum = os:unmarshalInt32()
  self.totalYuanBaoNum = os:unmarshalInt64()
end
function CPetSoulExchangeReq:sizepolicy(size)
  return size <= 65535
end
return CPetSoulExchangeReq
