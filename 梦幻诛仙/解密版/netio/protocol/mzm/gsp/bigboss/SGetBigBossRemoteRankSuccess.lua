local SGetBigBossRemoteRankSuccess = class("SGetBigBossRemoteRankSuccess")
SGetBigBossRemoteRankSuccess.TYPEID = 12598029
function SGetBigBossRemoteRankSuccess:ctor(occupation, startpos, num, rank_list)
  self.id = 12598029
  self.occupation = occupation or nil
  self.startpos = startpos or nil
  self.num = num or nil
  self.rank_list = rank_list or {}
end
function SGetBigBossRemoteRankSuccess:marshal(os)
  os:marshalInt32(self.occupation)
  os:marshalInt32(self.startpos)
  os:marshalInt32(self.num)
  os:marshalCompactUInt32(table.getn(self.rank_list))
  for _, v in ipairs(self.rank_list) do
    v:marshal(os)
  end
end
function SGetBigBossRemoteRankSuccess:unmarshal(os)
  self.occupation = os:unmarshalInt32()
  self.startpos = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.bigboss.BigbossRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rank_list, v)
  end
end
function SGetBigBossRemoteRankSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetBigBossRemoteRankSuccess
