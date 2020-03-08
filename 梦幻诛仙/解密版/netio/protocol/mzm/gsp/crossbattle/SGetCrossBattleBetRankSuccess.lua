local SGetCrossBattleBetRankSuccess = class("SGetCrossBattleBetRankSuccess")
SGetCrossBattleBetRankSuccess.TYPEID = 12617097
function SGetCrossBattleBetRankSuccess:ctor(rank_type, activity_cfg_id, rank_list)
  self.id = 12617097
  self.rank_type = rank_type or nil
  self.activity_cfg_id = activity_cfg_id or nil
  self.rank_list = rank_list or {}
end
function SGetCrossBattleBetRankSuccess:marshal(os)
  os:marshalInt32(self.rank_type)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalCompactUInt32(table.getn(self.rank_list))
  for _, v in ipairs(self.rank_list) do
    v:marshal(os)
  end
end
function SGetCrossBattleBetRankSuccess:unmarshal(os)
  self.rank_type = os:unmarshalInt32()
  self.activity_cfg_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleBetRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rank_list, v)
  end
end
function SGetCrossBattleBetRankSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetCrossBattleBetRankSuccess
