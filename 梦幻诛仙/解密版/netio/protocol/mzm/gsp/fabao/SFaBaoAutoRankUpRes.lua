local SFaBaoAutoRankUpRes = class("SFaBaoAutoRankUpRes")
SFaBaoAutoRankUpRes.TYPEID = 12596043
function SFaBaoAutoRankUpRes:ctor(next_rank_skillid, random_skillid, fabaouuid, equiped, upToFaBaoCfgid)
  self.id = 12596043
  self.next_rank_skillid = next_rank_skillid or nil
  self.random_skillid = random_skillid or nil
  self.fabaouuid = fabaouuid or nil
  self.equiped = equiped or nil
  self.upToFaBaoCfgid = upToFaBaoCfgid or nil
end
function SFaBaoAutoRankUpRes:marshal(os)
  os:marshalInt32(self.next_rank_skillid)
  os:marshalInt32(self.random_skillid)
  os:marshalInt64(self.fabaouuid)
  os:marshalInt32(self.equiped)
  os:marshalInt32(self.upToFaBaoCfgid)
end
function SFaBaoAutoRankUpRes:unmarshal(os)
  self.next_rank_skillid = os:unmarshalInt32()
  self.random_skillid = os:unmarshalInt32()
  self.fabaouuid = os:unmarshalInt64()
  self.equiped = os:unmarshalInt32()
  self.upToFaBaoCfgid = os:unmarshalInt32()
end
function SFaBaoAutoRankUpRes:sizepolicy(size)
  return size <= 65535
end
return SFaBaoAutoRankUpRes
