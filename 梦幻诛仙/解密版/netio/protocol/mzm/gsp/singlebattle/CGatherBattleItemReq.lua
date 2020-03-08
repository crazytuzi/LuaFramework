local CGatherBattleItemReq = class("CGatherBattleItemReq")
CGatherBattleItemReq.TYPEID = 12621591
function CGatherBattleItemReq:ctor(instanceId)
  self.id = 12621591
  self.instanceId = instanceId or nil
end
function CGatherBattleItemReq:marshal(os)
  os:marshalInt64(self.instanceId)
end
function CGatherBattleItemReq:unmarshal(os)
  self.instanceId = os:unmarshalInt64()
end
function CGatherBattleItemReq:sizepolicy(size)
  return size <= 65535
end
return CGatherBattleItemReq
