local CUnLockMagicMarkReq = class("CUnLockMagicMarkReq")
CUnLockMagicMarkReq.TYPEID = 12609550
function CUnLockMagicMarkReq:ctor(magicMarkItems)
  self.id = 12609550
  self.magicMarkItems = magicMarkItems or {}
end
function CUnLockMagicMarkReq:marshal(os)
  os:marshalCompactUInt32(table.getn(self.magicMarkItems))
  for _, v in ipairs(self.magicMarkItems) do
    os:marshalInt32(v)
  end
end
function CUnLockMagicMarkReq:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.magicMarkItems, v)
  end
end
function CUnLockMagicMarkReq:sizepolicy(size)
  return size <= 65535
end
return CUnLockMagicMarkReq
