local CGetBigBossRemoteRankReq = class("CGetBigBossRemoteRankReq")
CGetBigBossRemoteRankReq.TYPEID = 12598030
function CGetBigBossRemoteRankReq:ctor(occupation, startpos, num)
  self.id = 12598030
  self.occupation = occupation or nil
  self.startpos = startpos or nil
  self.num = num or nil
end
function CGetBigBossRemoteRankReq:marshal(os)
  os:marshalInt32(self.occupation)
  os:marshalInt32(self.startpos)
  os:marshalInt32(self.num)
end
function CGetBigBossRemoteRankReq:unmarshal(os)
  self.occupation = os:unmarshalInt32()
  self.startpos = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function CGetBigBossRemoteRankReq:sizepolicy(size)
  return size <= 65535
end
return CGetBigBossRemoteRankReq
