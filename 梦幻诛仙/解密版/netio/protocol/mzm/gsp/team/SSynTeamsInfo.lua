local SSynTeamsInfo = class("SSynTeamsInfo")
SSynTeamsInfo.TYPEID = 12588341
function SSynTeamsInfo:ctor(teams)
  self.id = 12588341
  self.teams = teams or {}
end
function SSynTeamsInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.teams))
  for _, v in ipairs(self.teams) do
    v:marshal(os)
  end
end
function SSynTeamsInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.team.TeamInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.teams, v)
  end
end
function SSynTeamsInfo:sizepolicy(size)
  return size <= 65535
end
return SSynTeamsInfo
