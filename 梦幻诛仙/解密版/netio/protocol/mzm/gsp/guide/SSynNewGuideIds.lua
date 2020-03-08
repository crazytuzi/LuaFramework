local SSynNewGuideIds = class("SSynNewGuideIds")
SSynNewGuideIds.TYPEID = 12594946
function SSynNewGuideIds:ctor(guideids)
  self.id = 12594946
  self.guideids = guideids or {}
end
function SSynNewGuideIds:marshal(os)
  os:marshalCompactUInt32(table.getn(self.guideids))
  for _, v in ipairs(self.guideids) do
    os:marshalInt32(v)
  end
end
function SSynNewGuideIds:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.guideids, v)
  end
end
function SSynNewGuideIds:sizepolicy(size)
  return size <= 65535
end
return SSynNewGuideIds
