local LevelCfg = require("netio.protocol.mzm.gsp.teamplatform.LevelCfg")
local CStartMatch = class("CStartMatch")
CStartMatch.TYPEID = 12593677
function CStartMatch:ctor(matchCfgIds, levelRange)
  self.id = 12593677
  self.matchCfgIds = matchCfgIds or {}
  self.levelRange = levelRange or LevelCfg.new()
end
function CStartMatch:marshal(os)
  os:marshalCompactUInt32(table.getn(self.matchCfgIds))
  for _, v in ipairs(self.matchCfgIds) do
    v:marshal(os)
  end
  self.levelRange:marshal(os)
end
function CStartMatch:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.teamplatform.MatchCfg")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.matchCfgIds, v)
  end
  self.levelRange = LevelCfg.new()
  self.levelRange:unmarshal(os)
end
function CStartMatch:sizepolicy(size)
  return size <= 65535
end
return CStartMatch
