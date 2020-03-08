local CExpandPetBagReq = class("CExpandPetBagReq")
CExpandPetBagReq.TYPEID = 12590609
function CExpandPetBagReq:ctor(itemNum, yuanBaoNum)
  self.id = 12590609
  self.itemNum = itemNum or nil
  self.yuanBaoNum = yuanBaoNum or nil
end
function CExpandPetBagReq:marshal(os)
  os:marshalInt32(self.itemNum)
  os:marshalInt64(self.yuanBaoNum)
end
function CExpandPetBagReq:unmarshal(os)
  self.itemNum = os:unmarshalInt32()
  self.yuanBaoNum = os:unmarshalInt64()
end
function CExpandPetBagReq:sizepolicy(size)
  return size <= 65535
end
return CExpandPetBagReq
