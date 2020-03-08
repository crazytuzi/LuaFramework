local CPetSoulRandomPropReq = class("CPetSoulRandomPropReq")
CPetSoulRandomPropReq.TYPEID = 12590667
function CPetSoulRandomPropReq:ctor(petId, pos, isUseYuanbao, useYuanBaoNum, totalYuanBaoNum)
  self.id = 12590667
  self.petId = petId or nil
  self.pos = pos or nil
  self.isUseYuanbao = isUseYuanbao or nil
  self.useYuanBaoNum = useYuanBaoNum or nil
  self.totalYuanBaoNum = totalYuanBaoNum or nil
end
function CPetSoulRandomPropReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.pos)
  os:marshalInt32(self.isUseYuanbao)
  os:marshalInt32(self.useYuanBaoNum)
  os:marshalInt64(self.totalYuanBaoNum)
end
function CPetSoulRandomPropReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.pos = os:unmarshalInt32()
  self.isUseYuanbao = os:unmarshalInt32()
  self.useYuanBaoNum = os:unmarshalInt32()
  self.totalYuanBaoNum = os:unmarshalInt64()
end
function CPetSoulRandomPropReq:sizepolicy(size)
  return size <= 65535
end
return CPetSoulRandomPropReq
