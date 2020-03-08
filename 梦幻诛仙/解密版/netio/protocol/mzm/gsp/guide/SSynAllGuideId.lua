local SSynAllGuideId = class("SSynAllGuideId")
SSynAllGuideId.TYPEID = 12594945
function SSynAllGuideId:ctor(guideids)
  self.id = 12594945
  self.guideids = guideids or {}
end
function SSynAllGuideId:marshal(os)
  os:marshalCompactUInt32(table.getn(self.guideids))
  for _, v in ipairs(self.guideids) do
    os:marshalInt32(v)
  end
end
function SSynAllGuideId:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.guideids, v)
  end
end
function SSynAllGuideId:sizepolicy(size)
  return size <= 65535
end
return SSynAllGuideId
