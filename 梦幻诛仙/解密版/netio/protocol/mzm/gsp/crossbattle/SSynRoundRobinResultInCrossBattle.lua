local SSynRoundRobinResultInCrossBattle = class("SSynRoundRobinResultInCrossBattle")
SSynRoundRobinResultInCrossBattle.TYPEID = 12616977
function SSynRoundRobinResultInCrossBattle:ctor(activity_cfg_id, rankList)
  self.id = 12616977
  self.activity_cfg_id = activity_cfg_id or nil
  self.rankList = rankList or {}
end
function SSynRoundRobinResultInCrossBattle:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalCompactUInt32(table.getn(self.rankList))
  for _, v in ipairs(self.rankList) do
    v:marshal(os)
  end
end
function SSynRoundRobinResultInCrossBattle:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleVoteRoundRobinPointRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rankList, v)
  end
end
function SSynRoundRobinResultInCrossBattle:sizepolicy(size)
  return size <= 65535
end
return SSynRoundRobinResultInCrossBattle
