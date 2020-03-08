local CGetCrossBattleVoteRankReq = class("CGetCrossBattleVoteRankReq")
CGetCrossBattleVoteRankReq.TYPEID = 12616971
CGetCrossBattleVoteRankReq.ACCESS_TYPE_POSITION = 0
CGetCrossBattleVoteRankReq.ACCESS_TYPE_CORPS_ID = 1
function CGetCrossBattleVoteRankReq:ctor(activity_cfg_id, rank_type, access_type, startpos, corps_id, num)
  self.id = 12616971
  self.activity_cfg_id = activity_cfg_id or nil
  self.rank_type = rank_type or nil
  self.access_type = access_type or nil
  self.startpos = startpos or nil
  self.corps_id = corps_id or nil
  self.num = num or nil
end
function CGetCrossBattleVoteRankReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.rank_type)
  os:marshalInt32(self.access_type)
  os:marshalInt32(self.startpos)
  os:marshalInt64(self.corps_id)
  os:marshalInt32(self.num)
end
function CGetCrossBattleVoteRankReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.rank_type = os:unmarshalInt32()
  self.access_type = os:unmarshalInt32()
  self.startpos = os:unmarshalInt32()
  self.corps_id = os:unmarshalInt64()
  self.num = os:unmarshalInt32()
end
function CGetCrossBattleVoteRankReq:sizepolicy(size)
  return size <= 65535
end
return CGetCrossBattleVoteRankReq
