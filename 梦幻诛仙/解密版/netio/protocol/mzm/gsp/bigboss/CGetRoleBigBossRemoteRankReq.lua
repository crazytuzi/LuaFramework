local CGetRoleBigBossRemoteRankReq = class("CGetRoleBigBossRemoteRankReq")
CGetRoleBigBossRemoteRankReq.TYPEID = 12598033
function CGetRoleBigBossRemoteRankReq:ctor(occupation)
  self.id = 12598033
  self.occupation = occupation or nil
end
function CGetRoleBigBossRemoteRankReq:marshal(os)
  os:marshalInt32(self.occupation)
end
function CGetRoleBigBossRemoteRankReq:unmarshal(os)
  self.occupation = os:unmarshalInt32()
end
function CGetRoleBigBossRemoteRankReq:sizepolicy(size)
  return size <= 65535
end
return CGetRoleBigBossRemoteRankReq
