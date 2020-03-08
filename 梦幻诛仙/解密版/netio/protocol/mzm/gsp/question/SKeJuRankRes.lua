local SKeJuRankRes = class("SKeJuRankRes")
SKeJuRankRes.TYPEID = 12594726
function SKeJuRankRes:ctor(rankList)
  self.id = 12594726
  self.rankList = rankList or {}
end
function SKeJuRankRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.rankList))
  for _, v in ipairs(self.rankList) do
    v:marshal(os)
  end
end
function SKeJuRankRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.question.KeJuChart")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rankList, v)
  end
end
function SKeJuRankRes:sizepolicy(size)
  return size <= 65535
end
return SKeJuRankRes
