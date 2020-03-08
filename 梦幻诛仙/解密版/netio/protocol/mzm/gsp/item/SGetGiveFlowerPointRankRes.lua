local SGetGiveFlowerPointRankRes = class("SGetGiveFlowerPointRankRes")
SGetGiveFlowerPointRankRes.TYPEID = 12584798
function SGetGiveFlowerPointRankRes:ctor(rankList, mypoint, myrank)
  self.id = 12584798
  self.rankList = rankList or {}
  self.mypoint = mypoint or nil
  self.myrank = myrank or nil
end
function SGetGiveFlowerPointRankRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.rankList))
  for _, v in ipairs(self.rankList) do
    v:marshal(os)
  end
  os:marshalInt32(self.mypoint)
  os:marshalInt32(self.myrank)
end
function SGetGiveFlowerPointRankRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.item.GiveFlowerPointRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rankList, v)
  end
  self.mypoint = os:unmarshalInt32()
  self.myrank = os:unmarshalInt32()
end
function SGetGiveFlowerPointRankRes:sizepolicy(size)
  return size <= 65535
end
return SGetGiveFlowerPointRankRes
