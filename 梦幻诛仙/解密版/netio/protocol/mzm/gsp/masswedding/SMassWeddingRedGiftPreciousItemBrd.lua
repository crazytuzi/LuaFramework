local SMassWeddingRedGiftPreciousItemBrd = class("SMassWeddingRedGiftPreciousItemBrd")
SMassWeddingRedGiftPreciousItemBrd.TYPEID = 12604966
function SMassWeddingRedGiftPreciousItemBrd:ctor(roleName, item2Num)
  self.id = 12604966
  self.roleName = roleName or nil
  self.item2Num = item2Num or {}
end
function SMassWeddingRedGiftPreciousItemBrd:marshal(os)
  os:marshalString(self.roleName)
  local _size_ = 0
  for _, _ in pairs(self.item2Num) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.item2Num) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SMassWeddingRedGiftPreciousItemBrd:unmarshal(os)
  self.roleName = os:unmarshalString()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.item2Num[k] = v
  end
end
function SMassWeddingRedGiftPreciousItemBrd:sizepolicy(size)
  return size <= 65535
end
return SMassWeddingRedGiftPreciousItemBrd
