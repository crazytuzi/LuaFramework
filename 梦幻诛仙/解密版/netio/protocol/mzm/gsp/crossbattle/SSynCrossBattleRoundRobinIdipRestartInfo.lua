local SSynCrossBattleRoundRobinIdipRestartInfo = class("SSynCrossBattleRoundRobinIdipRestartInfo")
SSynCrossBattleRoundRobinIdipRestartInfo.TYPEID = 12617028
function SSynCrossBattleRoundRobinIdipRestartInfo:ctor(activity_cfg_id, round_index, timestamp)
  self.id = 12617028
  self.activity_cfg_id = activity_cfg_id or nil
  self.round_index = round_index or nil
  self.timestamp = timestamp or nil
end
function SSynCrossBattleRoundRobinIdipRestartInfo:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.round_index)
  os:marshalInt32(self.timestamp)
end
function SSynCrossBattleRoundRobinIdipRestartInfo:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.round_index = os:unmarshalInt32()
  self.timestamp = os:unmarshalInt32()
end
function SSynCrossBattleRoundRobinIdipRestartInfo:sizepolicy(size)
  return size <= 65535
end
return SSynCrossBattleRoundRobinIdipRestartInfo
