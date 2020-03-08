local SCrossCompeteNormalResult = class("SCrossCompeteNormalResult")
SCrossCompeteNormalResult.TYPEID = 12616721
SCrossCompeteNormalResult.SIGN_UP__NO_RIGHT = 1
SCrossCompeteNormalResult.SIGN_UP__LEVEL = 2
SCrossCompeteNormalResult.SIGN_UP__CREATE = 3
SCrossCompeteNormalResult.SIGN_UP__VITALITY = 4
SCrossCompeteNormalResult.SIGN_UP__QUALIFIED_MEMBER_COUNT = 5
SCrossCompeteNormalResult.SIGN_UP__COMBINE = 6
SCrossCompeteNormalResult.SIGN_UP__STAGE = 7
SCrossCompeteNormalResult.SIGN_UP__ALREADY = 8
SCrossCompeteNormalResult.ENTER_CROSS_COMPETE_MAP__NO_FACTION = 11
SCrossCompeteNormalResult.ENTER_CROSS_COMPETE_MAP__NOT_MATCH = 12
SCrossCompeteNormalResult.ENTER_CROSS_COMPETE_MAP__TEAM_TMP_LEAVE = 13
SCrossCompeteNormalResult.ENTER_CROSS_COMPETE_MAP__NOT_ALL_NORMAL = 14
SCrossCompeteNormalResult.ENTER_CROSS_COMPETE_MAP__DIFF_FACTION = 15
SCrossCompeteNormalResult.ENTER_CROSS_COMPETE_MAP__TEAM_STATUS = 16
SCrossCompeteNormalResult.ENTER_CROSS_COMPETE_MAP__SELF_NOT_NORMAL_MEMBER = 17
SCrossCompeteNormalResult.ENTER_CROSS_COMPETE_MAP__TEAM_NOT_NORMAL_MEMBER = 18
SCrossCompeteNormalResult.ENTER_CROSS_COMPETE_MAP__SELF_JUST_JOIN = 19
SCrossCompeteNormalResult.ENTER_CROSS_COMPETE_MAP__TEAM_JUST_JOIN = 20
SCrossCompeteNormalResult.ENTER_CROSS_COMPETE_MAP__NOT_ACTIVITY_TIME = 21
SCrossCompeteNormalResult.ENTER_CROSS_COMPETE_MAP__END = 22
SCrossCompeteNormalResult.ENTER_CROSS_COMPETE_MAP__NO_ENTER = 23
SCrossCompeteNormalResult.ENTER_CROSS_COMPETE_MAP__CONNECT_ROAM = 24
SCrossCompeteNormalResult.ENTER_CROSS_COMPETE_MAP__SELF_LEVEL = 25
SCrossCompeteNormalResult.ENTER_CROSS_COMPETE_MAP__MEMBER_LEVEL = 26
SCrossCompeteNormalResult.ATTACK__SELF_LACK_ACTION_POINT = 31
SCrossCompeteNormalResult.ATTACK__OHTER_LACK_ACTION_POINT = 32
SCrossCompeteNormalResult.ATTACK__FRIEND_PROTECTED = 33
SCrossCompeteNormalResult.ATTACK__ENEMY_PROTECTED = 34
SCrossCompeteNormalResult.ATTACK__FRIEND_IN_FIGHT = 35
SCrossCompeteNormalResult.ATTACK__ENEMY_IN_FIGHT = 36
SCrossCompeteNormalResult.LEAVE_CROSS_COMPETE_MAP__NO_ACTION_POINT = 41
SCrossCompeteNormalResult.LEAVE_CROSS_COMPETE_MAP__IN_TEAM = 42
SCrossCompeteNormalResult.LEAVE_CROSS_COMPETE_MAP__NOT_LEADER = 43
SCrossCompeteNormalResult.LEAVE_CROSS_COMPETE_MAP__NOT_ALL_NORMAL = 44
function SCrossCompeteNormalResult:ctor(result, args)
  self.id = 12616721
  self.result = result or nil
  self.args = args or {}
end
function SCrossCompeteNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SCrossCompeteNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SCrossCompeteNormalResult:sizepolicy(size)
  return size <= 65535
end
return SCrossCompeteNormalResult
