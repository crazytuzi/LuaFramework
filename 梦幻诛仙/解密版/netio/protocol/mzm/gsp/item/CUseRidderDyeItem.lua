local CUseRidderDyeItem = class("CUseRidderDyeItem")
CUseRidderDyeItem.TYPEID = 788240
function CUseRidderDyeItem:ctor(uuid)
  self.id = 788240
  self.uuid = uuid or nil
end
function CUseRidderDyeItem:marshal(os)
  os:marshalInt64(self.uuid)
end
function CUseRidderDyeItem:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CUseRidderDyeItem:sizepolicy(size)
  return size <= 65535
end
return CUseRidderDyeItem
