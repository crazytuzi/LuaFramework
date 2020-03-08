local STopModelListRes = class("STopModelListRes")
STopModelListRes.TYPEID = 12587795
function STopModelListRes:ctor(dataList, chartType)
  self.id = 12587795
  self.dataList = dataList or {}
  self.chartType = chartType or nil
end
function STopModelListRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.dataList))
  for _, v in ipairs(self.dataList) do
    v:marshal(os)
  end
  os:marshalInt32(self.chartType)
end
function STopModelListRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.dataList, v)
  end
  self.chartType = os:unmarshalInt32()
end
function STopModelListRes:sizepolicy(size)
  return size <= 65535
end
return STopModelListRes
