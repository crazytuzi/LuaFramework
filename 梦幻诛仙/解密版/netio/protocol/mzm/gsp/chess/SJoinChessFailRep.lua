local SJoinChessFailRep = class("SJoinChessFailRep")
SJoinChessFailRep.TYPEID = 12619024
SJoinChessFailRep.MEMBER_COUNT_ERROR = -1
SJoinChessFailRep.MEMBER_LEVEL_NOT_ENOUGH = -2
SJoinChessFailRep.ACTIVITY_CLOSED = -3
SJoinChessFailRep.NPC_SERVICE_NOT_AVAILABLE = -4
SJoinChessFailRep.NOT_NEARBY_NPC = -5
SJoinChessFailRep.TEAM_NOT_EXIST = -6
SJoinChessFailRep.IS_NOT_LEADER = -7
SJoinChessFailRep.TEAM_MEMBER_STATE_ERROR = -8
SJoinChessFailRep.TEAM_CHANGED = -9
SJoinChessFailRep.TEAM_MEMBER_AlREADY_IN_GAME = -10
function SJoinChessFailRep:ctor(error_code, params)
  self.id = 12619024
  self.error_code = error_code or nil
  self.params = params or {}
end
function SJoinChessFailRep:marshal(os)
  os:marshalInt32(self.error_code)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalString(v)
  end
end
function SJoinChessFailRep:unmarshal(os)
  self.error_code = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.params, v)
  end
end
function SJoinChessFailRep:sizepolicy(size)
  return size <= 65535
end
return SJoinChessFailRep
