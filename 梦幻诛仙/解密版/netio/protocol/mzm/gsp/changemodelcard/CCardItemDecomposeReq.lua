local CCardItemDecomposeReq = class("CCardItemDecomposeReq")
CCardItemDecomposeReq.TYPEID = 12624396
function CCardItemDecomposeReq:ctor(item_uuids, decompose_one)
  self.id = 12624396
  self.item_uuids = item_uuids or {}
  self.decompose_one = decompose_one or nil
end
function CCardItemDecomposeReq:marshal(os)
  os:marshalCompactUInt32(table.getn(self.item_uuids))
  for _, v in ipairs(self.item_uuids) do
    os:marshalInt64(v)
  end
  os:marshalUInt8(self.decompose_one)
end
function CCardItemDecomposeReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.item_uuids, v)
  end
  self.decompose_one = os:unmarshalUInt8()
end
function CCardItemDecomposeReq:sizepolicy(size)
  return size <= 65535
end
return CCardItemDecomposeReq
