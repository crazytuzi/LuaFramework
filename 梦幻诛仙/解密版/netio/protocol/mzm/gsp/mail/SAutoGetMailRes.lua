local SAutoGetMailRes = class("SAutoGetMailRes")
SAutoGetMailRes.TYPEID = 12592897
function SAutoGetMailRes:ctor(mailIndexs)
  self.id = 12592897
  self.mailIndexs = mailIndexs or {}
end
function SAutoGetMailRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.mailIndexs))
  for _, v in ipairs(self.mailIndexs) do
    os:marshalInt32(v)
  end
end
function SAutoGetMailRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.mailIndexs, v)
  end
end
function SAutoGetMailRes:sizepolicy(size)
  return size <= 65535
end
return SAutoGetMailRes
