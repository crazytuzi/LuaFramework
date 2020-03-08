local SGatherBattleItemFail = class("SGatherBattleItemFail")
SGatherBattleItemFail.TYPEID = 12621594
SGatherBattleItemFail.FAIL_FIGHT = 1
SGatherBattleItemFail.FAIL_MOVE = 2
SGatherBattleItemFail.FAIL_BATTLE_END = 3
SGatherBattleItemFail.FAIL_ITEM_DISAPPEAR = 4
SGatherBattleItemFail.FAIL_OTHER_GATHERING = 5
function SGatherBattleItemFail:ctor(instanceId, reason, gatherItemCfgId)
  self.id = 12621594
  self.instanceId = instanceId or nil
  self.reason = reason or nil
  self.gatherItemCfgId = gatherItemCfgId or nil
end
function SGatherBattleItemFail:marshal(os)
  os:marshalInt64(self.instanceId)
  os:marshalInt32(self.reason)
  os:marshalInt32(self.gatherItemCfgId)
end
function SGatherBattleItemFail:unmarshal(os)
  self.instanceId = os:unmarshalInt64()
  self.reason = os:unmarshalInt32()
  self.gatherItemCfgId = os:unmarshalInt32()
end
function SGatherBattleItemFail:sizepolicy(size)
  return size <= 65535
end
return SGatherBattleItemFail
