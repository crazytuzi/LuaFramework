local CFabaoAddRankScoreReq = class("CFabaoAddRankScoreReq")
CFabaoAddRankScoreReq.TYPEID = 12596000
function CFabaoAddRankScoreReq:ctor(equiped, fabaouuid, itemKey, itemCount)
  self.id = 12596000
  self.equiped = equiped or nil
  self.fabaouuid = fabaouuid or nil
  self.itemKey = itemKey or nil
  self.itemCount = itemCount or nil
end
function CFabaoAddRankScoreReq:marshal(os)
  os:marshalInt32(self.equiped)
  os:marshalInt64(self.fabaouuid)
  os:marshalInt32(self.itemKey)
  os:marshalInt32(self.itemCount)
end
function CFabaoAddRankScoreReq:unmarshal(os)
  self.equiped = os:unmarshalInt32()
  self.fabaouuid = os:unmarshalInt64()
  self.itemKey = os:unmarshalInt32()
  self.itemCount = os:unmarshalInt32()
end
function CFabaoAddRankScoreReq:sizepolicy(size)
  return size <= 65535
end
return CFabaoAddRankScoreReq
