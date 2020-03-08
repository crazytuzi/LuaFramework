local SLadderRankRes = class("SLadderRankRes")
SLadderRankRes.TYPEID = 12607268
function SLadderRankRes:ctor(rankType, rankDatas)
  self.id = 12607268
  self.rankType = rankType or nil
  self.rankDatas = rankDatas or {}
end
function SLadderRankRes:marshal(os)
  os:marshalInt32(self.rankType)
  os:marshalCompactUInt32(table.getn(self.rankDatas))
  for _, v in ipairs(self.rankDatas) do
    v:marshal(os)
  end
end
function SLadderRankRes:unmarshal(os)
  self.rankType = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.ladder.LadderRankRoleData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rankDatas, v)
  end
end
function SLadderRankRes:sizepolicy(size)
  return size <= 65535
end
return SLadderRankRes
