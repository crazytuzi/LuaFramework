local SMountsSetBattleStateSuccess = class("SMountsSetBattleStateSuccess")
SMountsSetBattleStateSuccess.TYPEID = 12606215
function SMountsSetBattleStateSuccess:ctor(battle_mounts_info_map)
  self.id = 12606215
  self.battle_mounts_info_map = battle_mounts_info_map or {}
end
function SMountsSetBattleStateSuccess:marshal(os)
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
function SMountsSetBattleStateSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.mounts.BattleMountsInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.battle_mounts_info_map[k] = v
  end
end
function SMountsSetBattleStateSuccess:sizepolicy(size)
  return size <= 65535
end
return SMountsSetBattleStateSuccess
