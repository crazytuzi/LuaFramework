local SJiuXiaoRankRes = class("SJiuXiaoRankRes")
SJiuXiaoRankRes.TYPEID = 12595473
function SJiuXiaoRankRes:ctor(rankType, rankDatas)
  self.id = 12595473
  self.rankType = rankType or nil
  self.rankDatas = rankDatas or {}
end
function SJiuXiaoRankRes:marshal(os)
  os:marshalInt32(self.rankType)
  os:marshalCompactUInt32(table.getn(self.rankDatas))
  for _, v in ipairs(self.rankDatas) do
    v:marshal(os)
  end
end
function SJiuXiaoRankRes:unmarshal(os)
  self.rankType = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.jiuxiao.JiuXiaoRankRoleData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rankDatas, v)
  end
end
function SJiuXiaoRankRes:sizepolicy(size)
  return size <= 65535
end
return SJiuXiaoRankRes
