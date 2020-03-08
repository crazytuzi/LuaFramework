local SApplyJoinDrawAndGuessFailRep = class("SApplyJoinDrawAndGuessFailRep")
SApplyJoinDrawAndGuessFailRep.TYPEID = 12617232
SApplyJoinDrawAndGuessFailRep.ERROR_SYSTEM = -1
SApplyJoinDrawAndGuessFailRep.ERROR_USERID = -2
SApplyJoinDrawAndGuessFailRep.ERROR_CFG = -3
SApplyJoinDrawAndGuessFailRep.ERROR_PARAM = -4
SApplyJoinDrawAndGuessFailRep.ERROR_NPC_SERVER = -5
SApplyJoinDrawAndGuessFailRep.ERROR_MEMBER_IN_DRAW_AND_GUESS = -6
SApplyJoinDrawAndGuessFailRep.ERROR_TEAM_MEMBER_ERROR = -7
SApplyJoinDrawAndGuessFailRep.ERROR_CAN_NOT_JOIN_ACTIVITY = -8
SApplyJoinDrawAndGuessFailRep.ERROR_NO_TEAM = -9
SApplyJoinDrawAndGuessFailRep.ERROR_NOT_TEAM_LEADER = -10
function SApplyJoinDrawAndGuessFailRep:ctor(error_code, params)
  self.id = 12617232
  self.error_code = error_code or nil
  self.params = params or {}
end
function SApplyJoinDrawAndGuessFailRep:marshal(os)
  os:marshalInt32(self.error_code)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalString(v)
  end
end
function SApplyJoinDrawAndGuessFailRep:unmarshal(os)
  self.error_code = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.params, v)
  end
end
function SApplyJoinDrawAndGuessFailRep:sizepolicy(size)
  return size <= 65535
end
return SApplyJoinDrawAndGuessFailRep
