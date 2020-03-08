local SGatherItemSuc = class("SGatherItemSuc")
SGatherItemSuc.TYPEID = 12621596
function SGatherItemSuc:ctor(instanceId, gatherItemCfgId)
  self.id = 12621596
  self.instanceId = instanceId or nil
  self.gatherItemCfgId = gatherItemCfgId or nil
end
function SGatherItemSuc:marshal(os)
  os:marshalInt64(self.instanceId)
  os:marshalInt32(self.gatherItemCfgId)
end
function SGatherItemSuc:unmarshal(os)
  self.instanceId = os:unmarshalInt64()
  self.gatherItemCfgId = os:unmarshalInt32()
end
function SGatherItemSuc:sizepolicy(size)
  return size <= 65535
end
return SGatherItemSuc
