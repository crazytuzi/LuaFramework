local SGetRoleCrossBattleBetRankSuccess = class("SGetRoleCrossBattleBetRankSuccess")
SGetRoleCrossBattleBetRankSuccess.TYPEID = 12617094
function SGetRoleCrossBattleBetRankSuccess:ctor(rank_type, activity_cfg_id, rank, profit, timestamp)
  self.id = 12617094
  self.rank_type = rank_type or nil
  self.activity_cfg_id = activity_cfg_id or nil
  self.rank = rank or nil
  self.profit = profit or nil
  self.timestamp = timestamp or nil
end
function SGetRoleCrossBattleBetRankSuccess:marshal(os)
  os:marshalInt32(self.rank_type)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.rank)
  os:marshalInt64(self.profit)
  os:marshalInt32(self.timestamp)
end
function SGetRoleCrossBattleBetRankSuccess:unmarshal(os)
  self.rank_type = os:unmarshalInt32()
  self.activity_cfg_id = os:unmarshalInt32()
  self.rank = os:unmarshalInt32()
  self.profit = os:unmarshalInt64()
  self.timestamp = os:unmarshalInt32()
end
function SGetRoleCrossBattleBetRankSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetRoleCrossBattleBetRankSuccess
