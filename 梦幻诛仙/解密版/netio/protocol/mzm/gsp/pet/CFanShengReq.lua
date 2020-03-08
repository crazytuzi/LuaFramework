local CFanShengReq = class("CFanShengReq")
CFanShengReq.TYPEID = 12590619
CFanShengReq.GAOJI_FANSHENG = 0
CFanShengReq.PUTONG_FANSHENG = 1
function CFanShengReq:ctor(petId, fanShengType, costType, yuanBaoNum)
  self.id = 12590619
  self.petId = petId or nil
  self.fanShengType = fanShengType or nil
  self.costType = costType or nil
  self.yuanBaoNum = yuanBaoNum or nil
end
function CFanShengReq:marshal(os)
  os:marshalInt64(self.petId)
  os:marshalInt32(self.fanShengType)
  os:marshalInt32(self.costType)
  os:marshalInt64(self.yuanBaoNum)
end
function CFanShengReq:unmarshal(os)
  self.petId = os:unmarshalInt64()
  self.fanShengType = os:unmarshalInt32()
  self.costType = os:unmarshalInt32()
  self.yuanBaoNum = os:unmarshalInt64()
end
function CFanShengReq:sizepolicy(size)
  return size <= 65535
end
return CFanShengReq
