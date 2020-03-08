local SGatherBattleItemRep = class("SGatherBattleItemRep")
SGatherBattleItemRep.TYPEID = 12621593
function SGatherBattleItemRep:ctor(instanceId, endTime)
  self.id = 12621593
  self.instanceId = instanceId or nil
  self.endTime = endTime or nil
end
function SGatherBattleItemRep:marshal(os)
  os:marshalInt64(self.instanceId)
  os:marshalInt32(self.endTime)
end
function SGatherBattleItemRep:unmarshal(os)
  self.instanceId = os:unmarshalInt64()
  self.endTime = os:unmarshalInt32()
end
function SGatherBattleItemRep:sizepolicy(size)
  return size <= 65535
end
return SGatherBattleItemRep
