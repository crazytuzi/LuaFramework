local SGetRoundRobinPointInfoInCrossBattleSuccess = class("SGetRoundRobinPointInfoInCrossBattleSuccess")
SGetRoundRobinPointInfoInCrossBattleSuccess.TYPEID = 12617015
function SGetRoundRobinPointInfoInCrossBattleSuccess:ctor(activity_cfg_id, rankList)
  self.id = 12617015
  self.activity_cfg_id = activity_cfg_id or nil
  self.rankList = rankList or {}
end
function SGetRoundRobinPointInfoInCrossBattleSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalCompactUInt32(table.getn(self.rankList))
  for _, v in ipairs(self.rankList) do
    v:marshal(os)
  end
end
function SGetRoundRobinPointInfoInCrossBattleSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleVoteRoundRobinPointRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rankList, v)
  end
end
function SGetRoundRobinPointInfoInCrossBattleSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetRoundRobinPointInfoInCrossBattleSuccess
