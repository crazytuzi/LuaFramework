local CUseWingRootItem = class("CUseWingRootItem")
CUseWingRootItem.TYPEID = 12584784
function CUseWingRootItem:ctor(uuid)
  self.id = 12584784
  self.uuid = uuid or nil
end
function CUseWingRootItem:marshal(os)
  os:marshalInt64(self.uuid)
end
function CUseWingRootItem:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CUseWingRootItem:sizepolicy(size)
  return size <= 65535
end
return CUseWingRootItem
