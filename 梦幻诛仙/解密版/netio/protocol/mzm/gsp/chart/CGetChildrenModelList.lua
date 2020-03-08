local CGetChildrenModelList = class("CGetChildrenModelList")
CGetChildrenModelList.TYPEID = 12587796
function CGetChildrenModelList:ctor(idList, chartType)
  self.id = 12587796
  self.idList = idList or {}
  self.chartType = chartType or nil
end
function CGetChildrenModelList:marshal(os)
  os:marshalCompactUInt32(table.getn(self.idList))
  for _, v in ipairs(self.idList) do
    os:marshalInt64(v)
  end
  os:marshalInt32(self.chartType)
end
function CGetChildrenModelList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.idList, v)
  end
  self.chartType = os:unmarshalInt32()
end
function CGetChildrenModelList:sizepolicy(size)
  return size <= 65535
end
return CGetChildrenModelList
