local OctetsStream = require("netio.OctetsStream")
local FightTeam = require("netio.protocol.mzm.gsp.fight.FightTeam")
local Fight = class("Fight")
Fight.TYPE_PVE = 0
Fight.TYPE_PVP = 1
Fight.TYPE_PVC = 2
Fight.TYPE_PVIMonster = 3
Fight.TYPE_PETCVC = 4
function Fight:ctor(fight_type, fight_uuid, fight_cfg_id, fight_dis_type, active_team, passive_team, round, operEndTime, observers)
  self.fight_type = fight_type or nil
  self.fight_uuid = fight_uuid or nil
  self.fight_cfg_id = fight_cfg_id or nil
  self.fight_dis_type = fight_dis_type or nil
  self.active_team = active_team or FightTeam.new()
  self.passive_team = passive_team or FightTeam.new()
  self.round = round or nil
  self.operEndTime = operEndTime or nil
  self.observers = observers or {}
end
function Fight:marshal(os)
  os:marshalInt32(self.fight_type)
  os:marshalInt64(self.fight_uuid)
  os:marshalInt32(self.fight_cfg_id)
  os:marshalInt32(self.fight_dis_type)
  self.active_team:marshal(os)
  self.passive_team:marshal(os)
  os:marshalInt32(self.round)
  os:marshalInt64(self.operEndTime)
  os:marshalCompactUInt32(table.getn(self.observers))
  for _, v in ipairs(self.observers) do
    v:marshal(os)
  end
end
function Fight:unmarshal(os)
  self.fight_type = os:unmarshalInt32()
  self.fight_uuid = os:unmarshalInt64()
  self.fight_cfg_id = os:unmarshalInt32()
  self.fight_dis_type = os:unmarshalInt32()
  self.active_team = FightTeam.new()
  self.active_team:unmarshal(os)
  self.passive_team = FightTeam.new()
  self.passive_team:unmarshal(os)
  self.round = os:unmarshalInt32()
  self.operEndTime = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.Observer")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.observers, v)
  end
end
return Fight
