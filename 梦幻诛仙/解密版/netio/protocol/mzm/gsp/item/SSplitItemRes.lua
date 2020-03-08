local SSplitItemRes = class("SSplitItemRes")
SSplitItemRes.TYPEID = 12584879
function SSplitItemRes:ctor(item_uuid, split_num, acquired_items)
  self.id = 12584879
  self.item_uuid = item_uuid or nil
  self.split_num = split_num or nil
  self.acquired_items = acquired_items or {}
end
function SSplitItemRes:marshal(os)
  os:marshalInt64(self.item_uuid)
  os:marshalInt32(self.split_num)
  local _size_ = 0
  for _, _ in pairs(self.acquired_items) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.acquired_items) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSplitItemRes:unmarshal(os)
  self.item_uuid = os:unmarshalInt64()
  self.split_num = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.acquired_items[k] = v
  end
end
function SSplitItemRes:sizepolicy(size)
  return size <= 65535
end
return SSplitItemRes
