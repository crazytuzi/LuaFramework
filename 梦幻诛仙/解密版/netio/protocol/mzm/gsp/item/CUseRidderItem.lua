local CUseRidderItem = class("CUseRidderItem")
CUseRidderItem.TYPEID = 788228
function CUseRidderItem:ctor(uuid)
  self.id = 788228
  self.uuid = uuid or nil
end
function CUseRidderItem:marshal(os)
  os:marshalInt64(self.uuid)
end
function CUseRidderItem:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CUseRidderItem:sizepolicy(size)
  return size <= 65535
end
return CUseRidderItem
