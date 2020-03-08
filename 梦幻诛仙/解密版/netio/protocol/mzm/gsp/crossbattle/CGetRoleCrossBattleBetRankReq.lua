local CGetRoleCrossBattleBetRankReq = class("CGetRoleCrossBattleBetRankReq")
CGetRoleCrossBattleBetRankReq.TYPEID = 12617093
function CGetRoleCrossBattleBetRankReq:ctor(rank_type, activity_cfg_id)
  self.id = 12617093
  self.rank_type = rank_type or nil
  self.activity_cfg_id = activity_cfg_id or nil
end
function CGetRoleCrossBattleBetRankReq:marshal(os)
  os:marshalInt32(self.rank_type)
  os:marshalInt32(self.activity_cfg_id)
end
function CGetRoleCrossBattleBetRankReq:unmarshal(os)
  self.rank_type = os:unmarshalInt32()
  self.activity_cfg_id = os:unmarshalInt32()
end
function CGetRoleCrossBattleBetRankReq:sizepolicy(size)
  return size <= 65535
end
return CGetRoleCrossBattleBetRankReq
