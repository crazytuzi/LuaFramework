local SSyncMountsInfo = class("SSyncMountsInfo")
SSyncMountsInfo.TYPEID = 12606218
function SSyncMountsInfo:ctor(mounts_info_map, battle_mounts_info_map, current_ride_mounts)
  self.id = 12606218
  self.mounts_info_map = mounts_info_map or {}
  self.battle_mounts_info_map = battle_mounts_info_map or {}
  self.current_ride_mounts = current_ride_mounts or nil
end
function SSyncMountsInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.mounts_info_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.mounts_info_map) do
      os:marshalInt64(k)
      v:marshal(os)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.battle_mounts_info_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.battle_mounts_info_map) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalInt64(self.current_ride_mounts)
end
function SSyncMountsInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.mounts.MountsInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.mounts_info_map[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.mounts.BattleMountsInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.battle_mounts_info_map[k] = v
  end
  self.current_ride_mounts = os:unmarshalInt64()
end
function SSyncMountsInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncMountsInfo
