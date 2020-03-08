local SGetWatchCountRes = class("SGetWatchCountRes")
SGetWatchCountRes.TYPEID = 12600836
function SGetWatchCountRes:ctor(roleid2state)
  self.id = 12600836
  self.roleid2state = roleid2state or {}
end
function SGetWatchCountRes:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.roleid2state) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.roleid2state) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function SGetWatchCountRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.watchmoon.WatchmoonState")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.roleid2state[k] = v
  end
end
function SGetWatchCountRes:sizepolicy(size)
  return size <= 65535
end
return SGetWatchCountRes
