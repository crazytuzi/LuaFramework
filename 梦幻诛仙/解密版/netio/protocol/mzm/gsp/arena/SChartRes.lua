local SChartRes = class("SChartRes")
SChartRes.TYPEID = 12596744
function SChartRes:ctor(page, data_list)
  self.id = 12596744
  self.page = page or nil
  self.data_list = data_list or {}
end
function SChartRes:marshal(os)
  os:marshalInt32(self.page)
  os:marshalCompactUInt32(table.getn(self.data_list))
  for _, v in ipairs(self.data_list) do
    v:marshal(os)
  end
end
function SChartRes:unmarshal(os)
  self.page = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.arena.Score")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.data_list, v)
  end
end
function SChartRes:sizepolicy(size)
  return size <= 65535
end
return SChartRes
