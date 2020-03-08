local CMountsSetBattleState = class("CMountsSetBattleState")
CMountsSetBattleState.TYPEID = 12606212
function CMountsSetBattleState:ctor(cell_id, battle_mounts_state)
  self.id = 12606212
  self.cell_id = cell_id or nil
  self.battle_mounts_state = battle_mounts_state or nil
end
function CMountsSetBattleState:marshal(os)
  os:marshalInt32(self.cell_id)
  os:marshalInt32(self.battle_mounts_state)
end
function CMountsSetBattleState:unmarshal(os)
  self.cell_id = os:unmarshalInt32()
  self.battle_mounts_state = os:unmarshalInt32()
end
function CMountsSetBattleState:sizepolicy(size)
  return size <= 65535
end
return CMountsSetBattleState
