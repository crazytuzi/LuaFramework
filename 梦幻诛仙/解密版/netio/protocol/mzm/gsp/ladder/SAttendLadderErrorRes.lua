local SAttendLadderErrorRes = class("SAttendLadderErrorRes")
SAttendLadderErrorRes.TYPEID = 12607249
SAttendLadderErrorRes.NOT_TEAM_LEADER = 1
SAttendLadderErrorRes.TEAM_CHANGED = 2
SAttendLadderErrorRes.MEMBER_NOT_NORMAL = 3
SAttendLadderErrorRes.NPC_SERVICE_UNUSERABLE = 4
SAttendLadderErrorRes.SEASON_NOT_START = 5
SAttendLadderErrorRes.NOT_IN_SAME_LEVEL_RANGE = 6
function SAttendLadderErrorRes:ctor(ret, args)
  self.id = 12607249
  self.ret = ret or nil
  self.args = args or {}
end
function SAttendLadderErrorRes:marshal(os)
  os:marshalInt32(self.ret)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SAttendLadderErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SAttendLadderErrorRes:sizepolicy(size)
  return size <= 65535
end
return SAttendLadderErrorRes
