local SRefreshGongXunRes = class("SRefreshGongXunRes")
SRefreshGongXunRes.TYPEID = 12589961
function SRefreshGongXunRes:ctor(roleid2gongxun)
  self.id = 12589961
  self.roleid2gongxun = roleid2gongxun or {}
end
function SRefreshGongXunRes:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.roleid2gongxun) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.roleid2gongxun) do
    os:marshalInt64(k)
    os:marshalInt32(v)
  end
end
function SRefreshGongXunRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.roleid2gongxun[k] = v
  end
end
function SRefreshGongXunRes:sizepolicy(size)
  return size <= 65535
end
return SRefreshGongXunRes
