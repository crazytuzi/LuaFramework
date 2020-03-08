local SSiftItemRes = class("SSiftItemRes")
SSiftItemRes.TYPEID = 12584735
function SSiftItemRes:ctor(siftCfgid, itemList)
  self.id = 12584735
  self.siftCfgid = siftCfgid or nil
  self.itemList = itemList or {}
end
function SSiftItemRes:marshal(os)
  os:marshalInt32(self.siftCfgid)
  os:marshalCompactUInt32(table.getn(self.itemList))
  for _, v in ipairs(self.itemList) do
    os:marshalInt32(v)
  end
end
function SSiftItemRes:unmarshal(os)
  self.siftCfgid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.itemList, v)
  end
end
function SSiftItemRes:sizepolicy(size)
  return size <= 65535
end
return SSiftItemRes
