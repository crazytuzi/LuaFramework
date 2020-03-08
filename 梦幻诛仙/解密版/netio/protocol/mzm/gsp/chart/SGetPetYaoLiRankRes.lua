local SGetPetYaoLiRankRes = class("SGetPetYaoLiRankRes")
SGetPetYaoLiRankRes.TYPEID = 12587778
function SGetPetYaoLiRankRes:ctor(rankList, nextUpdateTime, myNo)
  self.id = 12587778
  self.rankList = rankList or {}
  self.nextUpdateTime = nextUpdateTime or nil
  self.myNo = myNo or nil
end
function SGetPetYaoLiRankRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.rankList))
  for _, v in ipairs(self.rankList) do
    v:marshal(os)
  end
  os:marshalInt64(self.nextUpdateTime)
  os:marshalInt32(self.myNo)
end
function SGetPetYaoLiRankRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.chart.PetYaoLiRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rankList, v)
  end
  self.nextUpdateTime = os:unmarshalInt64()
  self.myNo = os:unmarshalInt32()
end
function SGetPetYaoLiRankRes:sizepolicy(size)
  return size <= 65535
end
return SGetPetYaoLiRankRes
