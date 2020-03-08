local SLeaveLadderErrorRes = class("SLeaveLadderErrorRes")
SLeaveLadderErrorRes.TYPEID = 12607251
SLeaveLadderErrorRes.NOT_TEAM_LEADER = 1
SLeaveLadderErrorRes.TEAM_CHANGED = 2
SLeaveLadderErrorRes.IN_READY_STAGE = 3
SLeaveLadderErrorRes.IN_MATCH_STAGE = 4
SLeaveLadderErrorRes.IN_CROSS_SERVER_NOW = 5
function SLeaveLadderErrorRes:ctor(ret, args)
  self.id = 12607251
  self.ret = ret or nil
  self.args = args or {}
end
function SLeaveLadderErrorRes:marshal(os)
  os:marshalInt32(self.ret)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SLeaveLadderErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SLeaveLadderErrorRes:sizepolicy(size)
  return size <= 65535
end
return SLeaveLadderErrorRes
