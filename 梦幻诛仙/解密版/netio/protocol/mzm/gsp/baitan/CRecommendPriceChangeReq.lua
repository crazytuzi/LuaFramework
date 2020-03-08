local CRecommendPriceChangeReq = class("CRecommendPriceChangeReq")
CRecommendPriceChangeReq.TYPEID = 12584994
function CRecommendPriceChangeReq:ctor(itemIdList)
  self.id = 12584994
  self.itemIdList = itemIdList or {}
end
function CRecommendPriceChangeReq:marshal(os)
  os:marshalCompactUInt32(table.getn(self.itemIdList))
  for _, v in ipairs(self.itemIdList) do
    os:marshalInt32(v)
  end
end
function CRecommendPriceChangeReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.itemIdList, v)
  end
end
function CRecommendPriceChangeReq:sizepolicy(size)
  return size <= 65535
end
return CRecommendPriceChangeReq
