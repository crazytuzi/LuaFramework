local SRejectJoin = class("SRejectJoin")
SRejectJoin.TYPEID = 12619267
SRejectJoin.TEAM_NOT_ENOUGH = 0
SRejectJoin.MEMBER_LEVEL_LOW = 1
SRejectJoin.PROTOCOL_PARAM_WRONG = 2
SRejectJoin.ACTIVITY_CLOSED = 3
SRejectJoin.NPC_SERVICE_NOT_AVAILABLE = 4
SRejectJoin.NOT_NEARBY_NPC = 5
SRejectJoin.TEAM_NOT_EXIST = 6
SRejectJoin.IS_NOT_LEADER = 7
SRejectJoin.TEAM_MEMBER_NOT_NORMAL = 8
SRejectJoin.TEAM_CHANGED = 9
function SRejectJoin:ctor(rejCode, params)
  self.id = 12619267
  self.rejCode = rejCode or nil
  self.params = params or {}
end
function SRejectJoin:marshal(os)
  os:marshalInt32(self.rejCode)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalString(v)
  end
end
function SRejectJoin:unmarshal(os)
  self.rejCode = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.params, v)
  end
end
function SRejectJoin:sizepolicy(size)
  return size <= 65535
end
return SRejectJoin
