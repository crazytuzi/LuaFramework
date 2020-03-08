local CUseWingExpItem = class("CUseWingExpItem")
CUseWingExpItem.TYPEID = 12596490
function CUseWingExpItem:ctor(index, uuid)
  self.id = 12596490
  self.index = index or nil
  self.uuid = uuid or nil
end
function CUseWingExpItem:marshal(os)
  os:marshalInt32(self.index)
  os:marshalInt64(self.uuid)
end
function CUseWingExpItem:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.uuid = os:unmarshalInt64()
end
function CUseWingExpItem:sizepolicy(size)
  return size <= 65535
end
return CUseWingExpItem
