local SChildrenChartRes = class("SChildrenChartRes")
SChildrenChartRes.TYPEID = 12609433
function SChildrenChartRes:ctor(rank_list, my_rank, my_rating)
  self.id = 12609433
  self.rank_list = rank_list or {}
  self.my_rank = my_rank or nil
  self.my_rating = my_rating or nil
end
function SChildrenChartRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.rank_list))
  for _, v in ipairs(self.rank_list) do
    v:marshal(os)
  end
  os:marshalInt32(self.my_rank)
  os:marshalInt32(self.my_rating)
end
function SChildrenChartRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.children.ChildrenChartData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rank_list, v)
  end
  self.my_rank = os:unmarshalInt32()
  self.my_rating = os:unmarshalInt32()
end
function SChildrenChartRes:sizepolicy(size)
  return size <= 65535
end
return SChildrenChartRes
