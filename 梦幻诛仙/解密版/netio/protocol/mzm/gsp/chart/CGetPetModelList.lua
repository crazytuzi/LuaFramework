local CGetPetModelList = class("CGetPetModelList")
CGetPetModelList.TYPEID = 12587791
function CGetPetModelList:ctor(idList, chartType)
  self.id = 12587791
  self.idList = idList or {}
  self.chartType = chartType or nil
end
function CGetPetModelList:marshal(os)
  os:marshalCompactUInt32(table.getn(self.idList))
  for _, v in ipairs(self.idList) do
    v:marshal(os)
  end
  os:marshalInt32(self.chartType)
end
function CGetPetModelList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.chart.PetOwner")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.idList, v)
  end
  self.chartType = os:unmarshalInt32()
end
function CGetPetModelList:sizepolicy(size)
  return size <= 65535
end
return CGetPetModelList
