local SLadderReadyErrorRes = class("SLadderReadyErrorRes")
SLadderReadyErrorRes.TYPEID = 12607236
SLadderReadyErrorRes.NOT_IN_SAME_LEVEL_STAGE_WITH_LEADER = 1
SLadderReadyErrorRes.NOT_IN_SAME_LEVEL_STAGE_WITH_MEMBER = 2
SLadderReadyErrorRes.NOT_IN_TEAM = 3
SLadderReadyErrorRes.NOW_IN_MATCH_STAGE = 4
SLadderReadyErrorRes.NOW_IN_READY_STAGE = 5
SLadderReadyErrorRes.TEAM_MEMBER_CHANGED = 6
SLadderReadyErrorRes.SEASON_NOT_START = 7
SLadderReadyErrorRes.NOT_IN_SAME_LEVEL_RANGE = 8
function SLadderReadyErrorRes:ctor(ret, args)
  self.id = 12607236
  self.ret = ret or nil
  self.args = args or {}
end
function SLadderReadyErrorRes:marshal(os)
  os:marshalInt32(self.ret)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SLadderReadyErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SLadderReadyErrorRes:sizepolicy(size)
  return size <= 65535
end
return SLadderReadyErrorRes
