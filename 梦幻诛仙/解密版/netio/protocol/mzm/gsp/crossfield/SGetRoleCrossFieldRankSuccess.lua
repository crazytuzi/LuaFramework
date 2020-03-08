local SGetRoleCrossFieldRankSuccess = class("SGetRoleCrossFieldRankSuccess")
SGetRoleCrossFieldRankSuccess.TYPEID = 12619536
function SGetRoleCrossFieldRankSuccess:ctor(rank_type, rank)
  self.id = 12619536
  self.rank_type = rank_type or nil
  self.rank = rank or nil
end
function SGetRoleCrossFieldRankSuccess:marshal(os)
  os:marshalInt32(self.rank_type)
  os:marshalInt32(self.rank)
end
function SGetRoleCrossFieldRankSuccess:unmarshal(os)
  self.rank_type = os:unmarshalInt32()
  self.rank = os:unmarshalInt32()
end
function SGetRoleCrossFieldRankSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetRoleCrossFieldRankSuccess
