local SCompetitionNormalResult = class("SCompetitionNormalResult")
SCompetitionNormalResult.TYPEID = 12598532
SCompetitionNormalResult.ENTER_COMPETITION_MAP__SELF_NO_ACTION_POINT = 1
SCompetitionNormalResult.ENTER_COMPETITION_MAP__OTHER_NO_ACTION_POINT = 2
SCompetitionNormalResult.ENTER_COMPETITION_MAP__SELF_PARTICIPATED = 3
SCompetitionNormalResult.ENTER_COMPETITION_MAP__OTHER_PARTICIPATED = 4
SCompetitionNormalResult.ENTER_COMPETITION_MAP__DIFF_FACTION = 5
SCompetitionNormalResult.ENTER_COMPETITION_MAP__TEAM_STATUS = 6
SCompetitionNormalResult.ENTER_COMPETITION_MAP__SELF_NOT_NORMAL_MEMBER = 7
SCompetitionNormalResult.ENTER_COMPETITION_MAP__TEAM_NOT_NORMAL_MEMBER = 8
SCompetitionNormalResult.ENTER_COMPETITION_MAP__SELF_JUST_JOIN = 9
SCompetitionNormalResult.ENTER_COMPETITION_MAP__TEAM_JUST_JOIN = 10
SCompetitionNormalResult.ENTER_COMPETITION_MAP__NOT_ACTIVITY_TIME = 11
SCompetitionNormalResult.ENTER_COMPETITION_MAP__END = 12
SCompetitionNormalResult.ENTER_COMPETITION_MAP__NO_ENTER = 13
SCompetitionNormalResult.ATTACK__SELF_LACK_ACTION_POINT = 21
SCompetitionNormalResult.ATTACK__OHTER_LACK_ACTION_POINT = 22
SCompetitionNormalResult.ATTACK__FRIEND_PROTECTED = 23
SCompetitionNormalResult.ATTACK__ENEMY_PROTECTED = 24
SCompetitionNormalResult.ATTACK__FRIEND_IN_FIGHT = 25
SCompetitionNormalResult.ATTACK__ENEMY_IN_FIGHT = 26
SCompetitionNormalResult.LEAVE_COMPETITION_MAP__NO_ACTION_POINT = 31
SCompetitionNormalResult.LEAVE_COMPETITION_MAP__IN_TEAM = 32
function SCompetitionNormalResult:ctor(result, args)
  self.id = 12598532
  self.result = result or nil
  self.args = args or {}
end
function SCompetitionNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SCompetitionNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SCompetitionNormalResult:sizepolicy(size)
  return size <= 65535
end
return SCompetitionNormalResult
