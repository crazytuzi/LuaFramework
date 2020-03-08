local CReqItemAccessWay = class("CReqItemAccessWay")
CReqItemAccessWay.TYPEID = 12584723
function CReqItemAccessWay:ctor(itemIdList)
  self.id = 12584723
  self.itemIdList = itemIdList or {}
end
function CReqItemAccessWay:marshal(os)
  os:marshalCompactUInt32(table.getn(self.itemIdList))
  for _, v in ipairs(self.itemIdList) do
    os:marshalInt32(v)
  end
end
function CReqItemAccessWay:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.itemIdList, v)
  end
end
function CReqItemAccessWay:sizepolicy(size)
  return size <= 65535
end
return CReqItemAccessWay
