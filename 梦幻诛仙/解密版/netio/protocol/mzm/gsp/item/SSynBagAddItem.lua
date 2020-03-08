local SSynBagAddItem = class("SSynBagAddItem")
SSynBagAddItem.TYPEID = 12584733
function SSynBagAddItem:ctor(grids, itemid, count)
  self.id = 12584733
  self.grids = grids or {}
  self.itemid = itemid or nil
  self.count = count or nil
end
function SSynBagAddItem:marshal(os)
  os:marshalCompactUInt32(table.getn(self.grids))
  for _, v in ipairs(self.grids) do
    os:marshalInt32(v)
  end
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.count)
end
function SSynBagAddItem:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.grids, v)
  end
  self.itemid = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
end
function SSynBagAddItem:sizepolicy(size)
  return size <= 65535
end
return SSynBagAddItem
