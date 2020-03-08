local CExpandPetDepotReq = class("CExpandPetDepotReq")
CExpandPetDepotReq.TYPEID = 12590625
function CExpandPetDepotReq:ctor(itemNum, yuanBaoNum)
  self.id = 12590625
  self.itemNum = itemNum or nil
  self.yuanBaoNum = yuanBaoNum or nil
end
function CExpandPetDepotReq:marshal(os)
  os:marshalInt32(self.itemNum)
  os:marshalInt64(self.yuanBaoNum)
end
function CExpandPetDepotReq:unmarshal(os)
  self.itemNum = os:unmarshalInt32()
  self.yuanBaoNum = os:unmarshalInt64()
end
function CExpandPetDepotReq:sizepolicy(size)
  return size <= 65535
end
return CExpandPetDepotReq
