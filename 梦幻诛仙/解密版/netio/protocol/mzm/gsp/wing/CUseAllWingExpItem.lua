local CUseAllWingExpItem = class("CUseAllWingExpItem")
CUseAllWingExpItem.TYPEID = 12596515
function CUseAllWingExpItem:ctor(index, uuid)
  self.id = 12596515
  self.index = index or nil
  self.uuid = uuid or nil
end
function CUseAllWingExpItem:marshal(os)
  os:marshalInt32(self.index)
  os:marshalInt64(self.uuid)
end
function CUseAllWingExpItem:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.uuid = os:unmarshalInt64()
end
function CUseAllWingExpItem:sizepolicy(size)
  return size <= 65535
end
return CUseAllWingExpItem
