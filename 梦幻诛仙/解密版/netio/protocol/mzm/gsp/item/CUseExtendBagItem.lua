local CUseExtendBagItem = class("CUseExtendBagItem")
CUseExtendBagItem.TYPEID = 12584740
function CUseExtendBagItem:ctor(uuid)
  self.id = 12584740
  self.uuid = uuid or nil
end
function CUseExtendBagItem:marshal(os)
  os:marshalInt64(self.uuid)
end
function CUseExtendBagItem:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CUseExtendBagItem:sizepolicy(size)
  return size <= 65535
end
return CUseExtendBagItem
