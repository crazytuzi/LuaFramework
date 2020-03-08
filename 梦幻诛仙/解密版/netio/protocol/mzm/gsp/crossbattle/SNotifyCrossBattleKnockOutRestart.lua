local SNotifyCrossBattleKnockOutRestart = class("SNotifyCrossBattleKnockOutRestart")
SNotifyCrossBattleKnockOutRestart.TYPEID = 12617081
function SNotifyCrossBattleKnockOutRestart:ctor(fight_type, prepare_world_begin_time, prepare_world_end_time)
  self.id = 12617081
  self.fight_type = fight_type or nil
  self.prepare_world_begin_time = prepare_world_begin_time or nil
  self.prepare_world_end_time = prepare_world_end_time or nil
end
function SNotifyCrossBattleKnockOutRestart:marshal(os)
  os:marshalInt32(self.fight_type)
  os:marshalInt64(self.prepare_world_begin_time)
  os:marshalInt64(self.prepare_world_end_time)
end
function SNotifyCrossBattleKnockOutRestart:unmarshal(os)
  self.fight_type = os:unmarshalInt32()
  self.prepare_world_begin_time = os:unmarshalInt64()
  self.prepare_world_end_time = os:unmarshalInt64()
end
function SNotifyCrossBattleKnockOutRestart:sizepolicy(size)
  return size <= 65535
end
return SNotifyCrossBattleKnockOutRestart
