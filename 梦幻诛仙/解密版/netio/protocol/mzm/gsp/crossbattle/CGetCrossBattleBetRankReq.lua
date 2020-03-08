local CGetCrossBattleBetRankReq = class("CGetCrossBattleBetRankReq")
CGetCrossBattleBetRankReq.TYPEID = 12617095
function CGetCrossBattleBetRankReq:ctor(rankType, activity_cfg_id, startpos, num)
  self.id = 12617095
  self.rankType = rankType or nil
  self.activity_cfg_id = activity_cfg_id or nil
  self.startpos = startpos or nil
  self.num = num or nil
end
function CGetCrossBattleBetRankReq:marshal(os)
  os:marshalInt32(self.rankType)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.startpos)
  os:marshalInt32(self.num)
end
function CGetCrossBattleBetRankReq:unmarshal(os)
  self.rankType = os:unmarshalInt32()
  self.activity_cfg_id = os:unmarshalInt32()
  self.startpos = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function CGetCrossBattleBetRankReq:sizepolicy(size)
  return size <= 65535
end
return CGetCrossBattleBetRankReq
