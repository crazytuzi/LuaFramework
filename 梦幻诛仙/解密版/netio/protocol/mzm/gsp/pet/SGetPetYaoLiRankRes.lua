local SGetPetYaoLiRankRes = class("SGetPetYaoLiRankRes")
SGetPetYaoLiRankRes.TYPEID = 12590652
function SGetPetYaoLiRankRes:ctor(rankList, myNo)
  self.id = 12590652
  self.rankList = rankList or {}
  self.myNo = myNo or nil
end
function SGetPetYaoLiRankRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.rankList))
  for _, v in ipairs(self.rankList) do
    v:marshal(os)
  end
  os:marshalInt32(self.myNo)
end
function SGetPetYaoLiRankRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.pet.PetYaoLiRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rankList, v)
  end
  self.myNo = os:unmarshalInt32()
end
function SGetPetYaoLiRankRes:sizepolicy(size)
  return size <= 65535
end
return SGetPetYaoLiRankRes
