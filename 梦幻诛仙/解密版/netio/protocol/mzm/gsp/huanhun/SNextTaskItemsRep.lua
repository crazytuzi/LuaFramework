local SNextTaskItemsRep = class("SNextTaskItemsRep")
SNextTaskItemsRep.TYPEID = 12584455
function SNextTaskItemsRep:ctor(itemIds)
  self.id = 12584455
  self.itemIds = itemIds or {}
end
function SNextTaskItemsRep:marshal(os)
  os:marshalCompactUInt32(table.getn(self.itemIds))
  for _, v in ipairs(self.itemIds) do
    os:marshalInt32(v)
  end
end
function SNextTaskItemsRep:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.itemIds, v)
  end
end
function SNextTaskItemsRep:sizepolicy(size)
  return size <= 65535
end
return SNextTaskItemsRep
