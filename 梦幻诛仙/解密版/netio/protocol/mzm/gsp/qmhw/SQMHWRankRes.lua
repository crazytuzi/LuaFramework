local SQMHWRankRes = class("SQMHWRankRes")
SQMHWRankRes.TYPEID = 12601866
function SQMHWRankRes:ctor(rankDatas)
  self.id = 12601866
  self.rankDatas = rankDatas or {}
end
function SQMHWRankRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.rankDatas))
  for _, v in ipairs(self.rankDatas) do
    v:marshal(os)
  end
end
function SQMHWRankRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.qmhw.QMHWRankRoleData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rankDatas, v)
  end
end
function SQMHWRankRes:sizepolicy(size)
  return size <= 65535
end
return SQMHWRankRes
