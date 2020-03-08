local SMapCommonResult = class("SMapCommonResult")
SMapCommonResult.TYPEID = 12590850
SMapCommonResult.NOT_MY_FIGHT = 0
SMapCommonResult.MONSTER_FIGHT_SUCCESS = 1
SMapCommonResult.MONSTER_IN_FIGHT = 2
SMapCommonResult.TEAM_LEADER_MUST_GANG_MEMBER = 3
SMapCommonResult.TEAM_MEMBER_MUST_THREE_GANG_MEMBER = 4
SMapCommonResult.CAN_NOT_FIGHT_MONSTER = 5
SMapCommonResult.COMPETITION_MERCENARY_NOT_TIME = 7
SMapCommonResult.COMPETITION_MERCENARY_SELF = 8
SMapCommonResult.COMPETITION_MERCENARY_DISRELATED = 9
SMapCommonResult.COMPETITION_MERCENARY_FINISHED = 10
SMapCommonResult.FACTION_PVE_NOT_TIME = 11
SMapCommonResult.FACTION_PVE_DISRELATED = 12
SMapCommonResult.GATHER_SUCCESS = 101
SMapCommonResult.MAPITEM_ALREADY_GATHERED = 102
SMapCommonResult.BAG_FULL = 103
SMapCommonResult.ERROR_DAILY_GATHER_TIMES_LIMIT = 104
SMapCommonResult.ERROR_GATHER_INTERVAL = 105
SMapCommonResult.DISTANCE_NOT_MATCH = 201
SMapCommonResult.CAN_NOT_TRANSFER = 211
function SMapCommonResult:ctor(result)
  self.id = 12590850
  self.result = result or nil
end
function SMapCommonResult:marshal(os)
  os:marshalInt32(self.result)
end
function SMapCommonResult:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SMapCommonResult:sizepolicy(size)
  return size <= 65535
end
return SMapCommonResult
