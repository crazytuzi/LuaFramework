local CHuaShengReq = class("CHuaShengReq")
CHuaShengReq.TYPEID = 12590647
CHuaShengReq.NO_USE_HUA_SHENG_MIMMUM_GUARANTEE = 0
CHuaShengReq.USE_LOW_HUA_SHENG_MIMMUM_GUARANTEE = 1
CHuaShengReq.USE_HIGH_HUA_SHENG_MIMMUM_GUARANTEE = 2
function CHuaShengReq:ctor(mainPetId, fuPetId, costType, yuanBaoNum, minimum_guarantee_type, need_yuan_bao)
  self.id = 12590647
  self.mainPetId = mainPetId or nil
  self.fuPetId = fuPetId or nil
  self.costType = costType or nil
  self.yuanBaoNum = yuanBaoNum or nil
  self.minimum_guarantee_type = minimum_guarantee_type or nil
  self.need_yuan_bao = need_yuan_bao or nil
end
function CHuaShengReq:marshal(os)
  os:marshalInt64(self.mainPetId)
  os:marshalInt64(self.fuPetId)
  os:marshalInt32(self.costType)
  os:marshalInt64(self.yuanBaoNum)
  os:marshalInt32(self.minimum_guarantee_type)
  os:marshalInt32(self.need_yuan_bao)
end
function CHuaShengReq:unmarshal(os)
  self.mainPetId = os:unmarshalInt64()
  self.fuPetId = os:unmarshalInt64()
  self.costType = os:unmarshalInt32()
  self.yuanBaoNum = os:unmarshalInt64()
  self.minimum_guarantee_type = os:unmarshalInt32()
  self.need_yuan_bao = os:unmarshalInt32()
end
function CHuaShengReq:sizepolicy(size)
  return size <= 65535
end
return CHuaShengReq
