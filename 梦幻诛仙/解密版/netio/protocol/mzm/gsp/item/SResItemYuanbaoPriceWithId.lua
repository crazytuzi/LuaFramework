local SResItemYuanbaoPriceWithId = class("SResItemYuanbaoPriceWithId")
SResItemYuanbaoPriceWithId.TYPEID = 12584771
function SResItemYuanbaoPriceWithId:ctor(uid, itemid2yuanbao)
  self.id = 12584771
  self.uid = uid or nil
  self.itemid2yuanbao = itemid2yuanbao or {}
end
function SResItemYuanbaoPriceWithId:marshal(os)
  os:marshalInt32(self.uid)
  local _size_ = 0
  for _, _ in pairs(self.itemid2yuanbao) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.itemid2yuanbao) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SResItemYuanbaoPriceWithId:unmarshal(os)
  self.uid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.itemid2yuanbao[k] = v
  end
end
function SResItemYuanbaoPriceWithId:sizepolicy(size)
  return size <= 65535
end
return SResItemYuanbaoPriceWithId
