local SGatherItemAppearanceBro = class("SGatherItemAppearanceBro")
SGatherItemAppearanceBro.TYPEID = 12621595
function SGatherItemAppearanceBro:ctor(areaIds)
  self.id = 12621595
  self.areaIds = areaIds or {}
end
function SGatherItemAppearanceBro:marshal(os)
  os:marshalCompactUInt32(table.getn(self.areaIds))
  for _, v in ipairs(self.areaIds) do
    os:marshalInt32(v)
  end
end
function SGatherItemAppearanceBro:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.areaIds, v)
  end
end
function SGatherItemAppearanceBro:sizepolicy(size)
  return size <= 65535
end
return SGatherItemAppearanceBro
