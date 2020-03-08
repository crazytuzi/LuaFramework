local SGetChartSuccess = class("SGetChartSuccess")
SGetChartSuccess.TYPEID = 12628241
function SGetChartSuccess:ctor(my_rank, my_point, rank_datas)
  self.id = 12628241
  self.my_rank = my_rank or nil
  self.my_point = my_point or nil
  self.rank_datas = rank_datas or {}
end
function SGetChartSuccess:marshal(os)
  os:marshalInt32(self.my_rank)
  os:marshalInt32(self.my_point)
  os:marshalCompactUInt32(table.getn(self.rank_datas))
  for _, v in ipairs(self.rank_datas) do
    v:marshal(os)
  end
end
function SGetChartSuccess:unmarshal(os)
  self.my_rank = os:unmarshalInt32()
  self.my_point = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.petarena.PetArenaChartData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rank_datas, v)
  end
end
function SGetChartSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetChartSuccess
