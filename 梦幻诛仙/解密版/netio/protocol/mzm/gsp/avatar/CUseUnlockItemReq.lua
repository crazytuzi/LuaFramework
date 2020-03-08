local CUseUnlockItemReq = class("CUseUnlockItemReq")
CUseUnlockItemReq.TYPEID = 12615178
function CUseUnlockItemReq:ctor(item_keys)
  self.id = 12615178
  self.item_keys = item_keys or {}
end
function CUseUnlockItemReq:marshal(os)
  os:marshalCompactUInt32(table.getn(self.item_keys))
  for _, v in ipairs(self.item_keys) do
    os:marshalInt32(v)
  end
end
function CUseUnlockItemReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.item_keys, v)
  end
end
function CUseUnlockItemReq:sizepolicy(size)
  return size <= 65535
end
return CUseUnlockItemReq
