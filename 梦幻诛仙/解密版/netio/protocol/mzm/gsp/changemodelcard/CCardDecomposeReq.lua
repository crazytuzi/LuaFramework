local CCardDecomposeReq = class("CCardDecomposeReq")
CCardDecomposeReq.TYPEID = 12624413
function CCardDecomposeReq:ctor(card_ids)
  self.id = 12624413
  self.card_ids = card_ids or {}
end
function CCardDecomposeReq:marshal(os)
  os:marshalCompactUInt32(table.getn(self.card_ids))
  for _, v in ipairs(self.card_ids) do
    os:marshalInt64(v)
  end
end
function CCardDecomposeReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.card_ids, v)
  end
end
function CCardDecomposeReq:sizepolicy(size)
  return size <= 65535
end
return CCardDecomposeReq
