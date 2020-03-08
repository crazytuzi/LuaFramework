local SMapItemGatherSuccess = class("SMapItemGatherSuccess")
SMapItemGatherSuccess.TYPEID = 12590874
function SMapItemGatherSuccess:ctor(instanceId, itemId, num)
  self.id = 12590874
  self.instanceId = instanceId or nil
  self.itemId = itemId or nil
  self.num = num or nil
end
function SMapItemGatherSuccess:marshal(os)
  os:marshalInt32(self.instanceId)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.num)
end
function SMapItemGatherSuccess:unmarshal(os)
  self.instanceId = os:unmarshalInt32()
  self.itemId = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function SMapItemGatherSuccess:sizepolicy(size)
  return size <= 65535
end
return SMapItemGatherSuccess
