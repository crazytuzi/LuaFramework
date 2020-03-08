local SSyncFashionDressInfo = class("SSyncFashionDressInfo")
SSyncFashionDressInfo.TYPEID = 12603145
function SSyncFashionDressInfo:ctor(currentFashionDressCfgId, fashionDressInfoMap, activatePropertyList)
  self.id = 12603145
  self.currentFashionDressCfgId = currentFashionDressCfgId or nil
  self.fashionDressInfoMap = fashionDressInfoMap or {}
  self.activatePropertyList = activatePropertyList or {}
end
function SSyncFashionDressInfo:marshal(os)
  os:marshalInt32(self.currentFashionDressCfgId)
  do
    local _size_ = 0
    for _, _ in pairs(self.fashionDressInfoMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.fashionDressInfoMap) do
      os:marshalInt32(k)
      os:marshalInt64(v)
    end
  end
  os:marshalCompactUInt32(table.getn(self.activatePropertyList))
  for _, v in ipairs(self.activatePropertyList) do
    os:marshalInt32(v)
  end
end
function SSyncFashionDressInfo:unmarshal(os)
  self.currentFashionDressCfgId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.fashionDressInfoMap[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.activatePropertyList, v)
  end
end
function SSyncFashionDressInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncFashionDressInfo
