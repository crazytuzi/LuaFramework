local CPetMarkDecomposeAllReq = class("CPetMarkDecomposeAllReq")
CPetMarkDecomposeAllReq.TYPEID = 12628483
function CPetMarkDecomposeAllReq:ctor(decompose_qualities, decompose_max_level)
  self.id = 12628483
  self.decompose_qualities = decompose_qualities or {}
  self.decompose_max_level = decompose_max_level or nil
end
function CPetMarkDecomposeAllReq:marshal(os)
  os:marshalCompactUInt32(table.getn(self.decompose_qualities))
  for _, v in ipairs(self.decompose_qualities) do
    os:marshalInt32(v)
  end
  os:marshalInt32(self.decompose_max_level)
end
function CPetMarkDecomposeAllReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.decompose_qualities, v)
  end
  self.decompose_max_level = os:unmarshalInt32()
end
function CPetMarkDecomposeAllReq:sizepolicy(size)
  return size <= 65535
end
return CPetMarkDecomposeAllReq
