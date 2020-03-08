local CUseGiftBagItem = class("CUseGiftBagItem")
CUseGiftBagItem.TYPEID = 12584715
function CUseGiftBagItem:ctor(uuid, isUseAll)
  self.id = 12584715
  self.uuid = uuid or nil
  self.isUseAll = isUseAll or nil
end
function CUseGiftBagItem:marshal(os)
  os:marshalInt64(self.uuid)
  os:marshalInt32(self.isUseAll)
end
function CUseGiftBagItem:unmarshal(os)
  self.uuid = os:unmarshalInt64()
  self.isUseAll = os:unmarshalInt32()
end
function CUseGiftBagItem:sizepolicy(size)
  return size <= 65535
end
return CUseGiftBagItem
