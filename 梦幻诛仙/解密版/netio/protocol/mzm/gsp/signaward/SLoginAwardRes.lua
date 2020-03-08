local SLoginAwardRes = class("SLoginAwardRes")
SLoginAwardRes.TYPEID = 12593410
function SLoginAwardRes:ctor(loginday, canAwardDays, awardedDays, item2num)
  self.id = 12593410
  self.loginday = loginday or nil
  self.canAwardDays = canAwardDays or {}
  self.awardedDays = awardedDays or {}
  self.item2num = item2num or {}
end
function SLoginAwardRes:marshal(os)
  os:marshalInt32(self.loginday)
  os:marshalCompactUInt32(table.getn(self.canAwardDays))
  for _, v in ipairs(self.canAwardDays) do
    os:marshalInt32(v)
  end
  os:marshalCompactUInt32(table.getn(self.awardedDays))
  for _, v in ipairs(self.awardedDays) do
    os:marshalInt32(v)
  end
  local _size_ = 0
  for _, _ in pairs(self.item2num) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.item2num) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SLoginAwardRes:unmarshal(os)
  self.loginday = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.canAwardDays, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.awardedDays, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.item2num[k] = v
  end
end
function SLoginAwardRes:sizepolicy(size)
  return size <= 65535
end
return SLoginAwardRes
