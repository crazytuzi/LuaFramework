local SLadderCrossMatchRoleInfo = class("SLadderCrossMatchRoleInfo")
SLadderCrossMatchRoleInfo.TYPEID = 12607256
function SLadderCrossMatchRoleInfo:ctor(matchTeamAInfos, matchTeamBInfos)
  self.id = 12607256
  self.matchTeamAInfos = matchTeamAInfos or {}
  self.matchTeamBInfos = matchTeamBInfos or {}
end
function SLadderCrossMatchRoleInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.matchTeamAInfos))
  for _, v in ipairs(self.matchTeamAInfos) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.matchTeamBInfos))
  for _, v in ipairs(self.matchTeamBInfos) do
    v:marshal(os)
  end
end
function SLadderCrossMatchRoleInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.ladder.RoleLadderCrossMatchInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.matchTeamAInfos, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.ladder.RoleLadderCrossMatchInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.matchTeamBInfos, v)
  end
end
function SLadderCrossMatchRoleInfo:sizepolicy(size)
  return size <= 65535
end
return SLadderCrossMatchRoleInfo
