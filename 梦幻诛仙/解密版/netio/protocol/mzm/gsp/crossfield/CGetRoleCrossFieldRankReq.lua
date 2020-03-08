local CGetRoleCrossFieldRankReq = class("CGetRoleCrossFieldRankReq")
CGetRoleCrossFieldRankReq.TYPEID = 12619534
function CGetRoleCrossFieldRankReq:ctor(rank_type)
  self.id = 12619534
  self.rank_type = rank_type or nil
end
function CGetRoleCrossFieldRankReq:marshal(os)
  os:marshalInt32(self.rank_type)
end
function CGetRoleCrossFieldRankReq:unmarshal(os)
  self.rank_type = os:unmarshalInt32()
end
function CGetRoleCrossFieldRankReq:sizepolicy(size)
  return size <= 65535
end
return CGetRoleCrossFieldRankReq
