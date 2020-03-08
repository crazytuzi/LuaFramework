local SAutoDeleteMailRes = class("SAutoDeleteMailRes")
SAutoDeleteMailRes.TYPEID = 12592901
function SAutoDeleteMailRes:ctor(mailIndexs)
  self.id = 12592901
  self.mailIndexs = mailIndexs or {}
end
function SAutoDeleteMailRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.mailIndexs))
  for _, v in ipairs(self.mailIndexs) do
    os:marshalInt32(v)
  end
end
function SAutoDeleteMailRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.mailIndexs, v)
  end
end
function SAutoDeleteMailRes:sizepolicy(size)
  return size <= 65535
end
return SAutoDeleteMailRes
