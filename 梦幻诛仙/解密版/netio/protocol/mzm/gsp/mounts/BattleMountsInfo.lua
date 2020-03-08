local OctetsStream = require("netio.OctetsStream")
local BattleMountsInfo = class("BattleMountsInfo")
function BattleMountsInfo:ctor(mounts_id, is_chief_battle_mounts, protect_pet_id_list)
  self.mounts_id = mounts_id or nil
  self.is_chief_battle_mounts = is_chief_battle_mounts or nil
  self.protect_pet_id_list = protect_pet_id_list or {}
end
function BattleMountsInfo:marshal(os)
  os:marshalInt64(self.mounts_id)
  os:marshalInt32(self.is_chief_battle_mounts)
  os:marshalCompactUInt32(table.getn(self.protect_pet_id_list))
  for _, v in ipairs(self.protect_pet_id_list) do
    os:marshalInt64(v)
  end
end
function BattleMountsInfo:unmarshal(os)
  self.mounts_id = os:unmarshalInt64()
  self.is_chief_battle_mounts = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.protect_pet_id_list, v)
  end
end
return BattleMountsInfo
