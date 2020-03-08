local SGetCrossFieldRankSuccess = class("SGetCrossFieldRankSuccess")
SGetCrossFieldRankSuccess.TYPEID = 12619531
function SGetCrossFieldRankSuccess:ctor(rank_type, rank_list)
  self.id = 12619531
  self.rank_type = rank_type or nil
  self.rank_list = rank_list or {}
end
function SGetCrossFieldRankSuccess:marshal(os)
  os:marshalInt32(self.rank_type)
  os:marshalCompactUInt32(table.getn(self.rank_list))
  for _, v in ipairs(self.rank_list) do
    v:marshal(os)
  end
end
function SGetCrossFieldRankSuccess:unmarshal(os)
  self.rank_type = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crossfield.CrossFieldRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rank_list, v)
  end
end
function SGetCrossFieldRankSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetCrossFieldRankSuccess
