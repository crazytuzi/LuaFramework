local SLadderMatchErrorRes = class("SLadderMatchErrorRes")
SLadderMatchErrorRes.TYPEID = 12607237
SLadderMatchErrorRes.NOT_TEAM_LEADER = 1
SLadderMatchErrorRes.TEAM_MEMBER_NOT_ENOUGH = 2
SLadderMatchErrorRes.TEAM_MEMBER_CHANGED = 3
SLadderMatchErrorRes.TEAM_MEMBER_NOT_IN_NORMAL = 4
SLadderMatchErrorRes.TEAM_MEMBER_NOT_IN_SAME_LEVEL_STAGE = 5
SLadderMatchErrorRes.TEAM_MEMBER_NOT_READY = 6
SLadderMatchErrorRes.UN_KNOWM_ERROR = 7
SLadderMatchErrorRes.SEASON_NOT_START = 8
SLadderMatchErrorRes.NOT_IN_SAME_LEVEL_RANGE = 9
function SLadderMatchErrorRes:ctor(ret, args)
  self.id = 12607237
  self.ret = ret or nil
  self.args = args or {}
end
function SLadderMatchErrorRes:marshal(os)
  os:marshalInt32(self.ret)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SLadderMatchErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SLadderMatchErrorRes:sizepolicy(size)
  return size <= 65535
end
return SLadderMatchErrorRes
