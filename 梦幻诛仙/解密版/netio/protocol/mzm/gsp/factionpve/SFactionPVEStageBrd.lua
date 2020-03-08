local SFactionPVEStageBrd = class("SFactionPVEStageBrd")
SFactionPVEStageBrd.TYPEID = 12613636
SFactionPVEStageBrd.STG_BEFORE_START = 0
SFactionPVEStageBrd.STG_PREPARE = 1
SFactionPVEStageBrd.STG_KILL_MONSTER = 2
SFactionPVEStageBrd.STG_BOSS_COUNTDOWN = 3
SFactionPVEStageBrd.STG_KILL_BOSS = 4
SFactionPVEStageBrd.STG_FINISH_COUNTDOWN = 5
SFactionPVEStageBrd.STG_FINISHED = 6
function SFactionPVEStageBrd:ctor(stage, end_time)
  self.id = 12613636
  self.stage = stage or nil
  self.end_time = end_time or nil
end
function SFactionPVEStageBrd:marshal(os)
  os:marshalInt32(self.stage)
  os:marshalInt64(self.end_time)
end
function SFactionPVEStageBrd:unmarshal(os)
  self.stage = os:unmarshalInt32()
  self.end_time = os:unmarshalInt64()
end
function SFactionPVEStageBrd:sizepolicy(size)
  return size <= 65535
end
return SFactionPVEStageBrd
