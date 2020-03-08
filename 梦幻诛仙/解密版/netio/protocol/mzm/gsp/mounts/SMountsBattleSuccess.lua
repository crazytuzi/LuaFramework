local SMountsBattleSuccess = class("SMountsBattleSuccess")
SMountsBattleSuccess.TYPEID = 12606223
function SMountsBattleSuccess:ctor(cell_id, mounts_id, battle_mounts_state)
  self.id = 12606223
  self.cell_id = cell_id or nil
  self.mounts_id = mounts_id or nil
  self.battle_mounts_state = battle_mounts_state or nil
end
function SMountsBattleSuccess:marshal(os)
  os:marshalInt32(self.cell_id)
  os:marshalInt64(self.mounts_id)
  os:marshalInt32(self.battle_mounts_state)
end
function SMountsBattleSuccess:unmarshal(os)
  self.cell_id = os:unmarshalInt32()
  self.mounts_id = os:unmarshalInt64()
  self.battle_mounts_state = os:unmarshalInt32()
end
function SMountsBattleSuccess:sizepolicy(size)
  return size <= 65535
end
return SMountsBattleSuccess
