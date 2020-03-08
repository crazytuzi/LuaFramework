local SMatchFightEndRet = class("SMatchFightEndRet")
SMatchFightEndRet.TYPEID = 12607258
SMatchFightEndRet.TEAM_A_WIN = 0
SMatchFightEndRet.TEAM_A_LOSE = 1
function SMatchFightEndRet:ctor(teamAEndRetInfo, teamBEndRetInfo, ret)
  self.id = 12607258
  self.teamAEndRetInfo = teamAEndRetInfo or {}
  self.teamBEndRetInfo = teamBEndRetInfo or {}
  self.ret = ret or nil
end
function SMatchFightEndRet:marshal(os)
  os:marshalCompactUInt32(table.getn(self.teamAEndRetInfo))
  for _, v in ipairs(self.teamAEndRetInfo) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.teamBEndRetInfo))
  for _, v in ipairs(self.teamBEndRetInfo) do
    v:marshal(os)
  end
  os:marshalInt32(self.ret)
end
function SMatchFightEndRet:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.ladder.RoleEndRetInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.teamAEndRetInfo, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.ladder.RoleEndRetInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.teamBEndRetInfo, v)
  end
  self.ret = os:unmarshalInt32()
end
function SMatchFightEndRet:sizepolicy(size)
  return size <= 65535
end
return SMatchFightEndRet
