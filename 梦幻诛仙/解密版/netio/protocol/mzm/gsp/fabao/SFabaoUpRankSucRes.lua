local SFabaoUpRankSucRes = class("SFabaoUpRankSucRes")
SFabaoUpRankSucRes.TYPEID = 12595997
function SFabaoUpRankSucRes:ctor(next_rank_skillid, random_skillid, fabaouuid, equiped)
  self.id = 12595997
  self.next_rank_skillid = next_rank_skillid or nil
  self.random_skillid = random_skillid or nil
  self.fabaouuid = fabaouuid or nil
  self.equiped = equiped or nil
end
function SFabaoUpRankSucRes:marshal(os)
  os:marshalInt32(self.next_rank_skillid)
  os:marshalInt32(self.random_skillid)
  os:marshalInt64(self.fabaouuid)
  os:marshalInt32(self.equiped)
end
function SFabaoUpRankSucRes:unmarshal(os)
  self.next_rank_skillid = os:unmarshalInt32()
  self.random_skillid = os:unmarshalInt32()
  self.fabaouuid = os:unmarshalInt64()
  self.equiped = os:unmarshalInt32()
end
function SFabaoUpRankSucRes:sizepolicy(size)
  return size <= 65535
end
return SFabaoUpRankSucRes
