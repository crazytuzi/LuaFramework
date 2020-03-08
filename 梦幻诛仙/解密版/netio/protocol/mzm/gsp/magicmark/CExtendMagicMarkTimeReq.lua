local CExtendMagicMarkTimeReq = class("CExtendMagicMarkTimeReq")
CExtendMagicMarkTimeReq.TYPEID = 12609543
function CExtendMagicMarkTimeReq:ctor(magicMarkItems)
  self.id = 12609543
  self.magicMarkItems = magicMarkItems or {}
end
function CExtendMagicMarkTimeReq:marshal(os)
  os:marshalCompactUInt32(table.getn(self.magicMarkItems))
  for _, v in ipairs(self.magicMarkItems) do
    os:marshalInt32(v)
  end
end
function CExtendMagicMarkTimeReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.magicMarkItems, v)
  end
end
function CExtendMagicMarkTimeReq:sizepolicy(size)
  return size <= 65535
end
return CExtendMagicMarkTimeReq
